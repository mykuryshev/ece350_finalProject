module ps2_handler(in, upKey, leftKey, downKey, rightKey, oneKey, 
			twoKey, threeKey, fourKey, fiveKey, tKey, wKey, aKey, 
			sKey, dKey, rKey, pKey);  

  input [7:0] in; 
  output upKey, leftKey, downKey, rightKey, oneKey, twoKey, threeKey, 
			fourKey, fiveKey, tKey, wKey, aKey, sKey, dKey, rKey, 
			pKey;  
  
    assign upKey = (in==8'h75); //up arrow 
    assign leftKey = (in==8'h6b); //left arrow 
    assign downKey = (in==8'h72); //down arrow 
    assign rightKey = (in==8'h74); //right arrow
	 assign oneKey = (in==8'h16); 
	 assign twoKey = (in==8'h1e); 
	 assign threeKey = (in==8'h26); 
	 assign fourKey = (in==8'h25); 
	 assign fiveKey = (in==8'h2e); 
	 assign tKey = (in==8'h2c); 
	 assign wKey = (in==8'h1d);
	 assign aKey = (in==8'h1c); 
	 assign sKey = (in==8'h1b); 
	 assign dKey = (in==8'h23); 
	 assign rKey = (in==8'h2d); 
	 assign pKey = (in==8'h4d);  
endmodule
