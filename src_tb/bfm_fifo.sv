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
		output reg	[G_DATA_WIDTH_BITS-1:0]	r_data,
		
        output reg  [G_ADDR_WIDTH_BITS:0]   fill_level	//FIFO fill level
    );
	
	
	reg	[G_DATA_WIDTH_BITS-1:0]	fifo_array [0:(2**G_ADDR_WIDTH_BITS)-1];	
	reg [G_ADDR_WIDTH_BITS-1:0]	w_addr;
	reg [G_ADDR_WIDTH_BITS-1:0]	r_addr;
	

    //Read data always available
    assign r_data   = fifo_array[r_addr];

	
	always @( negedge rst_n or posedge clk )
	begin
		if ( rst_n==1'b0 ) 
		begin
			w_addr	                <= 0;
			r_addr	                <= 0;
			fill_level              <= 0;
		end		
		else if ( clk==1'b1 )
		begin
		    if ( w_en==1'b1 )
			begin
				fifo_array[w_addr]	<= w_data;
				w_addr              <= w_addr + 1;
				fill_level           = fill_level + 1;
			end

			if ( r_en==1'b1 )
			begin
				r_addr	            <= r_addr + 1;		
				fill_level           = fill_level - 1;		
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
	while ( fill_level < i_fill_level ) begin
		@(posedge clk);
	end		
end
endtask		


task insert_w_data;
	input [G_DATA_WIDTH_BITS-1:0]	new_data;
begin
	//Wait for negedge then we are safe to force internals
	@(negedge clk);
	
	fifo_array[w_addr]	= new_data;
	w_addr              = w_addr + 1;
end
endtask
 
task insert_w_data_array;
	input integer   data_length;
	input [7:0]  	data_array	[0:63];
begin
	@(negedge clk);

	for (integer i = 0; i < data_length; i = i +1) begin 
		fifo_array[w_addr]	= data_array[i];
		w_addr              = w_addr + 1;
	end
	
	fill_level          = fill_level + data_length;
end
endtask
 

 task update_fill_level;
	input [G_ADDR_WIDTH_BITS:0] 	new_fill_level;
begin
	$display ("%gns %m update_fill_level adding : %d", $time, new_fill_level);
	
	//Wait for negedge then we are safe to force internals
	@(negedge clk);	
	
	fill_level          = fill_level + new_fill_level;
 end
 endtask
	
	
task check_data;
	input [7:0]  	data_expected;
begin
	@(negedge clk);

	if ( fifo_array[r_addr] != data_expected )
	begin
		$display ("%gns %m ERROR Check read data expected=0x%h : actual=0x%h", $time, data_expected, fifo_array[r_addr]);
		inc_error_count();
	end
		
	r_addr	  	= r_addr + 1;		
	fill_level  = fill_level - 1;			
end
endtask		
	
task check_data_array;
	input integer   data_length;
	input [7:0]  	data_array	[0:63];
begin
	@(negedge clk);

	for (integer i = 0; i < data_length; i = i +1) begin 
		if ( fifo_array[r_addr] != data_array[i] )
		begin
			$display ("%gns %m ERROR Check read data expected=0x%h : actual=0x%h", $time, data_array[i], fifo_array[r_addr]);
			inc_error_count();
		end
		
		r_addr	  	= r_addr + 1;		
		fill_level  = fill_level - 1;		
	end	
	
end
endtask	
	
endmodule
