//--------------------------------------------------------------------------------
// bfm_fifo
//
// Bus functional model of a FIFO which can interface to clocked logic but TB 
// scripts can read and write to the data array
//
//--------------------------------------------------------------------------------

module bfm_fifo
	#(
    parameter 
        G_DATA_WIDTH_BITS  = 8,				//Sets the width of the data bus
		G_ADDR_WIDTH_BITS  = 6				//Sets the width of the internal address bus, gives how much DATA can be stored i.e. 2^G_ADDR_WIDTH_BITS
	)
	(  
		input								rst_n,
		input								clk,
				
		input								w_en,		//Active high write enable strobe	
		input		[G_DATA_WIDTH_BITS-1:0]	w_data,		
		
		input    							r_en,		//Active high read enable strobe
		output reg	[G_DATA_WIDTH_BITS-1:0]	r_data
		
        
    );
	
	reg  [G_ADDR_WIDTH_BITS:0]   fill_level;
	
	reg	[G_DATA_WIDTH_BITS-1:0]	fifo_array [0:(2**G_ADDR_WIDTH_BITS)-1];	
	int	w_addr;
	int r_addr;
	

    //Read data always available
    assign r_data   = fifo_array[r_addr];

	
	always @( negedge rst_n or posedge clk )
	begin
		if ( rst_n==1'b0 ) 
		begin
			w_addr	                = 0;
			r_addr	                = 0;
			fill_level              = 0;
		end		
		else if ( clk==1'b1 )
		begin
		    if ( w_en==1'b1 )
			begin
				fifo_array[w_addr]	= w_data;
				w_addr              = w_addr + 1;
				fill_level          = fill_level + 1;
			end

			if ( r_en==1'b1 )
			begin
				r_addr	            = r_addr + 1;		
				fill_level          = fill_level - 1;		
			end			
			
		end		
	end
	
//#################################################################################################	
// 
// TASKS
// 
//#################################################################################################	
	
task wait_fill_level;
    input integer   i_fill_level;
    
begin
	//$display ("%gns bfm_fifo : Waiting Fill %d", $time, i_fill_level );

	while ( fill_level < i_fill_level ) begin
		@(posedge clk);
		//$display ("%gns bfm_fifo : Fill=%d", $time, fill_level );
	end	
	
end
endtask		
	

endmodule
