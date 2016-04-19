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
        G_MAX_BIT_RATE_Mbs  	= 100    //Sets max bit rate to be 100Mbs
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
	

	reg				D_in_edge;
	reg				S_in_edge;

	reg				D_in_safe;
	reg				S_in_safe;
	
	reg				tx_active;
	reg				tx_parity;
	reg				tx_send_null_2;
	reg				tx_send_data;
	reg				tx_send_fcc;
	reg				tx_send_esc;
	reg				tx_send_eop1;
	reg				tx_send_eop2;

	reg 	[9:0]	tx_buffer;
	integer 		tx_buffer_length;
	integer			tx_bit_count;
	reg				tx_data_insert_waiting;		
	reg				tx_data_insert_done;	
	reg     [9:0]   tx_data_insert_data;
	
	
	reg 			D_out_last;
	reg 	[9:0]	rx_buffer;
	reg				rx_found_null;
	reg				rx_null_aligned;
	integer         rx_bit_count;
	reg 	[9:0]	rx_data;
	reg 	    	rx_data_valid;
	
	
function calc_tx_parity;
	input [2:0]		current_character;
	input			is_next_control;
begin
	//Ignore current_character[0] as this is the control character including in the previous parity calc
	//XOR with the generic G_LINK_PARITY_IS_ODD to make the parity of the link ODD or EVEN
	calc_tx_parity = G_LINK_PARITY_IS_ODD ^ current_character[2] ^ current_character[1] ^ is_next_control;
	
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
			rx_null_aligned	= 1'b0;
		
			rx_found_null 	= 1'b0;	

			rx_bit_count    = 0;			
			rx_data			= 10'b0000000000;
			rx_data_valid	= 1'b0;	
		end
		else if ( clk==1'b1 )
		begin
			rx_found_null 	= 1'b0;
			rx_data_valid	= 1'b0;
		
			//Shift data in
			rx_buffer		<= {D_in_safe, rx_buffer[9:1]};
			
			//Look for a NULL
			//TBD NULL will change when followed by DATA as parity will differ. Do we care if we miss one or two ???
			if ( rx_buffer[7:0] == 8'b00101110 )	
			begin
				rx_found_null 	= 1'b1;	
				rx_null_aligned	= 1'b1;
			end 	
	
            //Valid Data strobes
            if ( rx_found_null == 1'b0 && rx_null_aligned == 1'b1 && rx_bit_count == 9 )
            begin
                rx_data         <= rx_buffer;
                rx_data_valid   <= 1'b1;                
            end	
							
			//Keep count of incoming bits
			if ( rx_found_null == 1'b1 || rx_bit_count == 9 )	rx_bit_count = 0;			//Synchronises incoming data bits
			else 												rx_bit_count = rx_bit_count + 1;			
			
		end		
	end

	bfm_fifo
	#(
		.G_DATA_WIDTH_BITS	(8),
		.G_ADDR_WIDTH_BITS	(6)
	)	
	fifo_rx
	(  
		.rst_n	( rst_n ),
		.clk	( clk ),
				
		.w_en	( rx_data_valid ),	
		.w_data	( rx_data[7:0] ),
		
		.r_en	( 1'b0 ),   //Tied low. FIFO expects write DATA during recieve but the TB will take it out via a task
		.r_data	( )
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
		
			tx_send_null_2			<= 1'b1;			//Defaults to send a NULL once active
			tx_send_data			<= 1'b0;
			tx_send_fcc				<= 1'b0;
			tx_send_esc				<= 1'b0;
			tx_send_eop1			<= 1'b0;
			tx_send_eop2			<= 1'b0;
		

			if ( G_LINK_PARITY_IS_ODD==0 )	tx_buffer <= 10'b0000001111;		//First char to send is a NULL with Control=1, so parity defaults to 0 if an ODD link is needed else 1
			else 							tx_buffer <= 10'b0000001110;		//Buffer reset to hold a NULL ready for the active flag

			tx_buffer_length		<= 4;
			tx_data_insert_done 	<= 1'b0;
			tx_data_insert_waiting	<= 1'b0;
		end

		else if ( clk==1'b1 )
		begin			
			tx_data_insert_done 	= 1'b0;
						
			if ( tx_active == 1'b1 )
			begin
			
				//Update next to send when tx_bit_count has progressed enough
				if ( tx_bit_count == tx_buffer_length-1 ) 
				begin
				
					//TBD Parity calculated with tx_send_data but tx_send_data can change before next CHAR sent
					//TBD If tx_send_data is low when parity calculated then the next char must be a CONTROL character
						
					if ( tx_send_null_2 == 1'b1 ) 
					begin
						//HIGHEST PRIORITY as we have just done a NULL_1 so must finish with a NULL_2						
						tx_parity				 = calc_tx_parity(`C_CHAR_NULL_2, ~tx_send_data );
												
						tx_buffer[3:1]			<= `C_CHAR_NULL_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b0;				
					end
					else if ( tx_send_data==1'b1 )
					begin
						//TBD
						tx_buffer				<= 10'b1010101010;
						tx_buffer_length		<= 10;			
					end
					else if ( tx_send_fcc==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_FCC, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_FCC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
					end			
					else if ( tx_send_esc==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_ESC, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_ESC;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;								
					end					
					else if ( tx_send_eop1==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_EOP_1, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_EOP_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;								
					end					
					else if ( tx_send_eop2==1'b1 )
					begin
						tx_parity				 = calc_tx_parity(`C_CHAR_EOP_2, ~tx_send_data );												
						tx_buffer[3:1]			<= `C_CHAR_EOP_2;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;								
					end					
					else
					begin
						//Default send first four bits of NULL
						tx_buffer[3:1]			<= `C_CHAR_NULL_1;
						tx_buffer[0]			<= tx_parity;
						tx_buffer_length		<= 4;			
						tx_send_null_2			<= 1'b1;
					end 
				
				end
			end
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
//			if ( tx_bit_count==9 )
//			begin		
//				if ( tx_data_insert_waiting == 1'b1 )
//				begin
//					tx_data_insert_done 	<= 1'b1;
//					tx_buffer				<= tx_data_insert_data;
//				end		
//				else 				
//				begin
//					tx_buffer				<= `C_NULL_CHAR;
//				end	
//			end	
		end					
	end		

//#################################################################################################	
// OUTPUT STAGE
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
						tx_active		<= 1'b1;
					
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
// Write 10bit into tx_buffer
task insert_10b;
	input [9:0]  	new_data;
begin
	$display ("%gns ieee1355_insert_10b : %h Data", $time, new_data);
	
	tx_data_insert_waiting	= 1'b1;
	tx_data_insert_data	    = new_data;
		
	wait ( tx_data_insert_done	== 1'b1);
	wait ( tx_data_insert_done	== 1'b0);
	
	tx_data_insert_waiting	= 1'b0;
	
 end
 endtask


endmodule














