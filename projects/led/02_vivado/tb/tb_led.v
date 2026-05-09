`timescale 1ns / 1ps

module tb_led;

    reg clk;
    reg rst_n;
    wire led;

    led #(
        .CLK_FREQ_HZ(1_000),
        .BLINK_HZ(10)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .led(led)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
        #5_000;
        $finish;
    end

endmodule

