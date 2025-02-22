module demux #(
    parameter WIDTH = 4,                // Number of inputs
    parameter SEL_WIDTH = $clog2(WIDTH) // Selector width
)(
    input  logic [SEL_WIDTH-1:0] sel,   // Control selector
    input  logic in,                    // Input
    output logic [WIDTH-1:0] out        // Outputs
);

    always_comb begin
        out = '0;           // Deafult 0
        out[sel] = in;      // Selector
    end

endmodule