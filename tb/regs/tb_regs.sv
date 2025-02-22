`timescale 1ps/1ps
module tb ();
    
    parameter DIV = 4;

    reg clk;
    reg nrst_i;
    reg s_spi_clk_i;
    reg s_spi_mosi_i;
    wire s_spi_miso_o;
    reg s_spi_nss_i;

    wire [7:0]    spi_reg_id;
    wire [7:0]    spi_reg_ctrl;
    wire [7:0]    spi_reg_delay;

    regs_s_spi dut(.*);

    initial begin
        nrst_i <= 1;
        clk <= 0;
        s_spi_clk_i <= 0;
        s_spi_mosi_i <= 0;
        s_spi_nss_i <= 1;

        repeat(2) @(posedge clk);
        nrst_i <= 0;
        repeat(2) @(posedge clk);
        nrst_i <= 1;

        m_spi_read(4'h0);
        m_spi_write(4'h1, 8'h38);
        m_spi_read(4'h1);
        m_spi_write(4'h2, 8'h53);
        m_spi_read(4'h2);

    end

    always begin
        #1 clk <= ~clk;
    end

    task m_spi_write(input [3:0] addr, input [7:0] data);
    begin
        reg [7:0] address;
        address <= {4'h0, addr};

        // CS on
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 0;

        // Address
        for (int i = 0; i < 8; i++) begin
            repeat(DIV) @(posedge clk);
            s_spi_mosi_i <= address[7-i];
            s_spi_clk_i <= 1;
            repeat(DIV) @(posedge clk);
            s_spi_clk_i <= 0;
        end

        // CS off
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 1;

        // CS on
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 0;

        // Data
        for (int i = 0; i < 8; i++) begin
            repeat(DIV) @(posedge clk);
            s_spi_mosi_i <= data[7-i];
            s_spi_clk_i <= 1;
            repeat(DIV) @(posedge clk);
            s_spi_clk_i <= 0;
        end

        // CS
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 1;
        
        $display("Write 0x%02X <- 0x%02X", addr, data);
    end
    endtask

    task  m_spi_read(input [3:0] addr);
    begin
        reg [7:0] data;
        reg [7:0] address;
        address <= {4'h8, addr};

        // CS
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 0;

        // Address
        for (int i = 0; i < 8; i++) begin
            repeat(DIV) @(posedge clk);
            s_spi_mosi_i <= address[7-i];
            s_spi_clk_i <= 1;
            repeat(DIV) @(posedge clk);
            s_spi_clk_i <= 0;
        end

        // CS off
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 1;

        // CS on
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 0;

        // Idle data
        for (int i = 0; i < 8; i++) begin
            repeat(DIV) @(posedge clk);
            s_spi_mosi_i <= 1;
            data[7-i] <= s_spi_miso_o;
            s_spi_clk_i <= 1;
            repeat(DIV) @(posedge clk);
            s_spi_clk_i <= 0;
        end

        // CS
        repeat(2) @(posedge clk);
        s_spi_nss_i <= 1;
        
        $display("Read  0x%02X -> 0x%02X", addr, data);
    end
    endtask

endmodule