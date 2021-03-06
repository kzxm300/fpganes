`include "dat.vh"

module nrom(
	input wire clk,
	input wire reset,
	output wire irq,
	
	input wire [15:0] memaddr,
	output wire [7:0] prgrdata,
	input wire [7:0] memwdata,
	input wire memwr,
	input wire prgreq,
	output wire prgack,
	
	input wire [13:0] vmemaddr,
	output wire [7:0] chrrdata,
	input wire [7:0] vmemwdata,
	input wire vmemwr,
	input wire chrreq,
	output wire chrack,
	
	output wire [20:0] promaddr,
	input wire [7:0] promdata,
	output wire promreq,
	input wire promack,
	
	output wire [20:0] cromaddr,
	input wire [7:0] cromdata,
	output wire cromreq,
	input wire cromack,
	
	output wire [12:0] chrramaddr,
	input wire [7:0] chrramrdata,
	output wire [7:0] chrramwdata,
	output wire chrramwr,
	output wire chrramreq,
	input wire chrramack,

	output wire [14:0] prgramaddr,
	input wire [7:0] prgramrdata,
	output wire [7:0] prgramwdata,
	output wire prgramwr,
	output wire prgramreq,
	input wire prgramack,
	
	input wire [127:0] header,
	output reg [2:0] mirr
);

	assign prgrdata = memaddr[15] ? promdata : prgramrdata;
	assign promaddr = header[39:32] != 1 ? {6'd0, memaddr[14:0]} : {7'd0, memaddr[13:0]};
	assign prgramaddr = {2'b00, memaddr[12:0]};
	assign promreq = memaddr[15] && prgreq;
	assign prgramreq = !memaddr[15] && prgreq;
	assign prgack = memaddr[15] ? promack : prgramack;
	assign prgramwdata = memwdata;
	assign prgramwr = memwr;
	
	wire chrram;
	
	assign chrram = header[47:40] == 0;
	assign cromaddr = {7'd0, vmemaddr};
	assign chrramaddr = vmemaddr[12:0];
	assign chrrdata = chrram ? chrramrdata : cromdata;
	assign chrramwdata = vmemwdata;
	assign chrramwr = vmemwr;
	assign chrramreq = chrram ? chrreq : 0;
	assign cromreq = chrram ? 0 : chrreq;
	assign chrack = chrram ? chrramack : cromack;
	
	assign irq = 0;
	
	always @(*)
		case({header[51], header[48]})
		0: mirr = `MIRRHOR;
		1: mirr = `MIRRVER;
		default: mirr = `MIRR4;
		endcase
endmodule
