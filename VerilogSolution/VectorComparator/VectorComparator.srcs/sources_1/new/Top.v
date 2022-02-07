`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2022 04:18:17 PM
// Design Name: 
// Module Name: Top
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

module Top (
    input clk, rst, input_mode,
    input [7:0] serial_in,
    output [7:0] td1, td2, td3,
    output out_valid,
    output done
    );
    
    wire process_done, load_mem, run, halt, data_rdy;
    wire [7:0] rp1, rp2, rp3, ip_count;
    
    FSM SM(clk, rst, data_rdy, process_done, load_mem, run, done);
    
    RegisterFile RF(clk, rst, load_mem, input_mode, serial_in, rp1, rp2, rp3, ip_count, td1, td2, td3, data_rdy);
    
    Processor Lane1(clk, rst, run, ip_count, td1, td2, td3, out_valid, process_done, rp1, rp2, rp3);
endmodule