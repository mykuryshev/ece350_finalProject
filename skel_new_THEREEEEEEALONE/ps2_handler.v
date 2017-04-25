module ps2_handler(in, hKey, jKey, kKey, lKey, oneKey, 
			twoKey, threeKey, fourKey, fiveKey, tKey, aKey, sKey, 
			dKey, fKey, rKey, pKey);  

  input [7:0] in; 
  output hKey, jKey, kKey, lKey, oneKey, twoKey, threeKey, 
			fourKey, fiveKey, tKey, aKey, sKey, dKey, fKey, rKey, 
			pKey;  
  
    assign hKey = (in==8'h33); 
    assign jKey = (in==8'h3b); 
    assign kKey = (in==8'h42);  
    assign lKey = (in==8'h4b); 
	 assign oneKey = (in==8'h16); 
	 assign twoKey = (in==8'h1e); 
	 assign threeKey = (in==8'h26); 
	 assign fourKey = (in==8'h25); 
	 assign fiveKey = (in==8'h2e); 
	 assign tKey = (in==8'h2c); 
	 assign fKey = (in==8'h2b);
	 assign aKey = (in==8'h1c); 
	 assign sKey = (in==8'h1b); 
	 assign dKey = (in==8'h23); 
	 assign rKey = (in==8'h2d); 
	 assign pKey = (in==8'h4d);  
endmodule

//h = 33
//j = 3b
//k = 42
//l = 4b
//f = 2b

//asdf to register 30
//hjkl to register 28