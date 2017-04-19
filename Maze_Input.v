module Maze_Input # (
	parameter WIDTH = 10,
	parameter HEIGHT = 10
)(
	input		[3:0]							player_direction,
	input										at_start,
	input										stop_player,
	input 	[(WIDTH * HEIGHT)-1:0]	maze,
	
	output	[7:0]							player_x,
	output	[7:0]							player_y,
	output									at_end
);

	localparam UP 		= 4'b0001;
	localparam DOWN 	= 4'b0010;
	localparam RIGHT	= 4'b0100;
	localparam LEFT	= 4'b1000;
	
	//reg	[3:0]	prev_direction;
	
	reg 	[7:0]	x_reg;
	reg	[7:0]	y_reg;
	
	reg	end_reg;
	
	always @(player_direction or at_start or stop_player) begin
		if (at_start == 1'b1) begin
			x_reg = 1'b0;
			y_reg = 1'b0;
			end_reg = 1'b0;
		end else if (stop_player == 1'b0) begin
			if (player_direction == UP && player_y > 8'h00 && maze[(WIDTH * (player_y - 1)) + player_x] == 0) begin
				// Move up
				y_reg = player_y - 8'h01;
			end else if (player_direction == DOWN && player_y < HEIGHT - 1 && maze[(WIDTH * (player_y + 1)) + player_x] == 0) begin
				// Move down
				y_reg = player_y + 8'h01;
			end else if (player_direction == RIGHT && player_x < WIDTH - 1 && maze[(WIDTH * player_y) + player_x + 1] == 0) begin
				// Move right
				x_reg = player_x + 8'h01;
			end else if (player_direction == LEFT && player_x > 8'h00 && maze[(WIDTH * player_y) + player_x - 1] == 0) begin
				// Move left
				x_reg = player_x - 8'h01;
			end
			
			if (((player_x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (player_x == WIDTH - 2 && (WIDTH - 2) % 2 == 0))  && player_y == HEIGHT - 1) begin
			end_reg = 1'b1;
		end else begin
			end_reg = 1'b0;
		end
			
		end
	end
	
	assign player_x = x_reg;
	assign player_y = y_reg;
	
	assign at_end = end_reg;
	
endmodule
