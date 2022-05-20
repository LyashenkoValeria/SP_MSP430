module msp430(
input logic F1,
input logic F2,

input logic [15:0] COMM,
input logic COMME,
 
output logic [15:0] DMI,
output logic DMIE,

output logic [15:0] PC_OUT
);
wire [15:0] ps_data;
wire ps_jmpe;
wire [15:0] ps_addr;
wire ps_addr_ena;

wire [15:0] dm_wr_addr, dm_rd_addr;
wire [15:0] dm_wr_data;
wire dm_dms, dm_rdv;

assign PC_OUT = ps_addr;

//counter cnt_inst(.CLK(F1),
//                 .DATA(ps_data)
//                 .JMP_ENA(ps_jmpe),
//					    .JMP_ADDR(ps_pc_next),
//					  
//					    .PC(ps_addr),
//					    .PC_ENA(ps_addr_ena)
//		             );
//		
//prog_mem pm_inst(.CLK(F2),
//                 .PC_ADDR(ps_addr),
//					    .PC_ENA(ps_addr_ena),
//					  
//					    .DATA(ps_data)
//                 );	

cpu cpu_inst(.COMM(COMM),
             .COMME(COMME),
				 .DMI(DMI),
				 .DMIE(DMIE),
				 .F1(F1),
				 .F2(F2),
				 
				 .DMO(dm_wr_data),
             .DMAW(dm_wr_addr), 
				 .DMAR(dm_rd_addr), 
				 .DMS(dm_dms),
				 .RDV(dm_rdv),
				 .WRV(dm_wrv),
				 .RS(ps_rs)
				 );

data_mem dm_inst(.CLK(F1),
                 .DMAW(dm_wr_addr), 
					  .DMAR(dm_rd_addr), 
					  .WD(dm_wr_data), 
					  .DMS(dm_dms),
					  .RDV(dm_rdv),
					  .WRV(dm_wrv),
					  
					  .RD(DMI)
					  );
endmodule