`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 20;

	reg [8:0] Instruction;
	reg Run;
	wire Done;
	wire [8:0] BusWires;

	reg CLOCK_50;
	initial begin
		CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	reg Resetn;
	initial begin
		Resetn <= 1'b0;
		#20 Resetn <= 1'b1;
	end // initial

	initial begin
				Run	<= 1'b0;	Instruction	<= 9'b000000000;	
		#20	Run	<= 1'b1; Instruction	<= 9'b001000000; //mvi R0	
		#20	Run	<= 1'b0; Instruction	<= 9'b000000101;	 //D
		#20	Run	<= 1'b1; Instruction	<= 9'b000001000;	//mv R1, R0
		#20	Run	<= 1'b0;
		#20	Run	<= 1'b1; Instruction	<= 9'b010000001; //add R0, R1
		#20	Run	<= 1'b0;
		#60	Run	<= 1'b1; Instruction	<= 9'b011000000; //sub R0, R0
		#60	Run	<= 1'b0;
		
		//testcase1
		#20	Run	<= 1'b1; Instruction	<= 9'b001010000; //mvi R2, #D
		#20	Run	<= 1'b0; Instruction	<= 9'b000000001;
		//testcase2
		#20	Run	<= 1'b1; Instruction	<= 9'b000011010; //mv R3, R2
		#20	Run	<= 1'b0; 
		//testcase3
		#20	Run	<= 1'b1; Instruction	<= 9'b001100000; //mvi R4, #D
		#20	Run	<= 1'b0; Instruction	<= 9'b000000111;
		//testcase4
		#60	Run	<= 1'b1; Instruction	<= 9'b010100011; //add R4, R3
		#60	Run	<= 1'b0;
		//testcase5
		#60	Run	<= 1'b1; Instruction	<= 9'b011100001; //sub R4, R1
		#60	Run	<= 1'b0;
		
		
	end // initial

	proc U1 (Instruction, Resetn, CLOCK_50, Run, Done, BusWires);

endmodule
