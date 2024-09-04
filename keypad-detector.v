module PD(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [3:0]din,
    output wire pattern1,
    output wire pattern2

);
    reg [3:0] C0, C1, C2, C3; // Creating 4 registers with 4b size.
    reg V0, V1, V2, V3; //Creating 4 registers for validation with 1b size.
    wire datacheck1;
    wire datacheck2;
    wire vercheck; 
    always @ (posedge clk or posedge reset) // Triggered on positive edge of clock or reset signal
    begin
        if(reset) 
        begin
            C0 <= 0;
            C1 <= 0;
            C2 <= 0;
            C3 <= 0;
            V0 <= 0;
            V1 <= 0;
            V2 <= 0;
            V3 <= 0;
        end  
        else

        // If enable is 1, then the din value inputted by the user will propogate throughout the C0-C3 registers, otherwise the values wont change.

        C0 <= enable? din : C0; 
        C1 <= enable? C0 : C1;  
        C2 <= enable? C1 : C2;  
        C3 <= enable? C2 : C3;  

        // If enable is 1, then valid registers will become 1 in the same shifting fasion that the data comes in above.

        V0 <= enable? 1:V0;
        V1 <= enable? V0:V1;
        V2 <= enable? V1:V2;
        V3 <= enable? V2:V3;

    end

        // Here we are assigning the logic to check if pattern 1 or not are met, it will only assert if the pattern is correct and the all the valid bits are = 1.
        // This is because we dont want it to be checking data unless the user has pressed atleast 4 numbers.
        
    assign vercheck = V0 & V1 & V2 & V3;
    assign datacheck1 = ((C0==1)&(C1==3)&(C2==5)&(C3==0));  
    assign datacheck2 = ((C0==9)&(C1==1)&(C2==6)&(C3==0));  
    assign pattern1 = vercheck & datacheck1;
    assign pattern2 = vercheck & datacheck2;


//Tools: I used JDOODLE Online Verilog Compiler to simulate the TB.

endmodule
