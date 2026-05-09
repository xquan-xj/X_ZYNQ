`timescale 1ns / 1ps

module led #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BLINK_HZ    = 1
) (
    input  wire clk,
    input  wire rst_n,
    output reg  led
);

    localparam integer HALF_PERIOD = CLK_FREQ_HZ / (BLINK_HZ * 2);
    localparam integer CNT_WIDTH   = $clog2(HALF_PERIOD);

    reg [CNT_WIDTH-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= {CNT_WIDTH{1'b0}};
            led <= 1'b0;
        end else if (cnt == HALF_PERIOD - 1) begin
            cnt <= {CNT_WIDTH{1'b0}};
            led <= ~led;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule

