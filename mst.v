module mst
    (
    input clock,
    input reset,
    input enable,
    output reg [7:0] wra,
    output reg [7:0] wrd,
    output reg [7:0] rda,
    output reg [7:0] rdd,
    output reg we,
    output reg [8:0] t1attempts,
    output reg [8:0] t1fails,
    output reg [8:0] t2attempts,
    output reg [8:0] t2fails,
    output reg done
    );

    wire [7:0] rddmem;
    
    memory u2 (.clock(clock), .reset(reset), .we(we), .wra(wra), .wrd(wrd), .rda(rda), .rdd(rddmem));

    reg testnumber;


    assign rddmem = rdd;
    
//test 1

reg [7:0]count;
reg [1:0]timemaker;


always @ (negedge clock)
begin
if(reset)
    begin
    rda<=0;
    wrd<=0;
    wra<=0;
    t1attempts<=0;
    t1fails<=0;
    t2attempts<=0;
    t2fails<=0;
    done<=0;
    testnumber<=0;
    timemaker<=0;
    count<=0;
    end
else if(enable && !(done))
    begin
    timemaker <= (timemaker+1)%3;
    if (testnumber==0)
        begin
            if(timemaker==0)
                begin
                    we <= 1;
                    wra <= count;
                    wrd <= 8'h00;
                    rda <= count;
                end
            else if(timemaker==1)
                begin
                    we <=0;
                end
            else if(timemaker==2)
                begin

                    t1fails <= (rdd==0) ? t1fails : t1fails+1;
                    t1attempts <= t1attempts+1;
                    count<=count+1;

                end
            else
                begin
                    t1fails<=t1fails;
                    t1attempts<=t1attempts;
                end
        end

    //test2
    else 
        begin
            if(timemaker==0)
                begin
                    we <= 1;
                    wra <= count;
                    wrd <= 8'hFF;
                    rda <= count;
                end
            else if(timemaker==1)
                begin
                    we <=0;
                end
            else if(timemaker==2)
                begin
                    t2fails <= (rdd==8'hFF) ? t2fails : t2fails+1;
                    t2attempts <= t2attempts+1;
                    count<=count+1;
                end
            else
                begin
                    t2fails<=t2fails;
                    t2attempts<=t2attempts;
                end
        end

    if (count == 255 && timemaker == 2)
    begin
        testnumber <= testnumber + 1;
        count <= 0;
    end

    if(count==255 && testnumber==1 && timemaker==2)
        begin

        done<=1;

        end
    else
        begin

        done<=0;

        end
    end
end
    
endmodule



module memory(
    input clock,
    input reset,
    input we,
    input [7:0] wra,
    input [7:0] wrd,
    input [7:0] rda,
    output [7:0] rdd
    );
    
    reg [7:0] mem[255:0];
    reg [7:0] rddata;
    
    always @(posedge clock)
    begin
        if(reset)
        begin
            rddata <= 8'h00;
        end
        else
        begin
            if(we)
            begin
                mem[wra] <= wrd;
            end
            rddata <= mem[rda];
        end
    end
    
    assign rdd = rddata;
        
endmodule
