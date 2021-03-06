# ROJOBOT World

This project builds on the RojoBot concepts by placing the RojoBot in a virtual world. The RojoBot and its world are simulated in an IP (intellectual-property) 
block called BotSim (bot.v). BotSim is a SoC design in its own right; containing a Xilinx Picoblaze, firmware in program memory and logic to manage its interface.

The BotSim module receives instructions that control the RojoBot wheel motors through a writable 8- bit “Motor Control Input” register. The BotSim provides information about its virtual environment through a set of read-only 8-bit registers. These registers indicate the RojoBot location, orientation (heading), 
direction of movement and the values of its proximity and line tracking sensors. The register details and function of the BotSim are described in the BotSim 2.0 Functional Specification. 

Project constructs an interface blocks of Verilog logic, an embedded CPU executing PicoBlaze Assembly Code and a VGA video controller in order to generate an onscreen virtual robot capable of following different lines through a computer generated word. There was also an intermediate step where a demo program was instantiated, run, and displayed on the Nexys 4 DDR Board. Coded the left right algorithm of the robot motion in assembly language for the PicoBlaze so that the robot can traverse the world map over the black line. 

Video demo project: [Video demo](https://www.youtube.com/watch?v=Eguip2julHM)

Project Design : [Project Design](https://github.com/danghai/rojo-bot/blob/master/rojo-bot_documentation.pdf)


