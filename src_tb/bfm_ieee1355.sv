//--------------------------------------------------------------------------------
// bfm_ieee1355
//
// Bus functional model to control the IEEE1355 interface
//
//--------------------------------------------------------------------------------

//					  MSB->LSB			
`define C_CHAR_NULL_1 3'b111	//All CHARs will need an additional parity bit as LSB
`define C_CHAR_NULL_2 3'b001
`define C_CHAR_EOP_1  3'b101
`define C_CHAR_EOP_2  3'b011
`define C_CHAR_ESC    3'b111
`define C_CHAR_FCC    3'b001


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
	
	reg     		clk;
	reg     		clk_x4;
	
	typedef enum { READY, STARTED, NULL_RECEIVED, RUN } enum_link_sm;
	enum_link_sm	state_link;

	typedef enum { WAIT_FILL, SEND_DATA } enum_data_sm;
	enum_data_sm	state_data;
	

	reg				D_in_edge;
	reg				S_in_edge;

	reg				D_in_safe;
	reg				S_in_safe;
	
	reg				tx_active;
	reg				tx_parity;
	reg				tx_next_must_be_control;
	reg				tx_send_null_2;
	reg				tx_send_data;
	reg				tx_send_fcc;
	reg				tx_send_esc;
	reg				tx_send_eop1;
	reg				tx_send_eop2;

	reg 	[9:0]	tx_buffer;
	integer 		tx_buffer_length;
	integer			tx_bit_count;
	reg 	[7:0]	tx_data;
	reg 	    	tx_data_taken;	
	wire  [G_FIFO_ADDR_WIDTH_BITS:0]   tx_fill_level;
	reg   [G_FIFO_ADDR_WIDTH_BITS:0]   tx_fill_count;
	
	reg 			D_out_last;
	reg 	[11:0]	rx_buffer;				//Holds 12 bits - to allow all of a data packet and the next two bits which will contain the parity etc
	reg				rx_found_null;
	reg				rx_null_aligned;
	integer         rx_bit_count;
	reg				reset_rx_bit_count;
	reg 	[7:0]	rx_data;
	reg 	    	rx_data_valid;
	wire  [G_FIFO_ADDR_WIDTH_BITS:0]   rx_fill_level;
	
	
function calc_tx_parity;
	input [2:0]		current_character;
	input			is_next_control;
begin
	//Ignore current_character[0] as this is the control character including in the previous parity calc
	//XOR with the generic G_LINK_PARITY_IS_ODD to make the parity of the link ODD or EVEN
	calc_tx_parity = G_LINK_PARITY_IS_ODD ^ current_character[2] ^ current_character[1] ^ is_next_control;
	
end	
endfunction

function calc_tx_parity_data;
	input [7:0]		data;
	input			is_next_control;
begin
	//XOR with the generic G_LINK_PARITY_IS_ODD to make the parity of the link ODD or EVEN
	calc_tx_parity_data	= G_LINK_PARITY_IS_ODD ^ data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[3] ^ data[2] ^ data[1] ^ data[0] ^ is_next_control;	
end	
endfunction
	
//#################################################################################################	
// CLOCKS
// Need a clock more than 2.5 times the bit rate, in this case 4 times
// Need a clock at the bit rate for transmit
//#################################################################################################
    integer         bit_freq_ns   		= (1000/G_MAX_BIT_RATE_Mbs);
	integer         bit_freq_sample_ns  = bit_freq_ns/4;

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
			
			count 		= count + 1;
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
			rx_null_aligned		= 1'b0;
		
			rx_found_null 		= 1'b0;	

			rx_bit_count    	= 0;	
			reset_rx_bit_count	= 1'b0;
			
			rx_data				= 8'h00;
			rx_data_valid		= 1'b0;	
		end
		else if ( clk==1'b1 )
		begin
			rx_found_null 	 	 = 1'b0;
			reset_rx_bit_count	 = 1'b0;
			rx_data_valid		<= 1'b0;
		
			//Shift data in
			rx_buffer			<= {D_in_safe, rx_buffer[11:1]};
			
			
			if ( rx_null_aligned==1'b0 )
			begin
				//Look for NULL characters, two parity options
				if ( rx_buffer[7:0] == 8'b00101110 || rx_buffer[7:0] == 8'b00111110 )	
				begin
					rx_found_null    = 1'b1;	
					rx_null_aligned	<= 1'b1;
				end 			
			end
			else 	
			begin			
				if ( rx_bit_count==7 )
				begin				
					//Check if CONTROL character is in rx_buffer[3:0]
				
					if ( rx_buffer[1] == 1'b1 )
					begin
						if ( rx_buffer[7:0] == 8'b00101110 || rx_buffer[7:0] == 8'b00111110 )
						begin
							rx_found_null    	= 1'b1;						
							reset_rx_bit_count	= 1'b1;
						end
					end					
				end			
			
				if ( rx_bit_count==9 )
				begin				
					//DATA character must be in rx_buffer[9:0]
					rx_data         			<= rx_buffer[9:2];
					rx_data_valid   			<= 1'b1; 					
					
					reset_rx_bit_count 			= 1'b1;
				end 
			
			
	
				if ( reset_rx_bit_count == 1'b1 )	rx_bit_count = 0;
				else     							rx_bit_count = rx_bit_count + 1;			
			end 	
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
		
			tx_next_must_be_control	<= 1'b0;
		
			tx_send_null_2			<= 1'b1;			//Defaults to send a NULL once active
			tx_send_fcc				<= 1'b0;
			tx_send_esc				<= 1'b0;
			tx_send_eop1			<= 1'b0;
			tx_send_eop2			<= 1'b0;
		

			if ( G_LINK_PARITY_IS_ODD==0 )	tx_buffer <= 10'b0000001111;		//First char to send is a NULL with Control=1, so parity defaults to 0 if an ODD link is needed else 1
			else 							tx_buffer <= 10'b0000001110;		//Buffer reset to hold a NULL ready for the active flag

			tx_buffer_length		<= 4;
			
			tx_data_taken			<= 1'b0;
		end

		else if ( clk==1'b1 )
		begin			
			tx_data_taken			<= 1'b0;
		
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
						tx_parity				 = calc_tx_parity(`C_CHAR_NULL_2, ~tx_send_data );
						
						tx_buffer[3:1]			<= `C_CHAR_NULL_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b0;				
						tx_next_must_be_control	<= 1'b0;
					end
					else if ( tx_send_data==1'b1 && tx_next_must_be_control==1'b0 )
					begin
						if ( tx_fill_count==1 )
						begin
							//Sending last data now
							//Make the next sent a control character and calculate parity according
							tx_next_must_be_control	<= 1'b0;
							
							tx_parity			= calc_tx_parity_data( tx_data, 1'b1 );
						end
						else
						begin						
							tx_parity			= calc_tx_parity_data( tx_data, 1'b0 );
						end
					
					
						//TBD
						tx_buffer[9:2]			<= tx_data;
						tx_buffer[1]			<= 1'b0;		//always 0 for data
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 10;	

						tx_data_taken			<= 1'b1;	
					end
					else if ( tx_send_fcc==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_FCC, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_FCC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;		
						tx_next_must_be_control	<= 1'b0;						
					end			
					else if ( tx_send_esc==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_ESC, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_ESC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;								
						tx_next_must_be_control	<= 1'b0;
					end					
					else if ( tx_send_eop1==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_EOP_1, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_EOP_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;
						tx_next_must_be_control	<= 1'b0;						
					end					
					else if ( tx_send_eop2==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_EOP_2, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_EOP_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;	
						tx_next_must_be_control	<= 1'b0;
					end					
					else
					begin
						//Default send first four bits of NULL
						tx_buffer[9:2]			<= 8'h00;				//Not needed but looks better in sim window
						tx_buffer[3:1]			<= `C_CHAR_NULL_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b1;
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
			state_data				<= WAIT_FILL;
		
			tx_fill_count			<= 0;
			tx_send_data			<= 1'b0;						
		end

		else if ( clk==1'b1 )
		begin
			case( state_data )
				WAIT_FILL : 
					begin 
						if ( tx_fill_level > 0 )	
						begin
							state_data		<= SEND_DATA;
							
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
							state_data		<= WAIT_FILL;
							
							tx_send_data	<= 1'b0;
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
// LINK STATE MACHINE
// State machine - Activates LINK and maintains it
//#################################################################################################	
	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin			
			state_link		<= READY;
		
			tx_active		<= 1'b0;
		end
	
		else if ( clk==1'b1 )
		begin

			case( state_link )
				READY : 
					begin
 
						if ( rx_found_null == 1'b1 )	state_link	<= NULL_RECEIVED;
						else 							state_link	<= STARTED;
 
					end
					
				STARTED : 
					begin
						tx_active	<= 1'b1;
					
						if ( rx_found_null == 1'b1 )	state_link	<= RUN;
					
					end
					
				NULL_RECEIVED :
					begin
					
					end

				RUN :
					begin
					
					end					
			endcase		
	
		end
	end
	
	
	
	
	
	
	
	
	
	
//#################################################################################################	
// TASKS
//#################################################################################################	

task insert_tx_data;
	input [7:0]  	new_data;
begin
	$display ("%gns insert_tx_data : %h Data", $time, new_data);
	
	fifo_tx.insert_fifo_data ( new_data );
 end
 endtask


endmodule














