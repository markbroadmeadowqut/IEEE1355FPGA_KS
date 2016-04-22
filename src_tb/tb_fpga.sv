
`timescale 1ns / 1ps

module tb_fpga;
    integer         error_count = 0;

	reg 			clk_100;
	
	reg 			rst_n_0;
	reg 			rst_n_1;

	reg 			D_0	;
	reg 			S_0	;	
	reg 			D_1	;
	reg 			S_1	;	
	
	reg 	[3:0]	sw_0;
	reg 	[3:0]	btn_0;
	wire 	[3:0]	led_0;
	wire 	[3:0]	ledb_0;

	reg 	[3:0]	sw_1;
	reg 	[3:0]	btn_1;
	wire	[3:0]	led_1;
	wire 	[3:0]	ledb_1;	
	
	function inc_error_count;
	begin
		error_count = error_count + 1;
	end
	endfunction

//#################################################################################################	
//FPGA
//#################################################################################################		

    node #() node_0
	(	   
		.CLK100MHZ		( clk_100 ),
		.rst_n			( rst_n_0 ),
		.sw				( sw_0 ),		//: in 		std_logic_vector(3 downto 0);	-- 4 switches on FPGA board	
		.btn            ( btn_0 ),		//: in      std_logic_vector(3 downto 0);	-- 4 buttons on FPGA board		  
		.led			( led_0 ),		//: out		std_logic_vector(3 downto 0);	-- 4 LEDs on FPGA board		
		.ledb           ( ledb_0 )		//: out     std_logic_vector(3 downto 0)		
	);		

    node #() node_1
	(	   
		.CLK100MHZ		( clk_100 ),
		.rst_n			( rst_n_1 ),
		.sw				( sw_1 ),		//: in 		std_logic_vector(3 downto 0);	-- 4 switches on FPGA board	
		.btn            ( btn_1 ),		//: in      std_logic_vector(3 downto 0);	-- 4 buttons on FPGA board		  
		.led			( led_1 ),		//: out		std_logic_vector(3 downto 0);	-- 4 LEDs on FPGA board		
		.ledb           ( ledb_1 )		//: out     std_logic_vector(3 downto 0)		
	);		
	
	
//#################################################################################################	
//BFM IEEE1355
//#################################################################################################	
	bfm_ieee1355	
	#(
		.G_LINK_PARITY_IS_ODD	(1),
		.G_MAX_BIT_RATE_Mbs		(100)
	)	
	bfm_ieee1355_0
	(  
		.rst_n				( rst_n_0 ),

		.D_in				( D_0 ),
		.S_in				( S_0 ),
		
		.D_out				( D_1 ),
		.S_out				( S_1 )
    );	

	bfm_ieee1355	
	#(
		.G_LINK_PARITY_IS_ODD	(1),
		.G_MAX_BIT_RATE_Mbs		(100)
	)	
	bfm_ieee1355_1
	(  
		.rst_n				( rst_n_1 ),

		.D_in				( D_1 ),
		.S_in				( S_1 ),
		
		.D_out				( D_0 ),
		.S_out				( S_0 )
    );	
	
	
//#################################################################################################	
//
//#################################################################################################		
   initial
      $timeformat (-9, 3, " ns", 13);	

	initial
	begin
		#0		clk_100 = 1'b0;
		#0  	rst_n_0 = 1'b0;
		#0  	rst_n_1 = 1'b0;
		
		//Default switches and buttons
		#0  	sw_0	= 4'b0000;
		#0  	sw_1	= 4'b0000;
		#0  	btn_0	= 4'b0000;		
		#0  	btn_1	= 4'b0000;	
		
		
		//Bring up resets at a different time
		#705    rst_n_0 = 1'b1;	
		#151 	rst_n_1 = 1'b1;				
	end

	always
	begin
		#5  	clk_100 = !clk_100;
	end


	  

//#################################################################################################	
//TEST SCRIPT
//#################################################################################################	
	initial
	begin
		//wire [7:0]	byte_array [0:63];
	
		$display("TEST STARTED");
		
		#5000;

		bfm_ieee1355_0.insert_tx_data( 8'b11100110 );
		bfm_ieee1355_0.insert_tx_data( 8'b00101110 );	//These are the NULL codes
		bfm_ieee1355_0.insert_tx_data( 8'b00101110 );	//Make sure interpreted as DATA not NULLS
		bfm_ieee1355_0.insert_tx_data( 8'b00111110 );	
		bfm_ieee1355_0.insert_tx_data( 8'b00111110 );	
		bfm_ieee1355_0.fifo_tx.update_fill_level( 5 );		
		
		bfm_ieee1355_1.fifo_rx.wait_fill_level(5);	
		#5000;
		
		bfm_ieee1355_0.insert_tx_data( 8'h00 );
		bfm_ieee1355_0.insert_tx_data( 8'h55 );
		bfm_ieee1355_0.insert_tx_data( 8'hC3 );		
		bfm_ieee1355_0.insert_tx_data( 8'h89 );
		bfm_ieee1355_0.insert_tx_data( 8'h72 );
		bfm_ieee1355_0.insert_tx_data( 8'hFF );
		bfm_ieee1355_0.fifo_tx.update_fill_level( 6 );
		bfm_ieee1355_0.insert_tx_data( 8'h01 );
		bfm_ieee1355_0.insert_tx_data( 8'h02 );
		bfm_ieee1355_0.insert_tx_data( 8'h03 );		
		bfm_ieee1355_0.fifo_tx.update_fill_level( 3 );
		
		bfm_ieee1355_1.fifo_rx.wait_fill_level(9);	
		#5000;		
		
		
		
		if ( error_count==0 ) $display("TEST PASSED");
		else                  $display("TEST FAILED : %d ERRORS", error_count );
		
		$finish;
	end

endmodule

