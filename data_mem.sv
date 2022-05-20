module data_mem(
input logic CLK,

input logic [15:0]DMAW, //write address
input logic [15:0]DMAR, //read address
input logic [15:0]WD,   //write data

input logic DMS,        //ena
input logic RDV,        
input logic WRV,       

output logic [15:0]RD  //read data
);

reg [15:0] RAM [4096:0];

assign RD = (DMS&&RDV) ? RAM[DMAR] : 16'b0;

always @(posedge CLK) begin
	if(DMS&&WRV) RAM[DMAW] <= WD;
end

endmodule