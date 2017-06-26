`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Hai Dang Hoang
// Engineer: Brendan Ball
// Email: danghai@pdx.edu
// Create Date: 10/26/2016 04:12:03 AM
// Design Name: 
// Module Name: Nexys4fpga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Nexys4fpga(
    ///////////////////////////////////////////////////////////////////////////
	// Port Declarations
	///////////////////////////////////////////////////////////////////////////
	// System Connections
	input			clk,           // 100 MHz clock from on-board oscillator
	output	[7:0]	JA,			   // JA Header
	input			btnCpuReset,   // Red pushbutton
	
	// On-Board Display Connections
	output			dp,           
	output	[6:0]	seg,           // Seven segment dis
	output	[7:0]	an,            // Seven segment display anode pins
	output	[15:0]	led,           // LED outputs
	
	// Buttons & Switches
	input			btnL, btnU,
					btnR, btnD,
					btnC, 
	input	[15:0]	sw,
	
	// VGA Display Connections
	output	[3:0]	vga_red,
	output	[3:0]	vga_green,
	output	[3:0]	vga_blue,
	output			vga_vsync,
					vga_hsync
);
	
	// parameter
	parameter SIMULATE = 0;
	localparam RESMOD  = 2;	// pixel multiplier
					
	///////////////////////////////////////////////////////////////////////////
	// Internal Signals
	///////////////////////////////////////////////////////////////////////////
	// IO <-> RojoBot connections
	wire	[7:0]	motctl;         // Motor Control
	wire	[7:0]	locx;           // Bot location X (column) coordinate
	wire	[7:0]	locy;           // Bot location Y (row) coordinate
	wire	[7:0]	botinfo;        // Bot orientation and movement (action)
	wire	[7:0]	sensors;        // Bot sensor values
	wire	[7:0]	lmdist;         // Left motor distance counter
	wire	[7:0]	rmdist;         // Right motor distance counter
	wire			upd_sysregs;    // Sysgnal toogles roughly every 50ms whether
	                                // the Bot output registers are updated or not
	
	// IO Interface <-> processor KCPSM6
	wire	[7:0]	port_id;
	wire	[7:0]	out_port;
	wire	[7:0]	in_port;
	wire			k_write_strobe;
	wire			write_strobe;
	wire			read_strobe;
	wire			interrupt;
	wire			interrupt_ack;
					
	// IO <-> Debounce connections
	wire	[5:0]	db_btns;
	wire	[15:0]	db_sw;
			
	// IO <-> 7-seg Connections
	wire	[4:0]	Dig[7:0];
	wire	[3:0]	DPHigh;
	wire	[3:0]	DPLow;
	
	// RoboCop <-> Code Store connections
	wire	[17:0]	instruction;
	wire	[11:0]	address;
	wire			bram_enable;
	
	// RoboCop <-> System connections
	wire			rdl;
	wire			kcpsm6_sleep;

	// Display related connections
	wire			clk_25MHz;
	wire			vidOn;	
	wire	[9:0]	pixCol;
	wire	[9:0]	pixRow;
	wire	[11:0]	botIcon;
	wire	[1:0]	worldPix;

	// System Level connections
	wire			sysreset;
	//wire			sysclk;

	wire [11:0] first_screen_out;     // 12-bit RGB data for displaying the first screen
	///////////////////////////////////////////////////////////////////////////
	// Global Assigns
	///////////////////////////////////////////////////////////////////////////

	assign sysreset = !db_btns[0];			// Reset is active low!
	assign kcpsm6_reset	= sysreset | rdl;
	assign kcpsm6_sleep = 1'b0;	
	assign JA[7:0] 	= {2'b0,clk,vga_vsync,vga_hsync,vidOn,clk_25MHz,1'b0};
	 
	///////////////////////////////////////////////////////////////////////////
	// Instantiate the debounce module
	///////////////////////////////////////////////////////////////////////////
	debounce #(
		.RESET_POLARITY_LOW(0),
		.SIMULATE(SIMULATE))
	DB (
		.clk(clk),	
		.pbtn_in({btnC, btnL, btnU, btnR, btnD, btnCpuReset}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);	
		
	///////////////////////////////////////////////////////////////////////////	
	// Instantiate the 7-segment, 8-digit display
	///////////////////////////////////////////////////////////////////////////
	sevensegment #(
		.RESET_POLARITY_LOW(0),
		.SIMULATE(SIMULATE))
		
	SSD (
		// inputs for control signals
		.d0(Dig[0]),
		.d1(Dig[1]),
 		.d2(Dig[2]),
		.d3(Dig[3]),
		.d4(Dig[4]),
		.d5(Dig[5]),
		.d6(Dig[6]),
		.d7(Dig[7]),
		.dp({DPHigh, DPLow}),
		.seg({dp,seg}),			
		.an(an),
		.clk(clk),
		.reset(sysreset),
		.digits_out() 
	);
	
	///////////////////////////////////////////////////////////////////////////
	// Instantiate the I/O controller
	///////////////////////////////////////////////////////////////////////////
	nexys4_bot_if #(
		/* module currently takes no parameters */)
	IO_Interface (
		// DEMO_CPU Interface
		.PortID			(port_id),		// Port address 			
		.DataIn			(out_port),		// Data	from Picoblaze to the I/O register					
		.DataOut		(in_port),		// Data from I/O register to Picoblaze
		.kWriteStrobe	(k_write_strobe),
		.WriteStrobe	(write_strobe),	 
		.ReadStrobe		(read_strobe),	
		.Interrupt		(interrupt),
		.InterruptAck	(interrupt_ack),		
		// bot interface
		.MotCtl			(motctl),		
		.LocX			(locx),			
		.LocY			(locy),			
		.BotInfo		(botinfo),		
		.Sensors		(sensors),		
		.LMDist			(lmdist),		
		.RMDist			(rmdist),		
		.BotInterrupt	(upd_sysregs),		
		// display interface
		.Dig0			(Dig[0]),		// out to 7-seg digits
		.Dig1			(Dig[1]),
		.Dig2			(Dig[2]),
		.Dig3			(Dig[3]),
		.Dig4			(Dig[4]),
		.Dig5			(Dig[5]),
		.Dig6			(Dig[6]),
		.Dig7			(Dig[7]),
		.DP_l			(DPLow),		// output to low-order decimal points on nexys4
		.DP_h			(DPHigh),		// output to high-order decimal points on nexus
		.LED			(led),			// output to switch LEDs on nexys4
		
		// switch & button interface
		.Button			(db_btns[4:1]),	// debounced buttons in from nexys4
										// Button[{left,up,right,down}]
		.Switch			(db_sw),		// debounced switches in from nexys4
		
		// System Interface
		.clk			(clk),
		.rst			(sysreset));
		
		
	///////////////////////////////////////////////////////////////////////////
	// Instantiate RojoBot
	///////////////////////////////////////////////////////////////////////////
	bot # (/* bot module has no parameters */)
	RojoBot_CPU (
		// Main CSRs
		.MotCtl_in		(motctl),		// Motor control input	
		.LocX_reg		(locx),			// X-coordinate of rojobot's location		
		.LocY_reg		(locy),			// Y-coordinate of rojobot's location
		.Sensors_reg	(sensors),		// Sensor readings
		.BotInfo_reg	(botinfo),		// Information about rojobot's activity
		.LMDist_reg		(lmdist),		// left motor distance register 
		.RMDist_reg		(rmdist),		// right motor distance register 
						
		// Interface to the video logic
		// RESMOD stretches the video b/c RojoBot World is only 128x128
		.vid_row		(pixRow >> RESMOD),		// video logic row address
		.vid_col		(pixCol >> RESMOD),		// video logic column address
		.vid_pixel_out	(worldPix),		        // pixel (location) value
		// System Interface
		.clk			(clk),		            // system clock
		.reset			(sysreset),	            // system reset
		.upd_sysregs	(upd_sysregs));	        
										       																											
	///////////////////////////////////////////////////////////////////////////
	// Instantiate RoboCop Line Follower
	///////////////////////////////////////////////////////////////////////////

	kcpsm6 #(
		.interrupt_vector		(12'h3FF),
		.scratch_pad_memory_size(64),
		.hwbuild				(8'h00))
	RoboCop_CPU (
		.address 		(address),
		.instruction 	(instruction),
		.bram_enable 	(bram_enable),
		.port_id 		(port_id),
		.write_strobe 	(write_strobe),
		.k_write_strobe (k_write_strobe),
		.out_port 		(out_port),
		.read_strobe 	(read_strobe),
		.in_port 		(in_port),
		.interrupt 		(interrupt),
		.interrupt_ack 	(interrupt_ack),
		.reset 			(kcpsm6_reset),
		.sleep			(kcpsm6_sleep),
		.clk 			(clk)); 
		
	
	///////////////////////////////////////////////////////////////////////////	
	// Instantiate Code Store
	///////////////////////////////////////////////////////////////////////////
	botInsts #(
		.C_FAMILY				("7S"),   	// Setting to '7S' since we are using a 7-series FPGA
		.C_RAM_SIZE_KWORDS		(2),     	// Program size '1', '2' or '4'
		.C_JTAG_LOADER_ENABLE	(1'b0))    	// Include JTAG Loader
	Code_Store (							
		.rdl 			(rdl),
		.enable 		(bram_enable),
		.address 		(address),
		.instruction 	(instruction),
		.clk 			(clk));
	

	///////////////////////////////////////////////////////////////////////////	
	// Instantiate Pixel Clock
	///////////////////////////////////////////////////////////////////////////
	clk_wiz_0	clk25 (
		.clk_in1		(clk),
		.clk_out1		(clk_25MHz),
		.reset			(sysreset));
	
		
	///////////////////////////////////////////////////////////////////////////	
	// Instantiate Colorizer
	///////////////////////////////////////////////////////////////////////////
	Colorizer #(/* mod takes no parameters */)
	colorizer (
		.clk			(clk),
		.world		(worldPix),
		.botIcon		(botIcon),
		.video_on	(vidOn),
		.firstscreen (first_screen_out),
		.drawIcon		({vga_red,vga_green,vga_blue}));
	
	
	///////////////////////////////////////////////////////////////////////////	
	// Instantiate DTG
	///////////////////////////////////////////////////////////////////////////
	dtg #(/* Keeping parameter Defaults */)
	dtg (
		.clock			(clk_25MHz),
		.rst			(sysreset),
		.horiz_sync		(vga_hsync),
		.vert_sync		(vga_vsync),
		.video_on		(vidOn),
		.pixel_row		(pixRow), 
		.pixel_column	(pixCol));


	///////////////////////////////////////////////////////////////////////////	
	// Instantiate Icon module (it instantiates the Icon ROM)
	///////////////////////////////////////////////////////////////////////////
	icon #(/* module takes no parameters */)  
	icon (
		.clk		(clk),
		.pixCol		(pixCol),
		.pixRow		(pixRow),
		.locX		({locx, {RESMOD{1'b0}}}),
		.locY		({locy, {RESMOD{1'b0}}}),
		.botInfo	(botinfo),
		.botIcon	(botIcon));
		
	/*	
    //////////////////////////////////////////////////
    // Background screen
    //////////////////////////////////////////////////
   
    first_screen first(
    .first_screen_out(first_screen_out),
    .pPixel_row(pixRow),
    .pPixel_column(pixCol),
    .clk_1(clk),
    .clk_2(clk_25MHz),
    .pReset(sysreset)  
    );   */
endmodule