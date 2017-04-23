module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, dmem_out,				// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50);  													// 50 MHz clock
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in, dmem_out;
	output   [11:0]   debug_addr;
	
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
	
	// clock divider (by 5, i.e., 10 MHz)
	pll2 div(CLOCK_50,inclock);
	//assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	assign clock = inclock;
	
	
	wire[18:0] vga_address;
	wire[7:0] vga_index;
	
	wire[7:0] debounced_ps2;
	wire ps2_indicator;
	wire[7:0] key_reg_data;
	wire[31:0] reg29_data;
	
	CP4_processor_sj166 myprocessor(.clock(clock), .reset(~resetn), 
												.dmem_data_in(debug_data_in), .dmem_address(debug_addr), .vga_address(vga_address), 
												.vga_out(vga_index), .vga_clock(VGA_CLK), .key_press_ind(ps2_indicator), .key_press_data(debounced_ps2), 
												.reg28_data(key_reg_data), .reg29_data(reg29_data));
	
	
	// keyboard controller: Interfaces with PS2 at a low level
	PS2_Interface myps2(.inclock(clock), .resetn(resetn), 
							  .ps2_clock(ps2_clock), .ps2_data(ps2_data),
							  .ps2_key_data(ps2_key_data), .ps2_key_pressed(ps2_key_pressed), .last_data_received(ps2_out));
	 
	//Debouncing FSM: Processes ps2 output into a debounced signal
	ps2_fsm fsm(ps2_key_pressed, clock, ~resetn, ps2_key_data, debounced_ps2);
	
	//Handler: Processes debounced PS2 into indicator signals for the 4 keys that we're interested in
	wire upKey, leftKey, downKey, rightKey;
	assign ps2_indicator = upKey || leftKey || downKey || rightKey;

	ps2_handler handleps2(debounced_ps2, upKey, leftKey, downKey, rightKey);
	
	
	//lcd mylcd(clock, ~resetn, 1'b1, ps2_out, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	//These 2 are hardwired to register 28
	Hexadecimal_To_Seven_Segment hex1(key_reg_data[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(key_reg_data[7:4], seg2);
	
	//These are hardwired to the ps2 scan code
	Hexadecimal_To_Seven_Segment hex3(ps2_out[3:0], seg3);
	Hexadecimal_To_Seven_Segment hex4(ps2_out[7:4], seg4);
	
	//Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	//These 2 are harwired to register 29
	Hexadecimal_To_Seven_Segment hex6(reg29_data[3:0], seg6);
	Hexadecimal_To_Seven_Segment hex7(reg29_data[7:4], seg7);
	
	//Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted  for project
	assign leds = vga_index;
		
	// VGA  for project
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	vga_controller vga_ins(.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R), 
								 .address(vga_address), 
								 .index(vga_index));
	
	
endmodule
