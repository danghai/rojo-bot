`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Hai Dang Hoang
// Engineer: Brendan Ball
// Email: danghai@pdx.edu
// Create Date: 10/26/2016 04:22:51 AM
// Design Name: 
// Module Name: nexys4_bot_if
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

// Description
// This module implements a register-based interface to the Nexys 4
// It is connected to a PicoBlaze which accesses the registers throush
// INPUT and OUTPUT instructions. The module also includes the interrupt
// flip-flop used to control the PicoBlaze interrupt mechanisms.

module nexys4_bot_if(
// system interface
	input			clk,
	input			rst,			

// pico blaze interface	
	input		[7:0]	PortID,		    // I/O port address				
	input		[7:0]	DataIn,			// Data from PicoBlaze to be written to I/O Register				    
	output	reg	[7:0]	DataOut,		// Data from I/O register to PicoBlaze				
	
	input				kWriteStrobe,	
	input				WriteStrobe,	
	input				ReadStrobe,
	
	output	reg			Interrupt,      // Interrupt request to PicoBlaze
	input				InterruptAck,   // Interrupt acknowledge from PicoBlaze
	
// bot interface
	output	reg	[7:0]	MotCtl,			// Motor control input    
	input		[7:0]	LocX,			// X-coordinate of rojobot's location   
	input 		[7:0]	LocY,			// Y-coordinate of rojobot's location
	input		[7:0]	BotInfo,		// Information about rojobot's activity
	input		[7:0]	Sensors,		// Sensor readings
	input		[7:0]	LMDist,			// left motor distance register 
	input		[7:0]	RMDist,			// right motor distance register
	
	input	     BotInterrupt,	        // interrupt from RojoBot 
	
// display interface
	output	reg	[4:0]	Dig0,			// out to 7-seg digits
	output	reg	[4:0]	Dig1,
	output	reg	[4:0]	Dig2,
	output	reg	[4:0]	Dig3,
	output	reg	[4:0]	Dig4,
	output	reg	[4:0]	Dig5,
	output	reg	[4:0]	Dig6,
	output	reg	[4:0]	Dig7,
	output	reg	[3:0]	DP_l,			
	output	reg	[3:0]	DP_h,			
	output	reg	[15:0]	LED,			
	
// switch and button interface
	input		[3:0]	Button,			// Debounced buttons 										
	input		[15:0]	Switch			// Debounced switches 
);

///////////////////////////////////////////////////////////////////////////////////////
// Parameter for Port Addresses
///////////////////////////////////////////////////////////////////////////////////////
parameter
    PA_PBTNS		= 8'h0,		// (i) pushbuttons inputs
	PA_SLSWTCH		= 8'h1,		// (i) slide switches
	PA_LEDS			= 8'h2,		// (o) LEDs
	PA_DIG3			= 8'h3,		// (o) digit 3 port address
	PA_DIG2			= 8'h4,		// (o) digit 2 port address
	PA_DIG1			= 8'h5,		// (o) digit 1 port address
	PA_DIG0			= 8'h6,		// (o) digit 0 port address
	PA_DP			= 8'h7,		// (o) decimal points 3:0 port address
	PA_RSVD			= 8'h8;		// (o) *RESERVED* port address


// Rojobot interface registers
parameter
	PA_MOTCTL_IN	= 8'h09,	// (o) Rojobot motor control
	PA_LOCX			= 8'h0A,	// (i) X coordinate of rojobot location
	PA_LOCY			= 8'h0B,	// (i) Y coordinate of rojobot location
	PA_BOTINFO		= 8'h0C,	// (i) Rojobot information register
	PA_SENSORS		= 8'h0D,	// (i) Sensor register
	PA_LMDIST		= 8'h0E,	// (i) Rojobot left motor distance register
	PA_RMDIST		= 8'h0F;	// (i) Rojobot right motor distance register

// Extended I/O interface port addresses for LED, switches, button and 7-segment
parameter 
	PA_PBTNS_ALT	= 8'h10,	// (i) pushbutton inputs alternate port address
	PA_SLSWTCH1508	= 8'h11,	// (i) slide switches 15:8 (high byte of switches
	PA_LEDS1508		= 8'h12,	// (o) LEDs 15:8 (high byte of switches)
	PA_DIG7			= 8'h13,	// (o) digit 7 port address
	PA_DIG6			= 8'h14,	// (o) digit 6 port address
	PA_DIG5			= 8'h15,	// (o) digit 5 port address
	PA_DIG4			= 8'h16,	// (o) digit 4 port address
	PA_DP0704		= 8'h17,	// (o) decimal points 7:4 port address
	PA_RSVD_ALT		= 8'h18;	// (o) *RESERVED* alternate port address
   
    initial begin 
        DP_h <= 4'd0;
        
    end
    
///////////////////////////////////////////////////////////////////////////////////////
// General Purpose Input Ports
///////////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk) begin
		case (PortID)
			PA_LOCX:		DataOut <= LocX;			
			PA_LOCY:		DataOut <= LocY;
			PA_BOTINFO:		DataOut <= BotInfo;			
			PA_SENSORS:		DataOut <= Sensors;			
			PA_LMDIST:		DataOut <= LMDist;			
			PA_RMDIST:		DataOut <= RMDist;			
			PA_PBTNS:		DataOut <= {Button};
			PA_PBTNS_ALT:	DataOut <= {Button};
			PA_SLSWTCH:		DataOut <= Switch[15:8];	
			PA_SLSWTCH1508:	DataOut <= Switch[7:0];		
			default:		DataOut <= 8'bx;
		endcase
	end
	
///////////////////////////////////////////////////////////////////////////////////////
// General Purpose Output Ports
// Poutput ports must capture the value presented on the 'out_port' based on the value of 'port_id' 
// when 'WriteStrobe' is High
///////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk ) begin

		if (WriteStrobe) begin
			case(PortID)
				PA_DIG7:	Dig7  <= DataIn;
				PA_DIG6:	Dig6  <= DataIn;
				PA_DIG5:	Dig5  <= DataIn;
				PA_DIG4:	Dig4  <= DataIn;
				PA_DIG3:	Dig3  <= DataIn;
				PA_DIG2:	Dig2  <= DataIn;
				PA_DIG1:	Dig1  <= DataIn;
				PA_DIG0:	Dig0  <= DataIn;
				PA_DP:		DP_l  <= DataIn;
				PA_DP0704:	DP_h  <= DataIn;
				PA_LEDS:	 LED[7:0]  <= DataIn;
				PA_LEDS1508: LED[15:8] <= DataIn;
				PA_MOTCTL_IN:	  MotCtl[7:0] <= DataIn;
			endcase
		end
	end 
		
	// Interrupt becomes active when 'int_request' is observed and then remains active until acknowledged by KCPSM6
	always @(posedge clk) begin
		if (InterruptAck)
			Interrupt <= 1'b0;
		else if (BotInterrupt)
			Interrupt <= 1'b1;
		else
			Interrupt <= Interrupt;
	end

endmodule
