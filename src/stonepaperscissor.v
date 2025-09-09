`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    00:02:47 09/07/25
// Design Name:    
// Module Name:    stonepaperscissor
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module stone_paper_scissors (
    input wire clk,
    input wire reset,
    input wire [1:0] p1_move,  // Player 1 move
    input wire [1:0] p2_move,  // Player 2 move
    input wire start,          // Start signal
    input wire mode,           // Debug mode (unused)
    output reg [1:0] winner,   // 00 = Tie, 01 = P1 wins, 10 = P2 wins, 11 = Invalid
    output reg [2:0] state,    // FSM state
    output reg [2:0] debug     // Debug output
);

    // State Encoding
    localparam S_IDLE     = 3'b000,
               S_EVALUATE = 3'b001,
               S_RESULT   = 3'b010;

    // Single sequential process FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= S_IDLE;
            winner <= 2'b00;
            debug  <= 3'b000;
        end
        else begin
            case(state)
                S_IDLE: begin
                    winner <= 2'b00; // Default tie
                    debug  <= 3'b000;
                    if (start)
                        state <= S_EVALUATE;
                end

                S_EVALUATE: begin
                    // Check for invalid moves
                    if (p1_move == 2'b11 || p2_move == 2'b11) begin
                        winner <= 2'b11; // Invalid
                    end
                    else if (p1_move == p2_move) begin
                        winner <= 2'b00; // Tie
                    end
                    else begin
                        case(p1_move)
                            2'b00: winner <= (p2_move == 2'b10) ? 2'b01 : 2'b10; // Stone
                            2'b01: winner <= (p2_move == 2'b00) ? 2'b01 : 2'b10; // Paper
                            2'b10: winner <= (p2_move == 2'b01) ? 2'b01 : 2'b10; // Scissors
                            default: winner <= 2'b11; // Invalid
                        endcase
                    end
                    debug <= {p1_move[0], p2_move[1:0]};
                    state <= S_RESULT;
                end

                S_RESULT: begin
                    if (!start)
                        state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

