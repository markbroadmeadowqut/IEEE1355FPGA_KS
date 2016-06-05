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
    reg             d_inB;
    reg             s_inB;
      
    wire    [3:0]   led;
    wire    [3:0]   ledb;
    wire            d_outA;
    wire            s_outA;
    wire            D_outB;
    wire            s_outB;
    
    node dut  (
        .clk_pad        ( clk ),
        .rst_n          ( rst_n ),
        .sw             ( sw ),
        .btn            ( btn ),
        .d_inA          ( d_inA),
        .s_inA          ( s_inA),
        .d_inB          ( d_inB),
        .s_inB          ( s_inB),
		.led		    ( led ),
        .ledb           ( ledb ),
        .d_outA         ( d_outA ),
        .s_outA         ( s_outA ),
        .d_outB         ( d_outB ),
        .s_outB         ( s_outB )
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
        #1      d_inA = d_outB;
        #1      s_inA = s_outB;
        #1      d_inB = d_outA;
        #1      s_inB = s_outA;       
        
    end
    
    initial
    begin
        $display("TEST STARTED");
            
        #5800
        sw      <= 4'b1010;
        btn     <= 4'b1010;        
        #300
        sw      <= 4'b1100;
        btn     <= 4'b1100;        
        #500  
        sw      <= 4'b1110;        
        btn     <= 4'b1110;
        #500    
        sw      <= 4'b0011;        
        btn     <= 4'b0011;
        #500      
        sw      <= 4'b1011;
        btn     <= 4'b1010;        
        #500
        sw      <= 4'b1101;
        btn     <= 4'b1100;        
        #500
        sw      <= 4'b1111;        
        btn     <= 4'b1110;
        #500  
        sw      <= 4'b0011;        
        btn     <= 4'b0011;
        #500               
        
        
        
               
        //if ( error_count==0 ) $display("TEST PASSED");
        //else                  $display("TEST FAILED : %d ERRORS", error_count );
          
        $finish;
    end
        
endmodule
