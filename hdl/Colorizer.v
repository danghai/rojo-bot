`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer:  Hai Dang Hoang 
// Email: danghai@pdx.edu
// Create Date: 10/25/2016 11:46:05 AM
// Design Name: 
// Module Name: Colorizer
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


module Colorizer(
        input clk,
        input [1:0] world,
        input [11:0] botIcon,
        input video_on,
        input [11:0] firstscreen,
        output reg [11:0] drawIcon
    );
    // parameter for color ( BLACK, RED, GREEN, BLUE)
    parameter 
        BLACK = 12'b000000000000,
        WHITE = 12'b111111111111,
        GREEN = 12'b000011110000,
        RED   = 12'b111100000000,
        BLUE  = 12'b000000001111;
        
     always @(posedge clk) begin
        if (~video_on)
            drawIcon <= BLACK;          // Colorizer output 000 ( Black) when video is off
        else if (botIcon)              // Else, draw the Icon from input
            drawIcon <= botIcon; 
    //    else if (firstscreen)          // draw first screen
    //        drawIcon <= firstscreen;
        else begin
            case (world)
                2'b00: drawIcon    <= WHITE;    // Background
                2'b01: drawIcon    <= BLACK;    // Black Line
                2'b10: drawIcon    <= RED;    // Obstruction
                2'b11: drawIcon    <= GREEN;      // Reserved
        endcase
     end  
     end
endmodule