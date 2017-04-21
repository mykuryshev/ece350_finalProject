module timer(clock, reset, out);

input clock, reset;
output reg out;


reg[3:0] count;


always@(posedge clock, posedge reset)
begin
  
  if (reset)
     count = 4'd0;
  else
	  count = count + 1;
	  
end

always@(posedge count)
begin

	if(count < 4'd3)
		out = 1'b1;
	else
		out = 1'b0;
	
end

endmodule
