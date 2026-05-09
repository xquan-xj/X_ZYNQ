`timescale 1ns / 1ps

module tb_qmx7020_base_top;

    reg sys_clk;
    reg sys_rst_n;
    wire [1:0] led;

    qmx7020_base_top #(
        .CLK_FREQ_HZ(1_000),
        .HEARTBEAT_HZ(10)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .led(led)
    );

    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    initial begin
        sys_rst_n = 1'b0;
        #100;
        sys_rst_n = 1'b1;
        #5_000;
        $finish;
    end

endmodule
