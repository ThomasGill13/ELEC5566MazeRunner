module LT24Top (
    //
    // Global Clock/Reset
    // - Clock
    input              clock,
    // - Global Reset
    input              globalReset,
    // - Application Reset - for debug
    output             resetApp,
    //
    // LT24 Interface
    output             LT24_WRn,
    output             LT24_RDn,
    output             LT24_CSn,
    output             LT24_RS,
    output             LT24_RESETn,
    output [     15:0] LT24_D,
    output             LT24_LCD_ON,
	 
	 output [9:0]		led_bus
);

	localparam A = 3'b000;
	localparam B = 3'b001;
	localparam C = 3'b010;
	localparam D = 3'b011;
	localparam E = 3'b100;
	localparam F = 3'b101;
	localparam G = 3'b110;
	
	reg [2:0]	state;
	reg [2:0]	next_state;
	
// Flags
reg startChar;	// sets the initial character
reg charAlternator;	// alternates between characters

reg  [7: 0] xCharOrigin		; // register to store character x origin
reg  [8: 0] yCharOrigin		; // register to store character y origin
reg  [3: 0] charXCord	; // stores the character X coordinate
reg	 [3: 0] charYCord	; // stores the character Y coordinate

// Flags

reg  [ 7:0] xAddr      ;
reg  [ 8:0] yAddr      ;
reg  [15:0] pixelData  ;
wire        pixelReady ;

localparam WIDTH = 240;
localparam HEIGHT = 320;

// Maze making variables

localparam height = 10;
localparam width = 30;

//reg [(width * height)-1:0] maze_wire_reg;
//wire [(width * height)-1:0] maze_wire;
reg gen_start;
//reg reset;
wire gen_end;
reg gen_end_reg;
reg [10:0] maze_tracker;
wire maze_address_data;

wire reset;
//assign maze_wire_reg = maze_wire

Maze_Maker # (
	.WIDTH  (width  ),
	.HEIGHT (height )
) maze_maker(
	.gen_start  			(1'b0						),
	.seed						(11'b10101010101		),
	.reset					(reset					),
	.clock					(clock					),
	.maze_address 			(maze_tracker			),
	.maze_address_data	(maze_address_data	),
	.gen_end					(gen_end					)
);



LT24Display #(
    .WIDTH       (240        ),
    .HEIGHT      (320        ),
    .CLOCK_FREQ  (50000000   )
) Display (
    .clock       (clock      ),
    .globalReset (reset			),
    .resetApp    (resetApp   ),
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (1'b1 		  ),
    .pixelReady  (pixelReady ),
	 .pixelRawMode(1'b0       ),
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    .LT24_WRn    (LT24_WRn   ),
    .LT24_RDn    (LT24_RDn   ),
    .LT24_CSn    (LT24_CSn   ),
    .LT24_RS     (LT24_RS    ),
    .LT24_RESETn (LT24_RESETn),
    .LT24_D      (LT24_D     ),
    .LT24_LCD_ON (LT24_LCD_ON)
);



// Wait to get data

always @(state or gen_end) begin
	case(state)
		// Initilize
		A : begin
			// Do initialising stuff here
			
			// set cursor at the origin
			yAddr <= 9'b0;	// set y coordinate to zero
			xAddr <= 8'b0;	// set x coordinate to zero
			
			// reset characters
			xCharOrigin <= 5'b0;
			yCharOrigin <= 6'b0;
			
			//
			charXCord <= 4'b0;
			charYCord <= 4'b0;
			
			// start the generation of the maze
			// gen_start <= 1'b1;
			//reset <= 1'b1;
			maze_tracker <= 11'b0;
			
			next_state <= C;
		end
		
		// Request data
		B : begin
			
			maze_tracker = maze_tracker + 11'd1;
			
			charYCord <= 0;
			charXCord <= 0;
			
			xCharOrigin = xCharOrigin + 8;
			
			if (xCharOrigin > (width * 8)) begin
				yCharOrigin = yCharOrigin + 8;
			end
			
			if (yCharOrigin > (height * 8)) begin
				next_state <= E;
			end else begin
				next_state <= C;
			end
		end
		
		// Wait
		C : begin
			next_state <= D;
		end
		
		// Draw data
		D : begin
			
			// first confirm that the LCD is ready to receive data
			if (pixelReady) begin
				// Pixel ready to be drawn
				
				// If in bounds
				if ((xAddr <(WIDTH)) && (yAddr < (HEIGHT)) && maze_tracker < (width*height)) begin
					
					
					pixelData[15:11] <= 5'b00000;	// red pixel data
					pixelData[10: 5] <= 6'b111111;	// green pixel data
					pixelData[4:0] <= 5'b00000;	// set pixel data to zero
					
					/*
					if (maze_address_data == 1'b1) begin
						// Draw wall
						// set the pixel data to black
						pixelData[15:11] <= 5'b0;	// red pixel data
						pixelData[10: 5] <= 6'b0;	// green pixel data
						pixelData[4:0] <= 5'b0;	// set pixel data to zero
					end else begin
						// Draw floor
						// set color to green
						pixelData[15:11] <= 5'b00000;	// red pixel data
						pixelData[10: 5] <= 6'b111111;	// green pixel data
						pixelData[4:0] <= 5'b00000;	// set pixel data to zero
					end
					*/
					
					/*
					// If the current tile's x pixel position >= 8
					if (charXCord + 1 >= 8) begin
						charXCord <= 0;
						// If the current tile's y pixel position >= 8
						if (charYCord + 1 >= 8) begin
							charYCord = 0;
						end else begin
							charYCord = charYCord + 1;
						end
					end else begin
						charXCord = charXCord + 1;
					end
					*/
					
					if (charXCord + 1 >= 8 && charYCord + 1 >= 8) begin
						next_state <= E;
					end else if (charXCord + 1 >= 8) begin
						charXCord <= 0;
						charYCord <= charYCord + 1;
						
						next_state <= G;
					end else begin
						charXCord <= charXCord + 1;
						next_state <= G;
					end
					
				end
				else begin
					next_state <= E;
				end
				
			end else begin
				// Wait unitl pixel is ready to be drawn
				next_state <= D;
			end
		end
		
		// End
		E : begin
			if (gen_end == 1'b1) begin
				next_state <= E;
			end
			else begin
				next_state <= F;
			end
		end
		
		// Wait until generation has finished
		F : begin
			if (gen_end == 1'b1 && resetApp == 1'b1) begin
				next_state <= A;
			end
			else begin
				next_state <= F;
			end
		end
		
		// Set cursor address
		G : begin
		// first confirm that the LCD is ready to receive data
			if (pixelReady) begin
				yAddr = yCharOrigin + charYCord;
				xAddr = xCharOrigin + charXCord;
				next_state <= D;
			end else begin
				next_state <= G;
			end
		end
		
	endcase
end

	// Change state of the state machine
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= F;
		end else begin
			state <= next_state;
		end
	end

assign led_bus[9] = gen_end;
assign led_bus[2:0] = state;
assign reset = ~globalReset;

endmodule
