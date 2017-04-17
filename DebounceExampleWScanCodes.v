//not an operational processor module, just an example from Piazza of debouncing with scan codes for a few keys 
// keyboard controller
PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
 	wire [7:0] debounced_ps2;
 	ps2_fsm my_ps2_fsm(ps2_key_pressed, clock, ~resetn, ps2_key_data, debounced_ps2);
 
 // can use debounced_ps2 here
 // will need to handle at least 4 arrow keys, maybe r for reset

 //SCAN CODES, still need to go in and observe FPGA out values on input
 //           MAKE   BREAK
 //U arrow -- E0,75; E0,F0,75
 //L arrow -- E0,6B; E0,F0,6B
 //D arrow -- E0,72; E0,F0,72
 //R arrow -- E0,74; E0,F0,74
 //Enter   --    5A;    F0,5A
 //R (reset)-    2D;    F0,2D
 //1       --    16;    F0,16
 //2       --    1E;    F0,1E
 //3       --    26;    F0,26
 //4       --    25;    F0,25
endmodule

module ps2_fsm(key_pressed, clock, reset, in, out);
	input key_pressed, clock, reset;
	input [7:0] in;
	output [7:0] out;
	reg [7:0] out;
	reg [31:0] counter;
	reg afterF;

always @ (posedge clock) begin
	if (reset) begin
 		out = 8'b0;
		counter = 32'b0;
 		afterF = 1'b0;
 	end
 	else if (counter == 1200000) begin
 		counter = 32'b0;
 		out = 8'b0;
 	end
 	else if (in == 8'b11110000) begin
 		afterF = 1'b1;
 	end
 	else if (afterF) begin
 		counter = 32'b0;
 		out = in;
 		afterF = 1'b0;
 	end
 	else begin
 		counter = counter + 1;
 	end
 end
endmodule
