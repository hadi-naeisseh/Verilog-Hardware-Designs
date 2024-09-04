`timescale 1ns / 1ns


module top_module ();

    parameter DATAWIDTH = 8'b00001000;
    parameter ARRAYLENGTH = 8'b00001010;

    reg clk;
    reg [ARRAYLENGTH*DATAWIDTH-1:0] array_in;
    reg valid_in;
    wire [ARRAYLENGTH*DATAWIDTH-1:0] array_out;
    wire valid_out;

    SE #(ARRAYLENGTH, DATAWIDTH) u1(
    .clk(clk),
    .array_in(array_in),
    .valid_in(valid_in),
    .array_out(array_out),
    .valid_out(valid_out)
    );

    initial begin
    
    clk = 0;
    forever 
    begin
    #10 clk = ~clk;
    //$display("Sorted array_out: %h, %d, %d, %d", array_out, valid_out, valid_in, clk);

    $monitor("t=%0t, clk=%0b, array_out=%0h, valid_out=%0b, valid_in=%0b", 
             $time, clk, array_out, valid_out, valid_in);


    end

    end
initial begin

    valid_in=1;
    array_in = {8'd10, 8'd3, 8'd5, 8'd1, 8'd6, 8'd8, 8'd2, 8'd9, 8'd4, 8'd7};
    #20 valid_in = 0;

    wait (valid_out == 1);

    //$display("Sorted array_out: %h", array_out);

    #40 $finish;
end


endmodule



   
module SE #(parameter ARRAYLENGTH=10, DATAWIDTH=8)(
    input wire clk,
    input wire [ARRAYLENGTH*DATAWIDTH-1:0] array_in,
    input wire valid_in,
    output wire [ARRAYLENGTH*DATAWIDTH-1:0] array_out,
    output wire valid_out
);

reg [ARRAYLENGTH/2:0]shiftregister=0; 
wire [DATAWIDTH-1:0] unpacked_in [ARRAYLENGTH-1:0];
reg [DATAWIDTH-1:0] workingarray [ARRAYLENGTH-1:0];

wire [DATAWIDTH-1:0] layer1_out [ARRAYLENGTH-1:0];
wire [DATAWIDTH-1:0] layer2_out [ARRAYLENGTH-1:0];

genvar i;

// unpack the vector to array
generate 
    for(i = 0; i < ARRAYLENGTH; i=i+1)
    begin : g1
        assign unpacked_in[i] = array_in[(i+1)*DATAWIDTH-1:i*DATAWIDTH];
        assign array_out[(i+1)*DATAWIDTH-1:i*DATAWIDTH] = workingarray[i];
    end
endgenerate

// first layer
parameter remainder = ARRAYLENGTH % 2;
generate 
    
    for(i = 0; i < ARRAYLENGTH/2; i=i+1)
    begin : g2
        swapper u1(
            .input1(workingarray[remainder + i*2]), .input2(workingarray[remainder + i*2 + 1]),
            .output1(layer1_out[remainder + i*2]), .output2(layer1_out[remainder + i*2 + 1])
        );
    end
    
    if (remainder != 0)
        assign layer1_out[0] = workingarray[0];
endgenerate

// second layer
parameter remainder2nd = (ARRAYLENGTH - 1) % 2;
generate 
    
    for(i = 0; i < (ARRAYLENGTH-1)/2; i=i+1)
    begin : g3
        swapper u2(
            .input1(layer1_out[remainder2nd + i*2]), .input2(layer1_out[remainder2nd + i*2 + 1]),
            .output1(layer2_out[remainder2nd + i*2]), .output2(layer2_out[remainder2nd + i*2 + 1])
        );
    end
    
    assign layer2_out[ARRAYLENGTH-1] = layer1_out[ARRAYLENGTH-1];

    if (remainder2nd != 0)
        assign layer2_out[0] = layer1_out[0];
endgenerate

always @ (posedge clk)
begin

    shiftregister[0]<=valid_in;

    // Figure out when to do workingarray <= inputs, or layer2_out
    // Track when valid_in was provided, set valid_out accordingly
    // that's it
end

generate

 for(i = 0; i < ARRAYLENGTH; i=i+1)
    begin : g5
    

always @ (posedge clk)
    begin

        if(valid_in)
    begin
        workingarray[i] <= unpacked_in[i];
    end
    else
    begin   
        workingarray[i] <= layer2_out[i];

    end
    end

end

endgenerate

generate

 for(i = 1; i <= (ARRAYLENGTH)/2; i=i+1)
    begin : g4
    

always @ (posedge clk)
    begin

shiftregister[i] <= shiftregister[i-1];

    end

end

endgenerate

assign valid_out = shiftregister[ARRAYLENGTH/2];


endmodule


module swapper #(
    parameter DATAWIDTH=8
) (
    input wire [DATAWIDTH-1:0] input1,   // right
    input wire [DATAWIDTH-1:0] input2,   // left
    output wire [DATAWIDTH-1:0] output1, // right
    output wire [DATAWIDTH-1:0] output2  // left
);
    assign output1 = (input2 > input1) ? input2 : input1;
    assign output2 = (input2 > input1) ? input1 : input2;
endmodule
