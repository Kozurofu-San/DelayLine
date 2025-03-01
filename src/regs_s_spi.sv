module regs_s_spi (
    input           clk,
    input           nrst_i,
    input           s_spi_clk_i,
    input           s_spi_mosi_i,
    output          s_spi_miso_o,
    input           s_spi_nss_i,

    output [7:0]    spi_reg_id,
    output [7:0]    spi_reg_ctrl,
    output [15:0]   spi_reg_delay
);

    // Input and output
    reg [7:0] shift_input;
    reg [7:0] shift_output;
    assign s_spi_miso_o = shift_output[7];

    // Address and data
    reg [7:0] address;
    wire rw;
    assign rw = shift_input[7];

    // ID register
    parameter REG_ID_ADDR = 4'h0;
    reg [7:0] REG_ID;

    // Control register
    parameter REG_CTRL_ADDR = 4'h1;
    reg [7:0] REG_CTRL;

    // Delay register 0 - lower 8 bits
    parameter REG_DELAY0_ADDR = 4'h2;
    reg [7:0] REG_DELAY0;

    // Delay register 1 - high 8 bits
    parameter REG_DELAY1_ADDR = 4'h3;
    reg [7:0] REG_DELAY1;

    assign spi_reg_id = REG_ID;
    assign spi_reg_ctrl = REG_CTRL;
    assign spi_reg_delay = {REG_DELAY1, REG_DELAY0};

    // Counter
    parameter NUMBER_OF_BITS = 8;
    reg [3:0] cnt;

    // Clock oversampling
    logic[1:0] spi_clk_ov; always_ff @(posedge clk) spi_clk_ov <= {spi_clk_ov[0], s_spi_clk_i};
    wire spi_clk_rise = (spi_clk_ov == 2'b01);

    // Address, reading and writing flag
    reg address_phase;
    reg read_phase;
    reg write_phase;

    // SPI Slave logic
    always @(posedge clk) begin
        if (!nrst_i) begin
            cnt <= 4'd0;
            address <= 8'h0;
            address_phase <= 0;
            read_phase <= 0;
            write_phase <= 0;
            shift_input <= 8'h0;
            shift_output <= 8'h0;
            REG_CTRL <= 8'h0;
            REG_DELAY0 <= 8'h0;
            REG_DELAY1 <= 8'h0;
            REG_ID <= 8'h58;
        end
        else begin
            if ((cnt <= NUMBER_OF_BITS) && spi_clk_rise && !s_spi_nss_i) begin
                cnt <= cnt + 4'd1;
                shift_input <= {shift_input[6:0], s_spi_mosi_i};
                shift_output <= {shift_output[6:0], 1'b0};
            end
            else if (cnt == NUMBER_OF_BITS) begin
                cnt <= 0;
                if (!address_phase) begin
                    address_phase <= 1;
                    address <= shift_input;
                    if (rw) begin
                        write_phase <= 0;
                        read_phase <= 1;
                    end
                    else begin
                        write_phase <= 1;
                        read_phase <= 0;
                    end
                end
                // Writing to REG
                else if (write_phase) begin
                    address_phase <= 0;
                    write_phase <= 0;
                    case (address[3:0])
                        REG_CTRL_ADDR:      REG_CTRL    <= shift_input;
                        REG_DELAY0_ADDR:    REG_DELAY0  <= shift_input;
                        REG_DELAY1_ADDR:    REG_DELAY1  <= shift_input;
                        default: shift_output <= 0;
                    endcase
                end
            end
            // Reading from REG
            else if (read_phase) begin
                address_phase <= 0;
                read_phase <= 0;
                case (address[3:0])
                    REG_ID_ADDR:        shift_output    <= REG_ID;
                    REG_CTRL_ADDR:      shift_output    <= REG_CTRL;
                    REG_DELAY0_ADDR:    shift_output    <= REG_DELAY0;
                    REG_DELAY1_ADDR:    shift_output    <= REG_DELAY1;
                    default: shift_output <= 0;
                endcase
            end
        end
    end

endmodule