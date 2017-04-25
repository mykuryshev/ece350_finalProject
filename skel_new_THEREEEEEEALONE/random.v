module random(clock, reset, data, small_data);

input clock, reset;
output reg[31:0] data;
output[2:0] small_data;
reg [31:0] data_next;

assign small_data = 1+ data%4;

always@(*) begin
  data_next[4] = data[4]^data[1];
  data_next[3] = data[3]^data[0];
  data_next[2] = data[2]^data_next[4];
  data_next[1] = data[1]^data_next[3];
  data_next[0] = data[0]^data_next[2];
end

always @(posedge clock, posedge reset)
  if(reset)
    data <= 5'h1f;
  else
    data <= data_next;

endmodule
