`timescale 10ps/10ps
module tb ();
    
    reg [2:0] sel_0;
    reg [7:0] in_0;
    wire out_0;

    reg [2:0] sel_1;
    reg in_1;
    wire [7:0] out_1;

    mux #(
        .WIDTH  (8)
    ) mux_dut (
        .sel    (sel_0),
        .in     (in_0),
        .out    (out_0)
    );
        
    demux #(
        .WIDTH  (8)
    ) demux_dut (
        .sel    (sel_1),
        .in     (in_1),
        .out    (out_1)
    );
        

    initial begin
        #1
        in_0 <= 8'hAA;
        in_1 <= 1;

        for (int i = 0; i < 8; i++) begin
            #3
            sel_0 <= i;
            sel_1 <= i;
        end

    end
    
endmodule