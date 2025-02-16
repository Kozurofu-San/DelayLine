module delay_line (
    input           nrst_i,
    input           s_spi_clk_i,
    input           s_spi_mosi_i,
    output          s_spi_miso_o,
    input           s_spi_nss_i,
    input [2:0]     delay_bit_i,
    output [2:0]    delay_bit_o
);

    assign delay_bit_o = delay_bit_i;

    // Input and output
    reg [7:0] shift_input;
    reg [7:0] shift_output;
    assign s_spi_miso_o = shift_input[0];

    // Address and data
    reg [7:0] address;
    wire rw;
    assign rw = address[7];

    // Control register
    parameter REG_CTRL_ADDR = 4'h1;
    reg [7:0] REG_CTRL;

    // Delay register
    parameter REG_DELAY_ADDR = 4'h2;
    reg [7:0] REG_DELAY;

    // Counter
    parameter NUMBER_OF_BITS = 8;
    reg [2:0] cnt;

    // SPI Slave logic
    always @(posedge s_spi_clk_i) begin
        if (!nrst_i) begin
            cnt <= 0;
            address <= 0;
            shift_input <= 8'h0;
            shift_output <= 8'h0;
            REG_CTRL <= 0;
            REG_DELAY <= 0;
        end
        else begin
            if (s_spi_nss_i == 0) begin
                cnt <= cnt + 1;
                shift_input <= {shift_input[6:0], s_spi_mosi_i};
                shift_output <= {1'b0, shift_output[6:1]};
                if (cnt == (NUMBER_OF_BITS - 1)) begin
                    cnt <= 0;
                    if (address[3:0] == 4'h0) begin
                        address[3:0] <= shift_input;
                    end
                    else if (rw) begin
                        case (address[3:0])
                            REG_CTRL_ADDR: REG_CTRL <= shift_input;
                            REG_DELAY_ADDR: REG_DELAY <= shift_input;
                            default: shift_output <= 0;
                        endcase
                    end
                    else begin
                        case (address[3:0])
                            REG_CTRL_ADDR: shift_output <= REG_CTRL;
                            REG_DELAY_ADDR: shift_output <= REG_DELAY;
                            default: shift_output <= 0;
                        endcase
                    end
                end
            end
            else begin
                cnt <= 0;
                address <= 0;
            end
        end
    end
endmodule