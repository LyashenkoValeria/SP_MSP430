module cpu(
//Входные порты
input logic [15:0]COMM,
input logic COMME,
input logic [15:0]DMI,
input logic DMIE,
input logic F1,
input logic F2,

//Выходные порты
output logic [15:0]DMO,
output logic [15:0]DMAW,
output logic [15:0]DMAR,
output logic RDV,
output logic WRV,
output logic DMS,
output logic [15:0]RS
);

//Парсим команду 1 формата
reg [3:0] code;
reg [3:0] scr_i, dst_i;
reg ad;
reg [1:0] as;

//Парсим команду 2 формата
reg [3:0] code2;

//Читаем результаты из рег файла
reg [15:0] scr_reg, dst_reg;

//Пишем в рег файл
reg wrv_rf;

//Работы с АЛУ
reg [15:0] alu_result;
reg [15:0] op_x, op_y;

//Читаем из RAM
reg [15:0] data;

//Пишем в RAM
reg dst_w;
reg [15:0] dst_w_addr;

reg read_op; //для поочередного чтения операндов из памяти

//Регистр состояния
reg [15:0] sr;

initial
    begin
	 wrv_rf = 1'b0;
	 scr_i = 4'h0;
	 dst_i = 4'h0;
	 read_op = 1'b1;
	 sr = 16'h0001;
	 dst_w = 1'b0;
	 end
	 
task read_ram;
    input [1:0] mode;
	 input [15:0] ram_data;
	 input [15:0] ram_reg;
	 output [15:0] ram_addr;
	 output dms, rdv;
	 
	 begin
	 case (mode)
	 2'b00, 2'b11: ram_addr <= 16'h0000;
	 2'b01: ram_addr <= ram_reg + ram_data;
	 2'b10: ram_addr <= ram_reg;
	 endcase
	 
	 if (!(^mode))
	 	 begin
	 	 dms <= 1'b1;
	 	 rdv <= 1'b1;
	 	 end
	 else
	 	 begin
	 	 dms <= 1'b0;
	 	 rdv <= 1'b0;
	 	 end
	 end
endtask
	 
reg_file reg_file_inst(.CLK(F1), 
                       .RADDR1(scr_i), 
							  .RADDR2(dst_i), 
							  .RDATA1(scr_reg), 
							  .RDATA2(dst_reg), 
							  .WRV(wrv_rf), 
							  .WADDR(dst_i), 
							  .WDATA(alu_result)
							  );

always @(posedge F1)
    begin
    if (COMME) 
	     begin
		  code <= COMM[15:12];
		  if (code > 4'h3) 
		      begin
		      scr_i <= COMM[11:8];
				dst_i <= COMM[3:0];
				ad <= COMM[7];
				as <= COMM[5:4];
				if (DMIE) data <= DMI;
				else data <= 16'h0000;
		      end
		  if (code == 4'h1)
		      begin
				code2 <= COMM[11:8];
				as <= COMM[5:4];
				dst_i <= COMM[3:0];
				scr_i <= 16'h0000;
				if (DMIE) data <= DMI;
				else data <= 16'h0000;
				end
		  
		  if (code > 4'h3) 
		      begin
		  
		      if (read_op) 
		          begin
					 read_ram (as, data, scr_reg, DMAR, DMS, RDV);
					 
					 case(as)
					 2'b00: op_x <= scr_reg;
	             2'b01, 2'b10: op_x <= DMI; //оставить так, пока нет память
					 2'b11: op_x <= data;
					 endcase
					 
					 dst_w <= 1'b0;
					 wrv_rf <= 1'b0;
                end
		  
		      if (!read_op) 
		          begin
		          case (ad)
		          1'b0: 
		              begin
					     DMAR <= 16'h0000;
					     DMS <= 1'b0;
					     RDV <= 1'b0;

						  dst_w_addr <= 16'h0000;
		              end
		          1'b1: 
				        begin
		              DMAR <= dst_reg + data;
					     DMS <= 1'b1;
					     RDV <= 1'b1;

						  dst_w_addr <= dst_reg + data; 
		              end
		          endcase
					 
		          dst_w <= ad;
					 wrv_rf <= ~ad;
					 
		          if (!ad) op_y <= dst_reg;
		          else op_y <= DMI;
		          end
					 read_op <= ~read_op;
		      end
		  
		  if (code == 4'h1) 
		      begin
		      read_ram (as, data, dst_reg, DMAR, DMS, RDV);
				
				case(as)
				2'b00: op_y <= scr_reg;
	         2'b01, 2'b10: op_y <= DMI; //оставить так, пока нет память
				default: op_y <= 16'h0000;
				endcase
				
				if(^as) dst_w_addr <= dst_reg + as[0]*data;
				else dst_w_addr <= 16'h0000;
				
				dst_w <= ^as;
				
				if (!(|as)) wrv_rf <= 1'b1;
		      end
	     end
	 end
	 
alu alu_inst(.CLK(F1), 
             .OP_X(op_x), 
				 .OP_Y(op_y), 
				 .RS(sr), 
				 .COMM_ALU(COMM), 
				 .DATA_OUT(),
				 .RS_ALU(sr)
				 );

always @(posedge F2)
    begin
    if (dst_w)
	     begin
		  DMAW <= dst_w_addr;
		  DMO <= alu_result;
		  end
	 else
	     begin
	     DMAW <= 16'h0000;
		  DMO <= alu_result;
		  end
	 WRV <= dst_w;
	 RS <= sr;
    end


endmodule