`timescale 10ps/10ps
module tb ();
    
    reg nrst_i;
    reg s_spi_clk_i;
    reg s_spi_mosi_i;
    wire s_spi_miso_o;
    reg s_spi_nss_i;
    reg [2:0] delay_bit_i;
    wire [2:0] delay_bit_o;

    delay_line dut(.*);

    initial begin
        nrst_i <= 1;
        s_spi_clk_i <= 0;
        s_spi_mosi_i <= 0;
        s_spi_nss_i <= 1;
        delay_bit_i <= 2'h0;

        #1 nrst_i <= 0;
        #1 nrst_i <= 1;
    end

    always begin
        #1 s_spi_clk_i <= ~s_spi_clk_i;
    end

endmodule