//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2022 04:18:17 PM
// Design Name: 
// Module Name: Components
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Processor (
    input clk, rst, run,
    input [7:0] count,
    input [7:0] rd1, rd2, rd3,
    output out_flag, done_flag,
    output reg [7:0] rp1, rp2, rp3
    );
    
    wire [7:0] sum;
    
    always@(*) begin
        if(rst) begin
            rp1 <= 8'd0;
            rp2 <= 8'd1;
        end
        rp3 <= count-1;
    end
    
    always@(posedge clk) begin
        if(run) begin
            rp1 <= rp1 + 1;
            rp2 <= rp1 + 2;
            rp3 <= count-1;
            if(sum == 0) begin
                if(rp2+1 < rp3-1) begin
                    rp1 <= rp1;
                    rp2 <= rp2 + 1;
                    rp3 <= rp3 - 1;
                end
            end else if(sum[7] == 1) begin
                if(rp2+1 < rp3) begin
                    rp1 <= rp1;
                    rp2 <= rp2 + 1;
                    rp3 <= rp3;
                end
            end else if(sum[7] == 0) begin
                if(rp2 < rp3-1) begin
                    rp1 <= rp1;    
                    rp2 <= rp2;
                    rp3 <= rp3 - 1;
                end    
            end
        end
    end
    
    assign sum = rd1 + rd2 + rd3;
    assign out_flag = run && (sum == 0);
    assign done_flag = (rd1 == 0);
endmodule
    
module Comparator(
    input [7:0] regA, regB, regC,
    output zeroFlag
    );
    assign zeroFlag = (regA + regB + regC) == 8'd0;
endmodule

module RegisterFile(
    input clk, rst, load_mem,
    input wr_mode_sel, //1-serialin, 0-bulkload
    input [7:0] serialIn,
    input [7:0] rd_ptr1, rd_ptr2, rd_ptr3,
    output [7:0] count, rd1, rd2, rd3,
    output reg data_ready
    );
    
    reg [7:0] VecReg [0:256]; //VecReg[0] is the count register
    reg [255:0] SBReg = 256'd0;
    
    reg [8:0] wr_pointer = 9'd1;// rd_ptr1 = 8'd0, rd_ptr2 = 8'd0, rd_ptr3 = 8'd0;
    reg [7:0] j, k = 128;
    reg [8:0] i;
    
    initial begin
        for(i=0; i<=256; i=i+1)
            VecReg[i] = 8'd0;
    end
    
    always@(posedge clk) begin
        if(rst) begin
            for(i=0; i<=256; i=i+1)
                VecReg[i] = 8'd0;
            wr_pointer <= 8'd1;
            data_ready <= 0;
        end else if(load_mem)
            if(wr_mode_sel) begin
                SBReg[serialIn] = 1;
                VecReg[0] = VecReg[0] + 1;
            end else begin
                $readmemh("dmem.mem", VecReg, 0, 255);
                for (j=0; j < VecReg[0]; j=j+1) begin
                    SBReg[VecReg[j+1]] = 1;
                    VecReg[j+1] = 0;
                end
                VecReg[0] = 0;
            end
        else if(!data_ready) begin
            if(SBReg[k] == 1) begin
                VecReg[0] = VecReg[0] + 1;
                VecReg[wr_pointer] <= k;
                wr_pointer <= wr_pointer + 1;
            end
            if(k == 255) k <= 0;
            else if(k == 127) data_ready <= 1;
            else k <= k+1;
        end
    end
    
    assign count = VecReg[0];
    assign rd1 = VecReg[rd_ptr1+1];
    assign rd2 = VecReg[rd_ptr2+1];
    assign rd3 = VecReg[rd_ptr3+1];
endmodule

module FSM(
    input clk, rst, data_sorted, process_done,
    output reg load_mem, run, halt
    );
    
    localparam [2:0] Reset = 0, LoadMem = 1, Arrange = 2, Run = 3, Halt = 4;
    reg [2:0] state, next_state;
    
    always@(posedge clk) begin
        state <= next_state;
    end
    
    always@(*) begin
        if(rst) next_state <= Reset;
        else
            case(state)
                Reset: next_state <= LoadMem;
                LoadMem: next_state <= Arrange;
                Arrange: begin 
                    if(data_sorted) next_state <= Run;
                    else next_state <= Arrange;
                end
                Run:
                    if(process_done) next_state <= Halt;
                    else next_state <= Run;
                Halt: next_state <= Halt;
            endcase
    end
    
    always@(state) begin
        load_mem <= 0; run <= 0; halt <= 0;
        case(state)
            LoadMem: load_mem <= 1;
            Run: run <= 1;
            Halt: halt <= 1;
        endcase
    end
endmodule