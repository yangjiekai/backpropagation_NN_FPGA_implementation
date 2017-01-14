module FPMULTest;
    	bit   clock;
	bit  [31:0]  dataa;
	bit   [31:0]  datab;
	bit   [31:0]  result;
	

    initial begin
        clk = 0;
		  dataa= 32'd64;
		  datab=32'd44444;
		  result= 32'd0;
        forever #5 clk = ~clk;
        end

		
	 FP_MUL_altfp_mult_trn nh
	( 
	.clock(clk),
	.dataa(dataa),
	.datab(datab),
	.result(result)) ;

	

endmodule: FPMULTest