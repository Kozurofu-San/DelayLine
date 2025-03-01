module DelayLine #(
    DELAY_BITS = 11
) (

    // Clock and reset
    input           clk_i,
    input           nrst_i,

    // LEDs
    output [2:0]    led_o,

    // Buttons
    input           btn_i,

    // SPI slave
    input           s_spi_clk_i,
    input           s_spi_mosi_i,
    output          s_spi_miso_o,
    input           s_spi_nss_i,

    // Variable delay wires connections
    input           delayed_strobe_i,       // Terminals
    output          delayed_strobe_o,

    input [DELAY_BITS-1:0]    delay_i,      // Interconnect
    output [DELAY_BITS-1:0]   delay_o,
    input [DELAY_BITS-1:0]    delay_short_i,
    output [DELAY_BITS-1:0]   delay_short_o,

    // Fixed delay wires connections
    input           fix_delayed_strobe_i,    // Terminals
    output          fix_delayed_strobe_o,

    input           delay_fix_i,            // Interconnect
    output          delay_fix_o
);

    // Connect fixed delay wires
    assign delay_fix_o = fix_delayed_strobe_i;
    assign fix_delayed_strobe_o = delay_fix_i;

    wire clk_pll;

    pll pll_inst(
        .inclk0(clk_i),
        .areset(1'b0),
        .c0(clk_pll)
    );

    reg [2:0] led;
    assign led_o = ~led;

    localparam FREQUENCY = 32'd16_000_000;
    reg [31:0] counter;

    always @(posedge clk_pll) begin
        if (nrst_i) begin
            counter <= 0;
            led <= 3'b0;
        end
        else begin
            if (!btn_i) begin
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
                if (counter == (FREQUENCY - 1)) begin
                    counter <= 0;
                    led <= led + 3'b1;
                end
            end
        end
    end

    wire [7:0]    spi_reg_id;
    wire [7:0]    spi_reg_ctrl;
    wire [15:0]   spi_reg_delay;

    regs_s_spi regs_inst(
        .clk            (clk_pll),
        .nrst_i         (nrst_i),
        .s_spi_clk_i    (s_spi_clk_i),
        .s_spi_mosi_i   (s_spi_mosi_i),
        .s_spi_miso_o   (s_spi_miso_o),
        .s_spi_nss_i    (s_spi_nss_i),

        .spi_reg_id     (spi_reg_id),
        .spi_reg_ctrl   (spi_reg_ctrl),
        .spi_reg_delay  (spi_reg_delay)
    );

    demultiplexer #(
        .WIDTH  (2)
    ) demux_inst (
        .sel    (spi_reg_delay[0]),
        .in     (delayed_strobe_i),
        .out    ({delay_short_o[0], delay_o[0]})
    );

    wire [DELAY_BITS-2:0] inter;
    genvar i;
    generate
        for (i = 0; i < DELAY_BITS-1; i++) begin: gen_block

            multiplexer #(
                .WIDTH  (2)
            ) mux_inst (
                .sel    (spi_reg_delay[i]),
                .in     ({delay_short_i[i], delay_i[i]}),
                .out    (inter[i])
            );

            demultiplexer #(
                .WIDTH  (2)
            ) demux_inst (
                .sel    (spi_reg_delay[i + 1]),
                .in     (inter[i]),
                .out    ({delay_short_o[i + 1], delay_o[i + 1]})
            );
        end
    endgenerate

    
    multiplexer #(
        .WIDTH  (2)
    ) mux_inst (
        .sel    (spi_reg_delay[DELAY_BITS - 1]),
        .in     ({delay_short_i[DELAY_BITS - 1], delay_i[DELAY_BITS - 1]}),
        .out    (delayed_strobe_o)
    );



endmodule