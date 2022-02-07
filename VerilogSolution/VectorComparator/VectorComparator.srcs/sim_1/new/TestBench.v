`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2022 05:37:28 AM
// Design Name: 
// Module Name: TestBench
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

module TestBench();
    reg clk = 0, rst = 1, input_mode = 0;
    reg [7:0] serial_in = 0;
    
    wire signed [7:0] td1, td2, td3;
    wire out_valid, done;
    
    integer tuple_count = 0, cycle_count = 0;
    
    Top UUT(clk, rst, input_mode, serial_in, td1, td2, td3, out_valid, done);
    
    always #5 clk = ~clk;
    
    initial begin
        #20 rst = 0;
        wait(done);
        #30;
        $display("All Done!");
        $display("Total number of tuples found: %d", tuple_count);
        $display("Total number of cycles taken after reset: %d", cycle_count);
        $finish;
    end
    
    always@(posedge clk) cycle_count <= cycle_count + 1;
    
    always@(posedge out_valid) begin
        tuple_count <= tuple_count + 1;
        $display("Tuple %d: (%d, %d, %d)\n", tuple_count+1, td1, td2, td3); 
    end
endmodule
