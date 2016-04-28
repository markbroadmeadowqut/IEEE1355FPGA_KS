
`timescale 1ns / 1ps

module tb_fpga;
    integer         error_count = 0;
	
	reg [7:0]		test_array [0:63];
	integer			test_length;

	reg 			clk_100;
	
	reg 			rst_n_0;
	reg 			rst_n_1;

	reg 			D_0	;
	reg 			S_0	;	
	reg 			D_1	;
	reg 			S_1	;	
	reg 			D_2	;
	reg 			S_2	;		
	reg 			D_3	;
	reg 			S_3	;	
	
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
	
	function randomise_test_data;
	begin
		for (integer i = 0; i < 64; i = i +1) begin 
			test_array[i]	= $urandom_range(255,0);
		end
		
		test_length			= $urandom_range(63,0);
	end
	endfunction	

//#################################################################################################	
//FPGA
//#################################################################################################		

    node #() node_0
	(	   
		.clk_pad		( clk_100 ),
		.rst_n			( rst_n_0 ),
		
		.d_inA			( D_1 ),
		.s_inA			( S_1 ),
		.d_outA			( D_2 ),
		.s_outA			( S_2 ),
		
		.sw				( sw_0 ),		//: in 		std_logic_vector(3 downto 0);	-- 4 switches on FPGA board	
		.btn            ( btn_0 ),		//: in      std_logic_vector(3 downto 0);	-- 4 buttons on FPGA board		  
		.led			( led_0 ),		//: out		std_logic_vector(3 downto 0);	-- 4 LEDs on FPGA board		
		.ledb           ( ledb_0 )		//: out     std_logic_vector(3 downto 0)		
	);		

    node #() node_1
	(	   
		.clk_pad		( clk_100 ),
		.rst_n			( rst_n_1 ),
		
		.d_inA			( D_2 ),
		.s_inA			( S_2 ),		
		.d_outA			( D_3 ),
		.s_outA			( S_3 ),	
		
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
	
	bfm_ieee1355	
	#(
		.G_LINK_PARITY_IS_ODD	(1),
		.G_MAX_BIT_RATE_Mbs		(100)
	)	
	bfm_ieee1355_2
	(  
		.rst_n				( rst_n_1 ),

		.D_in				( D_3 ),
		.S_in				( S_3 ),
		
		.D_out				( ),
		.S_out				( )
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

	
		$display("TEST STARTED");
		
		#2000;
		bfm_ieee1355_0.link_READY_to_STARTED();
		#2000;
		bfm_ieee1355_1.link_NULL_RECEIVED_to_RUN();		
		
		#2000;
		bfm_ieee1355_0.wait_link_RUN();
		bfm_ieee1355_1.wait_link_RUN();
		
		
		#5000;
		$display ( "%gns TB : Sending 5 bytes (DATA=NULL)", $time );
		bfm_ieee1355_0.fifo_tx.insert_w_data	( 8'b11100110 );
		bfm_ieee1355_0.fifo_tx.insert_w_data	( 8'b00101110 );	//These are the NULL codes
		bfm_ieee1355_0.fifo_tx.insert_w_data	( 8'b00101110 );	//Make sure interpreted as DATA not NULLS
		bfm_ieee1355_0.fifo_tx.insert_w_data	( 8'b00111110 );	
		bfm_ieee1355_0.fifo_tx.insert_w_data	( 8'b00111110 );	
		bfm_ieee1355_0.fifo_tx.update_fill_level( 5 );		
		
		bfm_ieee1355_1.fifo_rx.wait_fill_level(5);	
		bfm_ieee1355_1.fifo_rx.check_data		( 8'b11100110 );
		bfm_ieee1355_1.fifo_rx.check_data		( 8'b00101110 );
		bfm_ieee1355_1.fifo_rx.check_data		( 8'b00101110 );
		bfm_ieee1355_1.fifo_rx.check_data		( 8'b00111110 );
		bfm_ieee1355_1.fifo_rx.check_data		( 8'b00111110 );
		#5000;
		
		//Randomise data but force length to be 16
		$display ( "%gns TB : Sending 16 bytes", $time );
		randomise_test_data();
		test_length = 16;
		bfm_ieee1355_0.fifo_tx.insert_w_data_array( test_length, test_array );
		//Wait for data and check it
		bfm_ieee1355_1.fifo_rx.wait_fill_level	( test_length );
		bfm_ieee1355_1.fifo_rx.check_data_array	( test_length, test_array );		
		#1000;

		//Randomise data but force length to be 64
		$display ( "%gns TB : Sending 64 bytes", $time );
		randomise_test_data();
		test_length = 64;
		bfm_ieee1355_0.fifo_tx.insert_w_data_array( test_length, test_array );
		//Wait for data and check it
		bfm_ieee1355_1.fifo_rx.wait_fill_level	( test_length );
		bfm_ieee1355_1.fifo_rx.check_data_array	( test_length, test_array );		
		#1000;		
		
		
		//Inject a parity error in TX side
		$display ( "%gns TB : Inject Parity Error", $time );
		bfm_ieee1355_0.inject_TX_PARITY_ERROR_control(1'b1);
		bfm_ieee1355_1.wait_link_WAIT_IN_STOP();
		bfm_ieee1355_0.inject_TX_PARITY_ERROR_control(1'b0);
		
		
		
		#10000;
		
		if ( error_count==0 ) $display("TEST PASSED");
		else                  $display("TEST FAILED : %d ERRORS", error_count );
		
		$finish;
	end

endmodule

