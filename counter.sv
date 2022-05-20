module counter(
input logic CLK,
input logic [15:0] DATA,
input logic JMPE,
input logic [15:0] JMP_ADDR,

output logic [15:0] PC,
output logic PC_ENA
);

reg [3:0] code;
reg as_0, ad;
reg rd_comm;

reg [15:0]pc_next;

reg [15:0]pc_comm;
reg [15:0]pc_data;
reg rd_op2;

initial
    begin
	 pc_next = 16'h0002;
	 PC_ENA = 1'b0;
	 rd_comm = 1'b1;
	 end

always @(posedge CLK) 
    begin
	 if(JMPE) pc_next <= JMP_ADDR;
	 else pc_next <= pc_next + 2;

	 PC <= pc_next;
	 PC_ENA <= 1'b1;
    end
endmodule