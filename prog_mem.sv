module prog_mem(
input logic CLK,
input logic [15:0]PC_ADDR, //адрес с PC
input logic PC_ENA,        //разрешение чтения с PC_ADDR

output logic [15:0]DATA    //данные из памяти
);

reg [7:0] MEMORY [4096:0]; //сама память

reg [7:0] msbyte,lsbyte; //старший и младший байт команды

initial
    begin
	 
	 MEMORY[2] = 8'h40;
	 MEMORY[3] = 8'h34;
	 MEMORY[4] = 8'h02;
	 MEMORY[5] = 8'h00;
	 
	 MEMORY[6] = 8'h44;
	 MEMORY[7] = 8'h05;
	 
	 MEMORY[8] = 8'h40;
	 MEMORY[9] = 8'hB4;
	 MEMORY[10] = 8'h00;
	 MEMORY[11] = 8'h03;
	 MEMORY[12] = 8'h00;
	 MEMORY[13] = 8'h00;
	 
	 MEMORY[14] = 8'h44;
	 MEMORY[15] = 8'hA5;
	 MEMORY[16] = 8'h00;
	 MEMORY[17] = 8'h04;
	 end

always @(posedge CLK) 
    begin
	 if(PC_ENA) 
	     begin
	     msbyte <= MEMORY[PC_ADDR];
		  lsbyte <= MEMORY[PC_ADDR+1];
		  
		  DATA <= {msbyte,lsbyte};
		  end
    end

endmodule