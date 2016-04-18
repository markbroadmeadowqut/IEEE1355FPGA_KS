//--------------------------------------------------------------------------------
// bfm_ieee1355
//
// Bus functional model to control the IEEE1355 interface
//
//--------------------------------------------------------------------------------

`define C_NULL_CHAR 10'b1111000110

module bfm_ieee1355
	#(
    parameter 
        G_MAX_BIT_RATE_Mbs  = 100    //Sets max bit rate to be 100Mbs
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

	reg				D_in_edge;
	reg				S_in_edge;

	reg				D_in_safe;
	reg				S_in_safe;
	
	
	reg 	[9:0]	tx_buffer;
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
			rx_found_null 	<= 1'b0;
			rx_data_valid	<= 1'b0;
		
			//Shift data in
			rx_buffer		<= {D_in_safe, rx_buffer[9:1]};
			
			//Look for a NULL
			if ( rx_buffer == `C_NULL_CHAR )	
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
			D_out_last		= D_out;
			D_out			= tx_buffer[tx_bit_count];				
		
			if ( D_out_last == D_out )
			begin
				S_out		<= !S_out;
			end		
						
			if ( tx_bit_count==9 )	tx_bit_count	<= 0;
			else 					tx_bit_count	<= tx_bit_count + 1;
			
		end
	end

	always @( negedge rst_n or posedge clk )		
	begin		
		if ( rst_n==1'b0 ) 
		begin			
			tx_buffer				<= `C_NULL_CHAR;
			tx_data_insert_done 	<= 1'b0;
			tx_data_insert_waiting	<= 1'b0;
		end

		else if ( clk==1'b1 )
		begin			
			tx_data_insert_done 	= 1'b0;
			
			if ( tx_bit_count==9 )
			begin
			
				if ( tx_data_insert_waiting == 1'b1 )
				begin
					tx_data_insert_done 	<= 1'b1;
					tx_buffer				<= tx_data_insert_data;
				end		
				else 				
				begin
					tx_buffer				<= `C_NULL_CHAR;
				end	
			end
		
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














