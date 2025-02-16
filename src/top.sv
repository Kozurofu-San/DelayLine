module DelayLine (

    // Clock and reset
    input clk_i,
    input nrst_i,

    // LEDs
    output [2:0] led_o,

    // Buttons
    input btn_i,

    // SPI slave
    input s_spi_clk_i,
    input s_spi_mosi_i,
    output s_spi_miso_o,
    input s_spi_nss_i,

    // Delay wires connections
    input [2:0] delay_bit_i,
    output [2:0] delay_bit_o
);

    wire clk_pll;

    pll pll_inst(
        .inclk0(clk_i),
        .areset(1'b0),
        .c0(clk_pll)
    );

    reg [2:0] led;
    assign led_o = led;

    parameter FREQUENCY = 32'd16_000_000;
    reg [31:0] counter;

    always @(posedge clk_pll) begin
        counter <= counter + 1;
        if (counter == (FREQUENCY - 1)) begin
            counter <= 0;
            led <= led + 3'b1;
        end
    end

    delay_line delay_line_inst(
        .nrst_i(nrst_i),
        .s_spi_clk_i(s_spi_clk_i),
        .s_spi_mosi_i(s_spi_mosi_i),
        .s_spi_miso_o(s_spi_miso_o),
        .s_spi_nss_i(s_spi_nss_i),
        .delay_bit_i(delay_bit_i),
        .delay_bit_o(delay_bit_o)
    );

endmodule