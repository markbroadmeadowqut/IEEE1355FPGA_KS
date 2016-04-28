//--------------------------------------------------------------------------------
// bfm_ieee1355
//
// Bus functional model to control the IEEE1355 interface
//
//--------------------------------------------------------------------------------




module bfm_ieee1355
	#(
    parameter 
		G_LINK_PARITY_IS_ODD	= 1,	 //If 1 link parity is ODD else EVEN	
        G_MAX_BIT_RATE_Mbs  	= 100,   //Sets max bit rate to be 100Mbs
		G_FIFO_ADDR_WIDTH_BITS	= 6
    )
	(  
		input		rst_n,
		
		input		D_in,
		input		S_in,
		
		output reg	D_out,
		output reg	S_out
    );
	
//					            MSB->LSB			
	const reg	[2:0]	C_CHAR_NULL_1 = 3'b111;		//All CHARs will need an additional parity bit as LSB
	const reg	[2:0]	C_CHAR_NULL_2 = 3'b001;
	const reg	[2:0]	C_CHAR_EOP_1  = 3'b101;
	const reg	[2:0]	C_CHAR_EOP_2  = 3'b011;
	const reg	[2:0]	C_CHAR_ESC    = 3'b111;
	const reg	[2:0]	C_CHAR_FCC    = 3'b001;	
	
	
	
	reg     		clk;
	reg     		clk_x4;
	
	typedef enum { READY, STARTED, NULL_RECEIVED, RUN, WAIT_IN_STOP, WAIT_OUT_STOP, ERROR_SEEN, ERROR_RESET, ERROR_WAIT } 		enum_link_sm;
	enum_link_sm	state_link;
	
	reg 			go_link_STARTED;
	reg 			go_link_RUN;

	reg				D_in_edge;
	reg				S_in_edge;

	reg				D_in_safe;
	reg				S_in_safe;

	//TX SIGNALS
	typedef enum { WAIT_FILL, SEND_DATA, SEND_EOP, SEND_FCC } 	enum_tx_sm;
	enum_tx_sm		state_tx;
	
	reg				tx_active;
	reg				tx_parity;
	reg				tx_parity_carry;
	reg				tx_next_must_be_control;
	reg				tx_send_null_2;
	reg				tx_send_data;
	reg				tx_send_fcc;
	reg				tx_send_esc;
	reg				tx_send_eop1;
	reg				tx_send_eop2;	
	reg				tx_send_eop_done;
	reg				tx_send_fcc_done;
	
	reg				tx_inject_parity_error_control;
	reg				tx_inject_parity_error_data;

	reg 	[9:0]	tx_buffer;
	integer 		tx_buffer_length;
	integer			tx_bit_count;
	reg 	[7:0]	tx_data;
	reg 	    	tx_data_taken;	
	wire  [G_FIFO_ADDR_WIDTH_BITS:0]   tx_fill_level;
	reg   [G_FIFO_ADDR_WIDTH_BITS:0]   tx_fill_count;

	
	//RX SIGNALS
	typedef enum { WAIT_ALIGN, RX_CONTROL, RX_DATA } 			enum_rx_sm;
	enum_rx_sm		state_rx;	
	
	reg 			D_out_last;
	reg 	[11:0]	rx_buffer;				//Holds 12 bits - to allow all of a data packet and the next two bits which will contain the parity etc
	reg				rx_found_null;
	reg     		rx_found_esc;
	reg     		rx_found_fcc;
	reg     		rx_found_eop_1;
	reg     		rx_found_eop_2;
	reg             rx_found_data;
	reg     		rx_char_error;
	reg				rx_parity_error;
	reg				rx_null_aligned;
	integer         rx_bit_count;
	reg				reset_rx_bit_count;
	reg 	[7:0]	rx_data;
	reg 	    	rx_data_valid;
	wire  [G_FIFO_ADDR_WIDTH_BITS:0]   rx_fill_level;
	
	
	integer			timer;
	reg				reset_timer;
	

function check_rx_char_parity;
	input [2:0]		bits_to_check;
	input			parity_should_be;
begin
	//Return a 1 if CORRECT

	if ( ^bits_to_check == ~parity_should_be )
	begin	
		check_rx_char_parity	= 1'b1;		//All good 
	end
	else
	begin
		check_rx_char_parity	= 1'b0;		//ERROR	
		
		$display ( "%gns %m PARITY ERROR IN CHAR %b %b", $time, bits_to_check, ~parity_should_be );		
		inc_error_count();
	end
end
endfunction

function check_rx_data_parity;
	input [8:0]		bits_to_check;		//8 data bits plus next control bit
	input			parity_should_be;
begin
	//Return a 1 if CORRECT

	if ( ^bits_to_check == ~parity_should_be )
	begin		   
		check_rx_data_parity	= 1'b1;		//All good 
	end
	else
	begin	
		check_rx_data_parity	= 1'b0;		//ERROR	
		
		$display ( "%gns %m PARITY ERROR IN DATA %b %b", $time, bits_to_check, ~parity_should_be );
		inc_error_count();
	end
end
endfunction

	
//#################################################################################################	
// CLOCKS
// Need a clock more than 2.5 times the bit rate, in this case 4 times
// Need a clock at the bit rate for transmit
//#################################################################################################
    real            bit_freq_ns   		= (1000/G_MAX_BIT_RATE_Mbs);
	real            bit_freq_sample_ns  = bit_freq_ns/4;

	initial
	begin
		#0    clk_x4  = 1'b0;
	end

	//Clockx4
	always
	begin
		if ( rst_n == 1'b0 )	wait ( rst_n == 1'b1 );
		
		#(bit_freq_sample_ns/2)	clk_x4 	= !clk_x4;
	end
	
	//Clock
	always @( negedge rst_n or posedge clk_x4 )
	begin
		integer		count;

		if ( rst_n==1'b0 ) 
		begin
			count 		= 0;
			clk			= 1'b0;
		end		
		else if ( clk_x4==1'b1 )
		begin
		
			if ( count == 3 )
			begin
				count	= 0;
				clk 	= !clk;
			end 
			else
			begin
				count	= count + 1;
			end
		end		
	end

//#################################################################################################	
// INPUT STAGE
// Double sample the D and S inputs, then edge detect
//#################################################################################################
	always @( negedge rst_n or posedge clk_x4 )
	begin	
		reg		D_in_1;
		reg 	D_in_2;
		reg 	S_in_1;		
		reg 	S_in_2;	
	
		if ( rst_n==1'b0 ) 
		begin			
			D_in_1			<= 1'b0;
			D_in_2			<= 1'b0;
			S_in_1			<= 1'b0;
			S_in_2			<= 1'b0;
			
			D_in_edge		<= 1'b0;
			S_in_edge		<= 1'b0;
			
			D_in_safe		<= 1'b0;
			S_in_safe		<= 1'b0;
		end
		else if ( clk_x4==1'b1 )
		begin
			D_in_1			<= D_in;
			D_in_2			<= D_in_1;
		
			S_in_1			<= S_in;
			S_in_2			<= S_in_1;
			
			D_in_edge		<= D_in_2 ^ D_in_1;
			S_in_edge		<= S_in_2 ^ S_in_1;			
			
			if ( D_in_edge == 1'b1 ) D_in_safe <= !D_in_safe;
			if ( S_in_edge == 1'b1 ) S_in_safe <= !S_in_safe;
		end
	end	

//#################################################################################################	
// INPUT STAGE
// Put safe D and S into a shift register and look for the NULL character
//#################################################################################################	
	always @( negedge rst_n or posedge clk )
	begin				   
		if ( rst_n==1'b0 ) 
		begin			
			state_rx			<= WAIT_ALIGN;
		
			rx_null_aligned		= 1'b0;
		
			rx_found_null 		= 1'b0;	
			rx_found_esc 	 	= 1'b0;
			rx_found_fcc 	 	= 1'b0;
			rx_found_eop_1 	 	= 1'b0;
			rx_found_eop_2 	 	= 1'b0;
			rx_found_data		= 1'b0;
			
			rx_char_error 	 	= 1'b0;	
			rx_parity_error     = 1'b0;			

			rx_bit_count    	= 0;	
			reset_rx_bit_count	= 1'b0;
			
			rx_data				= 8'h00;
			rx_data_valid		= 1'b0;	
		end
		else if ( clk==1'b1 )
		begin
			rx_found_null 	 	 = 1'b0;
			rx_found_esc 	 	 = 1'b0;
			rx_found_fcc 	 	 = 1'b0;
			rx_found_eop_1 	 	 = 1'b0;
			rx_found_eop_2 	 	 = 1'b0;
			
			rx_char_error 	 	 = 1'b0;			
			rx_parity_error		 = 1'b0;
			
			reset_rx_bit_count	 = 1'b0;
			rx_data_valid		<= 1'b0;
		
		
			//Shift data in
			rx_buffer			<= {D_in_safe, rx_buffer[11:1]};
			

			case( state_rx )
				WAIT_ALIGN : 
					begin 			
						//Look for NULL characters, two parity options
						if ( rx_buffer[7:0] == 8'b00101110 || rx_buffer[7:0] == 8'b00111110 )	
						begin
							rx_found_null    		 = 1'b1;	
							rx_null_aligned			<= 1'b1;
							reset_rx_bit_count		 = 1'b1;
							state_rx				<= RX_CONTROL;
						end			
					end
			
				RX_CONTROL : 
					begin 			
						if ( rx_bit_count==3 )
						begin				
							//Check if CONTROL character is in rx_buffer[3:0]
							if ( rx_buffer[1] == 1'b1 )
							begin
								//Is CONTROL so reset counter
								reset_rx_bit_count		= 1'b1;
						
								//What have we received ???
								if ( rx_buffer[3:1] == 3'b111 )
								begin
									rx_found_esc    	= 1'b1;						
								end					
								else if ( rx_buffer[3:1] == 3'b001 )
								begin
									rx_found_fcc    	= 1'b1;						
								end									
								else if ( rx_buffer[3:1] == 3'b101 )
								begin
									rx_found_eop_1    	= 1'b1;						
								end					
								else if ( rx_buffer[3:1] == 3'b011 )
								begin
									rx_found_eop_2   	= 1'b1;						
								end					
								else
								begin
									rx_char_error		= 1'b1;
								end		

								//Check CHAR parity
								//At this point we have a CONTROL Char in rx_buffer[3:0]
								//Calculate that Parity bit in rx_buffer[4] is correct for next character
								//Data for check is in rx_buffer[3:1] and rx_buffer[5]
									rx_parity_error			= ~check_rx_char_parity( {rx_buffer[3:2],rx_buffer[5]}, rx_buffer[4] );
						
							end
							else 
							begin
								//Check DATA parity
								//At this point we have a byte of data in rx_buffer[9:2]
								//Calculate that Parity bit in rx_buffer[10] is correct for next character
								//Data for check is in rx_buffer[9:2] and rx_buffer[11]								
								rx_parity_error			= ~check_rx_data_parity( {rx_buffer[9:2],rx_buffer[11]}, rx_buffer[10] );							

								if (rx_parity_error == 1'b0 )
								begin
									rx_data        		<= rx_buffer[9:2];
									rx_data_valid  		<= 1'b1;															
								end
								
								reset_rx_bit_count		= 1'b1;
								
								state_rx				<= RX_DATA;
							end
						end			
					end
					
				RX_DATA : 
					begin 				
						if ( rx_bit_count==9 )
						begin
						
							//Look for EOP
							if ( rx_buffer[3:1] == 3'b101 )
							begin
								rx_found_eop_1    	= 1'b1;						
							end					
							else if ( rx_buffer[3:1] == 3'b011 )
							begin
								rx_found_eop_2   	= 1'b1;						
							end						


							if ( rx_found_eop_1==1'b1 || rx_found_eop_2==1'b1 )
							begin
								state_rx				<= RX_CONTROL;
								
								//Check CHAR parity
								//At this point we have a CONTROL Char in rx_buffer[3:0]
								//Calculate that Parity bit in rx_buffer[4] is correct for next character
								//Data for check is in rx_buffer[3:1] and rx_buffer[5]
									rx_parity_error			= ~check_rx_char_parity( {rx_buffer[3:2],rx_buffer[5]}, rx_buffer[4] );								
								
								//TBD FCC must be in rx_buffer[7:4]
								
								reset_rx_bit_count 		= 1'b1;
							end
							else
							begin
								//DATA character must be in rx_buffer[9:2]
								rx_data         			<= rx_buffer[9:2];
								rx_data_valid   			<= 1'b1; 	

								//Check DATA parity
								//At this point we have a byte of data in rx_buffer[9:2]
								//Calculate that Parity bit in rx_buffer[10] is correct for next character
								//Data for check is in rx_buffer[9:2] and rx_buffer[11]								
								rx_parity_error			= ~check_rx_data_parity( {rx_buffer[9:2],rx_buffer[11]}, rx_buffer[10] );
							
								reset_rx_bit_count 			= 1'b1;
							end
						end 
			
					end
			
			endcase
			
			
			
			if ( reset_rx_bit_count == 1'b1 )	rx_bit_count = 0;
			else     							rx_bit_count = rx_bit_count + 1;			
				
		end		
	end

	bfm_fifo
	#(
		.G_DATA_WIDTH_BITS	(8),
		.G_ADDR_WIDTH_BITS	( G_FIFO_ADDR_WIDTH_BITS )
	)	
	fifo_rx
	(  
		.rst_n		( rst_n ),
		.clk		( clk ),
				
		.w_en		( rx_data_valid ),	
		.w_data		( rx_data ),
		
		.r_en		( 1'b0 ),   //Tied low. FIFO expects write DATA during recieve but the TB will take it out via a task
		.r_data		( ),
		
		.fill_level ( rx_fill_level )
    );	















	
	
	
	
//#################################################################################################	
// OUTPUT STAGE
// Creates the data signal and works out if a strobe change is needed
//#################################################################################################
	always @( negedge rst_n or posedge clk )
	begin				   
		if ( rst_n==1'b0 ) 
		begin			
			D_out			<= 1'b0;
			S_out			<= 1'b0;
			D_out_last		<= 1'b0;
			
			tx_bit_count	= 0;
		end
		else if ( clk==1'b1 )
		begin
		
			if ( tx_active==1'b1)
			begin
				D_out_last		= D_out;
				D_out			= tx_buffer[tx_bit_count];				
		
				if ( D_out_last == D_out )
				begin
					S_out		<= !S_out;
				end		
						
				if ( tx_bit_count==tx_buffer_length-1 )	tx_bit_count	<= 0;
				else 									tx_bit_count	<= tx_bit_count + 1;
			end 			
			else 
			begin
				D_out			<= 1'b0;
				S_out			<= 1'b0;
				D_out_last		<= 1'b0;				
				tx_bit_count	= 0;
			end
		end
	end

//#################################################################################################	
// OUTPUT STAGE
// Decide what needs to be put in the output buffer, CONTROL or DATA characters
//#################################################################################################
	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin		
			tx_parity 				<= 1'b0;
			tx_parity_carry			<= 1'b0;
		
			tx_next_must_be_control	<= 1'b0;
		
			tx_send_null_2			<= 1'b1;			//Defaults to send a NULL once active
			tx_send_esc				<= 1'b0;
			tx_send_eop2			<= 1'b0;
			
			tx_send_eop_done		<= 1'b0;
			tx_send_fcc_done		<= 1'b0;		

			if ( G_LINK_PARITY_IS_ODD==0 )	tx_buffer <= 10'b0000001111;		//First char to send is a NULL with Control=1, so parity defaults to 0 if an ODD link is needed else 1
			else 							tx_buffer <= 10'b0000001110;		//Buffer reset to hold a NULL ready for the active flag

			tx_buffer_length		<= 4;
			
			tx_data_taken			<= 1'b0;
			
			tx_inject_parity_error_control	<= 1'b0;
			tx_inject_parity_error_data		<= 1'b0;
		end

		else if ( clk==1'b1 )
		begin			
			tx_data_taken			<= 1'b0;
			tx_send_eop_done		<= 1'b0;
			tx_send_fcc_done		<= 1'b0;
		
			if ( tx_active == 1'b1 )
			begin
			
				//Update next to send when tx_bit_count has progressed enough
				if ( tx_bit_count == tx_buffer_length-1 ) 
				begin
				
					//Parity calculated with tx_send_data but tx_send_data can change before next CHAR sent
					//If tx_send_data is low when parity calculated then the next char must be a CONTROL character
					if ( tx_send_data==1'b0)
					begin
						tx_next_must_be_control	<= 1'b1;
					end					
					
						
					if ( tx_send_null_2 == 1'b1 ) 
					begin					
						//HIGHEST PRIORITY as we have just done a NULL_1 so must finish with a NULL_2						
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_NULL_2[0] ^ tx_inject_parity_error_control;
						
						tx_buffer[3:1]			<= C_CHAR_NULL_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b0;				
						tx_next_must_be_control	<= 1'b0;
						
						tx_parity_carry			<= C_CHAR_NULL_2[2] ^ C_CHAR_NULL_2[1];
					end
					else if ( tx_send_data==1'b1 && tx_next_must_be_control==1'b0 )
					begin
						tx_parity				= G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ 1'b0 ^ tx_inject_parity_error_data;	
						
						tx_buffer[9:2]			<= tx_data;
						tx_buffer[1]			<= 1'b0;		//always 0 for data
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 10;	

						tx_data_taken			<= 1'b1;	
						
						tx_parity_carry			<= ^tx_data;
					end
					else if ( tx_send_fcc==1'b1 )
					begin
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_FCC[0] ^ tx_inject_parity_error_control;												
						tx_buffer[3:1]			<= C_CHAR_FCC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;		
						tx_next_must_be_control	<= 1'b0;
						tx_send_fcc_done		<= 1'b1;				
						
						tx_parity_carry			<= C_CHAR_FCC[2] ^ C_CHAR_FCC[1];
					end			
					else if ( tx_send_esc==1'b1 )
					begin
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_ESC[0] ^ tx_inject_parity_error_control;
						tx_buffer[3:1]			<= C_CHAR_ESC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;								
						tx_next_must_be_control	<= 1'b0;
						
						tx_parity_carry			<= C_CHAR_ESC[2] ^ C_CHAR_ESC[1];
					end					
					else if ( tx_send_eop1==1'b1 )
					begin
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_EOP_1[0] ^ tx_inject_parity_error_control;
						tx_buffer[3:1]			<= C_CHAR_EOP_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;
						tx_next_must_be_control	<= 1'b0;						
						tx_send_eop_done		<= 1'b1;
						
						tx_parity_carry			<= C_CHAR_EOP_1[2] ^ C_CHAR_EOP_1[1];
					end					
					else if ( tx_send_eop2==1'b1 )
					begin
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_EOP_2[0] ^ tx_inject_parity_error_control;
						tx_buffer[3:1]			<= C_CHAR_EOP_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;	
						tx_next_must_be_control	<= 1'b0;
						
						tx_parity_carry			<= C_CHAR_EOP_2[2] ^ C_CHAR_EOP_2[1];
					end					
					else
					begin
						//Default send first four bits of NULL												
						tx_parity				 = G_LINK_PARITY_IS_ODD ^ tx_parity_carry ^ C_CHAR_NULL_1[0] ^ tx_inject_parity_error_control;
						
						tx_buffer[3:1]			<= C_CHAR_NULL_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b1;
						
						tx_parity_carry			<= C_CHAR_NULL_1[2] ^ C_CHAR_NULL_1[1];
					end 
				
				end
			end
		end					
	end		
	
//#################################################################################################	
// OUTPUT STAGE
// TX FIFO Control
//#################################################################################################
	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin		
			state_tx				<= WAIT_FILL;
		
			tx_fill_count			<= 0;
			
			tx_send_data			<= 1'b0;						
			tx_send_eop1			<= 1'b0;
			tx_send_fcc				<= 1'b0;
		end

		else if ( clk==1'b1 )
		begin
			case( state_tx )
				WAIT_FILL : 
					begin 
						if ( tx_fill_level > 0 )	
						begin
							state_tx		<= SEND_DATA;
							
							tx_send_data	<= 1'b1;
							
							//Takes a snapshot of fill level to send this amount of data
							//Allows more to be written into FIFO but wont be sent in this stream
							tx_fill_count	<= tx_fill_level;
						end 
					end
					
				SEND_DATA : 
					begin
						if ( tx_data_taken ) 
						begin
							tx_fill_count	<= tx_fill_count - 1;
						end
					
					
						if ( tx_fill_count == 0 )	
						begin
							state_tx		<= SEND_EOP;
							
							tx_send_data	<= 1'b0;
						end 						
					end			

				SEND_EOP : 
					begin
						tx_send_eop1		<= 1'b1;
						
						if ( tx_send_eop_done == 1'b1 )
						begin
							tx_send_eop1	<= 1'b0;
						
							state_tx		<= SEND_FCC;
						end
					end
					
					
				SEND_FCC :
					begin
						tx_send_fcc			<= 1'b1;
						
						if ( tx_send_fcc_done == 1'b1 )
						begin
							tx_send_fcc		<= 1'b0;
						
							state_tx		<= WAIT_FILL;
						end					
					end
					
			endcase				

		end		
	end
	
	bfm_fifo
	#(
		.G_DATA_WIDTH_BITS	(8),
		.G_ADDR_WIDTH_BITS	( G_FIFO_ADDR_WIDTH_BITS )
	)	
	fifo_tx
	(  
		.rst_n		( rst_n ),
		.clk		( clk ),
				
		.w_en		( 1'b0 ),	
		.w_data		( 8'h00 ),
		
		.r_en		( tx_data_taken ),
		.r_data		( tx_data ),
		
		.fill_level ( tx_fill_level )
    );		
	
//#################################################################################################	
// TIMERS
//#################################################################################################	

	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin			
			timer			= 0;
		end
		
		else if ( clk==1'b1 )
		begin
			if ( reset_timer==1'b1 )
			begin
				timer		= 0;
			end
			else
			begin
				timer		= timer + 1;
			end		
		end
	end	

//#################################################################################################	
// LINK STATE MACHINE
// State machine - Activates LINK and maintains it
//#################################################################################################	
	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin			
			state_link		<= READY;
			
			reset_timer 	<= 1'b0;
		
			go_link_STARTED	<= 1'b0;
			go_link_RUN  	<= 1'b0;
		
			tx_active		<= 1'b0;
		end
	
		else if ( clk==1'b1 )
		begin
			reset_timer		<= 1'b0;
		

			case( state_link )
				READY : 
					begin
 
						if ( rx_found_null == 1'b1 )
						begin
														state_link	<= NULL_RECEIVED;
														$display ( "%gns %m LINK STATE READY => NULL_RECEIVED", $time );		
						end
						else if ( go_link_STARTED==1'b1 )
						begin							
														state_link	<= STARTED;
														$display ( "%gns %m LINK STATE READY => STARTED", $time );		
						end
 
					end
					
				STARTED : 
					begin
						tx_active	<= 1'b1;
					
						if ( rx_found_null == 1'b1 )
						begin							state_link	<= RUN;
														$display ( "%gns %m LINK STATE STARTED => RUN", $time );
						end
					
					end
					
				NULL_RECEIVED :
					begin
						if ( go_link_RUN==1'b1 )
						begin							state_link	<= RUN;
														$display ( "%gns %m LINK STATE NULL_RECEIVED => RUN", $time );
						end						
					end

				RUN :
					begin
						tx_active	<= 1'b1;
						
						if ( rx_parity_error == 1'b1 )
						begin							state_link	<= WAIT_IN_STOP;
														reset_timer <= 1'b1;
														$display ( "%gns %m LINK STATE RUN => WAIT_IN_STOP due to parity error", $time );
						end						
					end		
				
				WAIT_IN_STOP :
					begin
						tx_active	<= 1'b0;

						if ( 2*timer*bit_freq_ns > 6400 ) 
						begin							state_link	<= WAIT_OUT_STOP;
														$display ( "%gns %m LINK STATE WAIT_IN_STOP => WAIT_OUT_STOP due to disconnect", $time );						
						end											
					end		
					
				WAIT_OUT_STOP :
					begin								

					end		
					
				ERROR_SEEN :
					begin
					
					end		
					
				ERROR_RESET  :
					begin
					
					end		
					
				ERROR_WAIT :
					begin
					
					end		
			endcase		
	
		end
	end
	
	
	
	
	
	
	
	
	
	
//#################################################################################################	
// TASKS to enable state changes etc
//#################################################################################################	

task link_READY_to_STARTED;

begin
	wait ( state_link == READY )
		go_link_STARTED	<= 1'b1;

	wait ( state_link == STARTED )
		go_link_STARTED	<= 1'b0;

end
endtask	

task link_NULL_RECEIVED_to_RUN;

begin
	wait ( state_link == NULL_RECEIVED )
		go_link_RUN		<= 1'b1;

	wait ( state_link == RUN )
		go_link_RUN		<= 1'b0;

end
endtask	

//#################################################################################################	
// TASKS to wait for events
//#################################################################################################
task wait_link_RUN;
begin
	wait ( state_link == RUN );
end
endtask

task wait_link_WAIT_IN_STOP;
begin
	$display ( "%gns %m wait_link_WAIT_IN_STOP", $time );
	wait ( state_link == WAIT_IN_STOP )begin
		@(posedge clk);
	end		
	$display ( "%gns %m wait_link_WAIT_IN_STOP..done", $time );
end
endtask

//#################################################################################################	
// TASKS to inject errors
//#################################################################################################
task inject_TX_PARITY_ERROR_control;
	input new_setting;
begin
	tx_inject_parity_error_control	 = new_setting;
end
endtask

task inject_TX_PARITY_ERROR_data;
	input new_setting;
begin
	tx_inject_parity_error_data	 	= new_setting;
end
endtask

endmodule














