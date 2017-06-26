`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// filename:	icon.v
//
// ECE 540 Project 2: RojoBot World

// Name: Hai Dang Hoang
// Name: Brendan Ball
// ECE 540 
//////////////////////////////////////////////////////////////////////////////////
module icon (
  
  ///////////////////////////////////////////////////////////////////////////
  // Port Declarations
  ///////////////////////////////////////////////////////////////////////////
  input					clk,
  input			[9:0]	pixCol,			// Top side
  input			[9:0]	pixRow,         // Left side
  input			[9:0]	locX,			// x location
  input			[9:0]	locY,			// y location
  input			[7:0]	botInfo,        // Bot information for direction
  output	reg	[11:0]	botIcon			// 12-bit rgb color
);

parameter 

  ///////////////////////////////////////////////////////////////////////////
  // Parameter for tank color
  ///////////////////////////////////////////////////////////////////////////
   TR      = 12'h000,       //Transparent pixel
   BL      = 12'h008,       // Blue pixel
   YE      = 12'hFC4,       // Yellow
   RE      = 12'h800;      // RED

  ///////////////////////////////////////////////////////////////////////////
  // Parameter for direction
  ///////////////////////////////////////////////////////////////////////////
  localparam N  = 3'b000;				// Encoding for Compass heading
  localparam S  = 3'b100;				// N-S-E-W-NE-SW-SE-NW
  localparam E  = 3'b010;
  localparam W  = 3'b110;
  localparam NE = 3'b001;
  localparam SW = 3'b101;
  localparam SE = 3'b011;
  localparam NW = 3'b111;

  
  ///////////////////////////////////////////////////////////////////////////
  // Internal Signals
  ///////////////////////////////////////////////////////////////////////////
  reg	[3:0]	iconBit_X, iconBit_Y;	// index into icon pixelmap 
  wire	[9:0]	iconLeft;					// Bounds of the icon 
  wire	[9:0]	iconRight;
  wire	[9:0]	iconTop;
  wire	[9:0]	iconBottom;
  
  wire	[11:0]	pixelColor;					// Color out from ROM

  reg [11:0] icon_array[512:0];             // Array for icon
  
  // These are the icon index transforms that need done in order to use
  // 2 Icons for the eight ordinal directions in which the bot can be headed
  wire	[8:0]	x_Direction_N  = {1'b0, 		iconBit_Y,		iconBit_X }; 
  wire	[8:0]	x_Direction_S  = {1'b0, 4'd15-	iconBit_Y, 4'd15-	iconBit_X }; 
  wire	[8:0]	x_Direction_E  = {1'b0, 4'd15-	iconBit_X, 		iconBit_Y }; 
  wire	[8:0]	x_Direction_W  = {1'b0, 		iconBit_X, 4'd15-	iconBit_Y }; 
  wire	[8:0]	x_Direction_NE = {1'b1, 		iconBit_Y, 		iconBit_X };
  wire	[8:0]	x_Direction_SW = {1'b1, 4'd15-	iconBit_Y, 4'd15-	iconBit_X };
  wire	[8:0]	x_Direction_SE = {1'b1, 4'd15-	iconBit_X, 		iconBit_Y };
  wire	[8:0]	x_Direction_NW = {1'b1, 		iconBit_X, 4'd15-	iconBit_Y };
  
  
  
  ///////////////////////////////////////////////////////////////////////////
  // Global Assigns ( ICON Location Index)
  /////////////////////////////////////////////////////////////////////////// 
  assign iconLeft = locX-12'd7;
  assign iconRight  = locX + 12'd7;
  assign iconBottom = locY+12'd7;
  assign iconTop = locY-12'd7;
  

  
  // Set index into icon
  always @ (posedge clk) begin
	iconBit_X <= pixCol[3:0] - iconLeft[3:0];
	iconBit_Y <= pixRow[3:0] -  iconTop[3:0];
  end
  
 
  // Decide when to paint the botIcon
  // If the cathode ray gun overlaps the adjusted bot location,
  // paint the icon, otherwise paint "00" (transparency)

  always @ (posedge clk) begin
	if (pixCol >= iconLeft && pixCol <= iconRight &&
		pixRow >= iconTop  && pixRow <= iconBottom) begin
		
		case (botInfo[2:0])
			N :	botIcon <= icon_array[x_Direction_N];
			S :	botIcon <= icon_array[x_Direction_S];
			E :	botIcon <= icon_array[x_Direction_E];
			W :	botIcon <= icon_array[x_Direction_W];
			NE:	botIcon <= icon_array[x_Direction_NE];
			NW:	botIcon <= icon_array[x_Direction_NW];
			SE:	botIcon <= icon_array[x_Direction_SE];
			SW:	botIcon <= icon_array[x_Direction_SW];
			default: botIcon <= 12'b0;
		endcase	
	end
	else begin
		botIcon    <= 12'b0;				// transparent 
	end
  end
	  
  initial begin
     /**********************************************
    *****  Template file for the image array
    ***********************************************/
    icon_array[0]=TR;     //tank icon angle  90 
    icon_array[1]=TR;
    icon_array[2]=TR ;
    icon_array[3]=TR ;
    icon_array[4]=TR ;
    icon_array[5]=TR ;
    icon_array[6]=BL ;
    icon_array[7]=BL ;
    icon_array[8]=BL ;
    icon_array[9]=BL ;
    icon_array[10]=TR ;
    icon_array[11]=TR ;
    icon_array[12]=TR ;
    icon_array[13]=TR ;
    icon_array[14]=TR ;
    icon_array[15]=TR ;   //updated
    icon_array[16]=TR; // 1st pixel Row 1
    icon_array[17]=TR ;
    icon_array[18]=TR ;
    icon_array[19]=TR ;
    icon_array[20]=TR ;
    icon_array[21]=TR ;
    icon_array[22]=BL ;
    icon_array[23]=RE ;
    icon_array[24]=RE ;
    icon_array[25]=BL ;
    icon_array[26]=TR ;
    icon_array[27]=TR ;
    icon_array[28]=TR ;
    icon_array[29]=TR ;
    icon_array[30]=TR ;
    icon_array[31]=TR ;  //updated
    icon_array[32]=TR ;
    icon_array[33]=TR ;
    icon_array[34]=TR ;
    icon_array[35]=TR ;
    icon_array[36]=TR ;
    icon_array[37]=TR ;
    icon_array[38]=BL ;
    icon_array[39]=RE ;
    icon_array[40]=RE ;
    icon_array[41]=BL ;
    icon_array[42]=TR ;
    icon_array[43]=TR ;
    icon_array[44]=TR ;
    icon_array[45]=TR ;
    icon_array[46]=TR ;
    icon_array[47]=TR ;   //updated
    icon_array[48]=BL ;
    icon_array[49]=BL ;
    icon_array[50]=BL ;
    icon_array[51]=BL ;
    icon_array[52]=BL ;
    icon_array[53]=BL ;
    icon_array[54]=BL ;
    icon_array[55]=RE ;
    icon_array[56]=RE ;
    icon_array[57]=BL ;
    icon_array[58]=BL ;
    icon_array[59]=BL ;
    icon_array[60]=BL ;
    icon_array[61]=BL ;
    icon_array[62]=BL ;
    icon_array[63]=TR ;   //updated
    icon_array[64]=BL ;
    icon_array[65]=RE ;
    icon_array[66]=RE ;
    icon_array[67]=RE ;
    icon_array[68]=RE ;
    icon_array[69]=RE ;
    icon_array[70]=BL ;
    icon_array[71]=RE ;
    icon_array[72]=RE ;
    icon_array[73]=BL ;
    icon_array[74]=RE ;
    icon_array[75]=RE ;
    icon_array[76]=RE ;
    icon_array[77]=RE ;
    icon_array[78]=RE ;
    icon_array[79]=BL ;
    icon_array[80]=BL ;
    icon_array[81]=RE ;
    icon_array[82]=BL ;
    icon_array[83]=BL ;
    icon_array[84]=BL ;
    icon_array[85]=BL ;
    icon_array[86]=BL ;
    icon_array[87]=RE ;
    icon_array[88]=RE ;
    icon_array[89]=BL ;
    icon_array[90]=BL ;
    icon_array[91]=BL ;
    icon_array[92]=BL ;
    icon_array[93]=BL ;
    icon_array[94]=RE ;
    icon_array[95]=BL ;
    icon_array[96]=BL ;
    icon_array[97]=RE ;
    icon_array[98]=BL ;
    icon_array[99]=RE ;
    icon_array[100]=RE ;
    icon_array[101]=RE ;
    icon_array[102]=BL ;
    icon_array[103]=RE ;
    icon_array[104]=RE ;
    icon_array[105]=BL ;
    icon_array[106]=RE ;
    icon_array[107]=RE ;
    icon_array[108]=RE ;
    icon_array[109]=BL ;
    icon_array[110]=RE ;
    icon_array[111]=BL ;
    icon_array[112]=BL;
    icon_array[113]=RE ;
    icon_array[114]=BL ;
    icon_array[115]=RE ;
    icon_array[116]=RE ;
    icon_array[117]=RE ;
    icon_array[118]=BL ;
    icon_array[119]=BL ;
    icon_array[120]=BL ;
    icon_array[121]=BL ;
    icon_array[122]=RE ;
    icon_array[123]=RE ;
    icon_array[124]=RE ;
    icon_array[125]=BL ;
    icon_array[126]=RE ;
    icon_array[127]=BL ;
    icon_array[128]=BL ;
    icon_array[129]=RE ;
    icon_array[130]=BL ;
    icon_array[131]=RE ;
    icon_array[132]=RE ;
    icon_array[133]=RE ;
    icon_array[134]=RE ;
    icon_array[135]=RE ;
    icon_array[136]=RE ;
    icon_array[137]=RE ;
    icon_array[138]=RE ;
    icon_array[139]=RE ;
    icon_array[140]=RE ;
    icon_array[141]=BL ;
    icon_array[142]=RE ;
    icon_array[143]=BL ;
    icon_array[144]=BL ;
    icon_array[145]=RE ;
    icon_array[146]=BL ;
    icon_array[147]=RE ;
    icon_array[148]=RE ;
    icon_array[149]=RE ;
    icon_array[150]=RE ;
    icon_array[151]=RE ;
    icon_array[152]=RE ;
    icon_array[153]=RE ;
    icon_array[154]=RE ;
    icon_array[155]=RE ;
    icon_array[156]=RE ;
    icon_array[157]=BL ;
    icon_array[158]=RE ;
    icon_array[159]=BL ;
    icon_array[160]=BL ;   //row 10
    icon_array[161]=RE ;
    icon_array[162]=BL ;
    icon_array[163]=RE ;
    icon_array[164]=RE ;
    icon_array[165]=RE ;
    icon_array[166]=BL ;
    icon_array[167]=BL ;
    icon_array[168]=BL ;
    icon_array[169]=BL ;
    icon_array[170]=RE ;
    icon_array[171]=RE ;
    icon_array[172]=RE ;
    icon_array[173]=BL ;
    icon_array[174]=RE ;
    icon_array[175]=BL ;
    icon_array[176]=BL ;   //row 11
    icon_array[177]=RE ;
    icon_array[178]=BL ;
    icon_array[179]=RE ;
    icon_array[180]=RE ;
    icon_array[181]=RE ;
    icon_array[182]=BL ;
    icon_array[183]=RE ;
    icon_array[184]=RE ;
    icon_array[185]=BL ;
    icon_array[186]=RE ;
    icon_array[187]=RE ;
    icon_array[188]=RE ;
    icon_array[189]=BL ;
    icon_array[190]=RE ;
    icon_array[191]=BL ;
    icon_array[192]=BL ;        // row 12
    icon_array[193]=RE ;
    icon_array[194]=BL ;
    icon_array[195]=BL ;
    icon_array[196]=BL ;
    icon_array[197]=BL ;
    icon_array[198]=BL ;
    icon_array[199]=RE ;
    icon_array[200]=RE ;
    icon_array[201]=BL ;
    icon_array[202]=BL ;
    icon_array[203]=BL ;
    icon_array[204]=BL ;
    icon_array[205]=BL ;
    icon_array[206]=RE ;
    icon_array[207]=BL ;
    icon_array[208]=BL ;
    icon_array[209]=RE ;
    icon_array[210]=RE ;
    icon_array[211]=RE ;
    icon_array[212]=RE ;
    icon_array[213]=RE ;
    icon_array[214]=RE ;
    icon_array[215]=RE ;
    icon_array[216]=RE ;
    icon_array[217]=RE ;
    icon_array[218]=RE ;
    icon_array[219]=RE ;
    icon_array[220]=RE ;
    icon_array[221]=RE ;
    icon_array[222]=RE ;
    icon_array[223]=BL ;
    icon_array[224]=BL ;
    icon_array[225]=RE ;
    icon_array[226]=RE ;
    icon_array[227]=RE ;
    icon_array[228]=RE ;
    icon_array[229]=RE ;
    icon_array[230]=RE ;
    icon_array[231]=RE ;
    icon_array[232]=RE ;
    icon_array[233]=RE ;
    icon_array[234]=RE ;
    icon_array[235]=RE ;
    icon_array[236]=RE ;
    icon_array[237]=RE ;
    icon_array[238]=RE ;
    icon_array[239]=BL ;
    icon_array[240]=BL ;
    icon_array[241]=BL ;
    icon_array[242]=BL ;
    icon_array[243]=BL ;
    icon_array[244]=BL ;
    icon_array[245]=BL ;
    icon_array[246]=BL ;
    icon_array[247]=BL ;
    icon_array[248]=BL ;
    icon_array[249]=BL ;
    icon_array[250]=BL ;
    icon_array[251]=BL ;
    icon_array[251]=BL ;
    icon_array[253]=BL ;
    icon_array[254]=BL ;
    icon_array[255]=BL;

/// 45 Degree
   icon_array[271]=TR ;
   icon_array[270]=BL ;
   icon_array[269]=TR ;
   icon_array[268]=TR ;
   icon_array[267]=TR ;
   icon_array[266]=TR ;
   icon_array[265]=TR ;
   icon_array[264]=TR ;
   icon_array[263]=TR ;
   icon_array[262]=TR ;
   icon_array[261]=TR ;
   icon_array[260]=TR ;
   icon_array[259]=TR ;
   icon_array[258]=TR ;
   icon_array[257]=TR ;
   icon_array[256]=TR ;
   
   icon_array[287]=BL ;
   icon_array[286]=RE ;
   icon_array[285]=BL ;
   icon_array[284]=TR ;
   icon_array[283]=TR ;
   icon_array[282]=TR ;
   icon_array[281]=TR ;
   icon_array[280]=BL ;
   icon_array[279]=BL ;
   icon_array[278]=TR ;
   icon_array[277]=TR ;
   icon_array[276]=TR ;
   icon_array[275]=TR ;
   icon_array[274]=TR ;
   icon_array[273]=TR ;
   icon_array[272]=TR ;
   
   icon_array[303]=TR ;
   icon_array[302]=BL ;
   icon_array[301]=RE ;
   icon_array[300]=BL ;
   icon_array[299]=TR ;
   icon_array[298]=TR ;
   icon_array[297]=BL ;
   icon_array[296]=RE ;
   icon_array[295]=RE ;
   icon_array[294]=BL ;
   icon_array[293]=TR ;
   icon_array[292]=TR ;
   icon_array[291]=TR ;
   icon_array[290]=TR ;
   icon_array[289]=TR ;
   icon_array[288]=TR ;
   
   icon_array[319]=BL ;     //row 3
   icon_array[318]=BL ;
   icon_array[317]=BL ;
   icon_array[316]=RE ;
   icon_array[315]=BL ;
   icon_array[314]=BL ;
   icon_array[313]=RE ;
   icon_array[312]=RE ;
   icon_array[311]=RE ;
   icon_array[310]=RE ;
   icon_array[309]=BL ;
   icon_array[308]=BL ;
   icon_array[307]=BL ;
   icon_array[306]=BL ;
   icon_array[305]=BL ;
   icon_array[304]=TR ;    // updated
   
   icon_array[335]=BL ;     //row 4
   icon_array[334]=RE ;
   icon_array[333]=RE ;
   icon_array[332]=BL ;
   icon_array[331]=RE ;
   icon_array[330]=BL ;
   icon_array[329]=RE ;
   icon_array[328]=RE ;
   icon_array[327]=RE ;
   icon_array[326]=RE ;
   icon_array[325]=RE ;
   icon_array[324]=BL ;
   icon_array[323]=RE ;
   icon_array[322]=RE ;
   icon_array[321]=RE ;
   icon_array[320]=BL ;
   
   icon_array[350]=BL ;        //row 5
   icon_array[349]=RE ;
   icon_array[348]=RE ;
   icon_array[347]=BL ;
   icon_array[346]=BL ;
   icon_array[345]=RE ;
   icon_array[344]=BL ;
   icon_array[343]=RE ;
   icon_array[342]=RE ;
   icon_array[341]=RE ;
   icon_array[340]=RE ;
   icon_array[339]=RE ;
   icon_array[338]=BL ;
   icon_array[337]=RE ;
   icon_array[336]=RE ;
   icon_array[335]=BL ;
   
   icon_array[366]=BL ;     //row 6
   icon_array[365]=RE ;
   icon_array[364]=BL ;
   icon_array[363]=RE ;
   icon_array[362]=RE ;
   icon_array[361]=BL ;
   icon_array[360]=RE ;
   icon_array[359]=BL ;
   icon_array[358]=BL ;
   icon_array[357]=RE ;
   icon_array[356]=RE ;
   icon_array[355]=RE ;
   icon_array[354]=RE ;
   icon_array[353]=BL ;
   icon_array[352]=RE ;
   icon_array[351]=BL ;
   
   icon_array[382]=BL ;      //row 7
   icon_array[381]=BL ;
   icon_array[380]=RE ;
   icon_array[379]=RE ;
   icon_array[378]=RE ;
   icon_array[377]=RE ;
   icon_array[376]=BL ;
   icon_array[375]=RE ;
   icon_array[374]=RE ;
   icon_array[373]=RE ;
   icon_array[372]=RE ;
   icon_array[371]=RE ;
   icon_array[370]=BL ;
   icon_array[369]=RE ;
   icon_array[368]=RE ;
   icon_array[367]=BL ;
   
   icon_array[398]=BL ;       //row 8
   icon_array[397]=BL ;
   icon_array[396]=RE ;
   icon_array[395]=RE ;
   icon_array[394]=RE ;
   icon_array[393]=RE ;
   icon_array[392]=BL ;
   icon_array[391]=RE ;
   icon_array[390]=RE ;
   icon_array[389]=BL ;
   icon_array[388]=BL ;
   icon_array[387]=BL ;
   icon_array[386]=RE ;
   icon_array[385]=RE ;
   icon_array[384]=RE ;
   icon_array[383]=BL ;
   
   icon_array[414]=BL ;             //row 9
   icon_array[413]=RE ;
   icon_array[412]=BL ;
   icon_array[411]=RE ;
   icon_array[410]=RE ;
   icon_array[409]=RE ;
   icon_array[408]=RE ;
   icon_array[407]=RE ;
   icon_array[406]=BL ;
   icon_array[405]=RE ;
   icon_array[404]=RE ;
   icon_array[403]=RE ;
   icon_array[402]=RE ;
   icon_array[401]=RE ;
   icon_array[400]=RE ;
   icon_array[399]=BL ;
   
   icon_array[430]=BL ;    //row 10
   icon_array[429]=RE ;
   icon_array[428]=RE ;
   icon_array[427]=BL ;
   icon_array[426]=RE ;
   icon_array[425]=RE ;
   icon_array[424]=RE ;
   icon_array[423]=RE ;
   icon_array[422]=BL ;
   icon_array[421]=RE ;
   icon_array[420]=RE ;
   icon_array[419]=RE ;
   icon_array[418]=RE ;
   icon_array[417]=RE ;
   icon_array[416]=RE ;
   icon_array[415]=BL ;
   
   icon_array[446]=BL ;     //row 11
   icon_array[445]=RE ;
   icon_array[444]=RE ;
   icon_array[443]=RE ;
   icon_array[442]=BL ;
   icon_array[441]=RE ;
   icon_array[440]=RE ;
   icon_array[439]=RE ;
   icon_array[438]=BL ;
   icon_array[437]=RE ;
   icon_array[436]=RE ;
   icon_array[435]=RE ;
   icon_array[434]=RE ;
   icon_array[433]=RE ;
   icon_array[432]=RE ;
   icon_array[431]=BL ;
   
   icon_array[462]=BL ;     //row 12
   icon_array[461]=RE ;
   icon_array[460]=RE ;
   icon_array[459]=RE ;
   icon_array[458]=RE ;
   icon_array[457]=BL ;
   icon_array[456]=RE ;
   icon_array[455]=BL ;
   icon_array[454]=RE ;
   icon_array[453]=RE ;
   icon_array[452]=RE ;
   icon_array[451]=RE ;
   icon_array[450]=RE ;
   icon_array[449]=RE ;
   icon_array[448]=RE ;
   icon_array[447]= BL;
   
   icon_array[478]=BL ;       //row 13
   icon_array[477]=RE ;
   icon_array[476]=RE ;
   icon_array[475]=RE ;
   icon_array[474]=RE ;
   icon_array[473]=RE ;
   icon_array[472]=BL ;
   icon_array[471]=RE ;
   icon_array[470]=RE ;
   icon_array[469]=RE ;
   icon_array[468]=RE ;
   icon_array[467]=RE ;
   icon_array[466]=RE ;
   icon_array[465]=RE ;
   icon_array[464]=RE ;
   icon_array[463]=BL ;
   
   icon_array[494]=BL ;        //row 14
   icon_array[493]=RE ;
   icon_array[492]=RE ;
   icon_array[491]=RE ;
   icon_array[490]=RE ;
   icon_array[489]=RE ;
   icon_array[488]=RE ;
   icon_array[487]=RE ;
   icon_array[486]=RE ;
   icon_array[485]=RE ;
   icon_array[484]=RE ;
   icon_array[483]=RE ;
   icon_array[482]=RE ;
   icon_array[481]=RE ;
   icon_array[480]=RE ;
   icon_array[479]=BL ;
   
   icon_array[510]=BL ;       //row 15
   icon_array[509]=BL ;
   icon_array[508]=BL ;
   icon_array[507]=BL ;
   icon_array[506]=BL ;
   icon_array[505]=BL ;
   icon_array[504]=BL ;
   icon_array[503]=BL ;
   icon_array[502]=BL ;
   icon_array[501]=BL ;
   icon_array[500]=BL ;
   icon_array[499]=BL ;
   icon_array[498]=BL ;
   icon_array[497]=BL ;
   icon_array[496]=BL ;
   icon_array[495]=BL ;     //updated

/**********************************************
*****  End of array template
***********************************************/
end
endmodule 