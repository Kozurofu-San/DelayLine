module mux #(
    parameter WIDTH = 4,                // Number of inputs
    parameter SEL_WIDTH = $clog2(WIDTH) // Selector width
)(
    input  logic [SEL_WIDTH-1:0] sel,   // Control selector
    input  logic [WIDTH-1:0] in,        // Inputs
    output logic out                    // Output
);

    assign out = in[sel];
    
endmodule