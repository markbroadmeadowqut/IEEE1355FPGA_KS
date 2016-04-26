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
    reg             d_inA;
    reg             s_inA;
      
    wire    [3:0]   led;
    wire    [3:0]   ledb;
    wire            d_outA;
    wire            s_outA;
    
    node dut  (
        .clk_pad        ( clk ),
        .rst_n          ( rst_n ),
        .sw             ( sw ),
        .btn            ( btn ),
        .d_inA           ( d_inA),
        .s_inA           ( s_inA),
		.led		    ( led ),
        .ledb           ( ledb ),
        .d_outA          ( d_outA ),
        .s_outA          ( s_outA )
    );
    
   initial
       $timeformat (-9, 3, " ns", 13);    
 
     initial
     begin
        #0      clk      = 1'b0;
        #0      sw       = {4{1'b0}};   
        #0      btn      = {4{1'b0}};
        #0      d_inA    = 1'b0;
        #0      s_inA    = 1'b0;
        
        #1      rst_n   = 1'b0;       
        #2      rst_n   = 1'b1;        
     end  
     
    always
    begin
        #5      clk = !clk;
        #1      d_inA = d_outA;
        #1      s_inA = s_outA;
    end
    
    initial
    begin
        $display("TEST STARTED");
            
        #400
        sw      <= 4'b1010;
        btn     <= 4'b1010;        
        #300
        sw      <= 4'b1100;
        btn     <= 4'b1100;        
        #300
        sw      <= 4'b1110;        
        btn     <= 4'b1110;
        #300     
        sw      <= 4'b0011;        
        btn     <= 4'b0011;
        #300        
        sw      <= 4'b0101;        
        btn     <= 4'b0101;
        #300           
        //if ( error_count==0 ) $display("TEST PASSED");
        //else                  $display("TEST FAILED : %d ERRORS", error_count );
          
        $finish;
    end
        
endmodule
