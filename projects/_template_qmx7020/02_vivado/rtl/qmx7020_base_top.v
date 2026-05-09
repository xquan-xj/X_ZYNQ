`timescale 1ns / 1ps

module qmx7020_base_top #(
    parameter integer CLK_FREQ_HZ  = 50_000_000,
    parameter integer HEARTBEAT_HZ = 1
) (
    input  wire       sys_clk,
    input  wire       sys_rst_n,
    output reg  [1:0] led
);

    localparam integer HALF_PERIOD = CLK_FREQ_HZ / (HEARTBEAT_HZ * 2);
    localparam integer CNT_WIDTH = (HALF_PERIOD <= 2) ? 1 : $clog2(HALF_PERIOD);

    reg [CNT_WIDTH-1:0] cnt;
    reg heartbeat;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= {CNT_WIDTH{1'b0}};
            heartbeat <= 1'b0;
            led <= 2'b00;
        end else if (cnt == HALF_PERIOD - 1) begin
            cnt <= {CNT_WIDTH{1'b0}};
            heartbeat <= ~heartbeat;
            led <= {heartbeat, ~heartbeat};
        end else begin
            cnt <= cnt + 1'b1;
            led <= {heartbeat, ~heartbeat};
        end
    end

endmodule
