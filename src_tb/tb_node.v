//////////////////////////////////////////////////////////////////////////////////
// Project:             Final Year Project     
// Engineer:            Ken Sands 
// 
// Create Date:         16.04.2016 14:32:43
// Design Name: 
// Module Name:         test_bench_node
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision             0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_node;
    reg             clk;
    reg             rst_n;
    reg     [3:0]   sw;
    reg     [3:0]   btn;
    reg             d_in;
    reg             s_in;
      
    wire    [3:0]   led;
    wire    [3:0]   ledb;
    wire            d_out;
    wire            s_out;
    
    node dut  (
        .clk_pad        ( clk ),
        .rst_n          ( rst_n ),
        .sw             ( sw ),
        .btn            ( btn ),
        .d_in           ( d_in),
        .s_in           ( s_in),
		.led		    ( led ),
        .ledb           ( ledb ),
        .d_out          ( d_out ),
        .s_out          ( s_out )
    );
    
   initial
       $timeformat (-9, 3, " ns", 13);    
 
     initial
     begin
        #0      clk      = 1'b0;
        #0      sw       = {4{1'b0}};   
        #0      btn      = {4{1'b0}};
        #0      d_in     = 1'b0;
        #0      s_in     = 1'b0;
        
        #1      rst_n   = 1'b0;       
        #2      rst_n   = 1'b1;        
     end  
     
    always
    begin
        #5      clk = !clk;
        #1      d_in = d_out;
        #1      s_in = s_out;
    end
    
    initial
    begin
        $display("TEST STARTED");
            
        #4;
        btn     = 1;
        btn[2]  = 1;
        sw[0]   = 1;
        sw[2]   = 1;
        #10;
        
        #40;
        btn[0]  = 0;
        btn[2]  = 0;
        sw[0]   = 0;
        sw[2]   = 0;        
        btn[1]  = 1;
        btn[3]  = 1;
        sw[1]   = 1;
        sw[3]   = 1;
        #40; 
        
            
        //if ( error_count==0 ) $display("TEST PASSED");
        //else                  $display("TEST FAILED : %d ERRORS", error_count );
          
        $finish;
    end
        
endmodule
