module ps2_handler(in, upKey, leftKey, downKey, rightKey);  

  input [7:0] in; 
  output upKey,leftKey,downKey,rightKey;  
  
    assign upKey = (in==8'h75); //up arrow 
    assign leftKey = (in==8'h6b); //left arrow 
    assign downKey = (in==8'h72); //down arrow 
    assign rightKey = (in==8'h74); //right arrow
	 
endmodule
