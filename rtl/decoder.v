/*
* Decoder
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module decoder(clk_i, rst_i, instruction_i,
               funct3_o, rs1_o, rs2_o, rd_o, imm_op_o, sel_dat_a_o, sel_dat_b_o,
               is_alu_alt_op_o, is_lui_o, is_auipc_o, is_jal_o, is_jalr_o, is_branch_o,
               is_mem_o, we_mem_o, is_misc_mem_o, is_system_o);

  input clk_i;
  input rst_i;

  // OPCODES
  localparam LUI      = 7'b0110111;
  localparam AUIPC    = 7'b0010111;
  localparam JAL      = 7'b1101111;
  localparam JALR     = 7'b1100111;
  localparam BRANCH   = 7'b1100011;
  localparam LOAD     = 7'b0000011;
  localparam STORE    = 7'b0100011;
  localparam OP_IMM   = 7'b0010011;
  localparam OP       = 7'b0110011;
  localparam MISC_MEM = 7'b0001111;
  localparam SYSTEM   = 7'b1110011;

  // Imm-Gen Operations
  localparam IMM_I = 3'b000;
  localparam IMM_S = 3'b001;
  localparam IMM_B = 3'b010;
  localparam IMM_U = 3'b011;
  localparam IMM_J = 3'b100;
  localparam IMM_C = 3'b101;

  // Mux control for ALU's inputs
  localparam SEL_REG  = 2'b00;
  localparam SEL_IMM  = 2'b01;
  localparam SEL_PC   = 2'b10;
  localparam SEL_ZERO = 2'b11;


  input  [31:0] instruction_i;
  output [2:0] funct3_o;
  output [2:0] imm_op_o;
  output [4:0] rs1_o;
  output [4:0] rs2_o;
  output [4:0] rd_o;
  output [2:0] sel_dat_a_o;
  output [2:0] sel_dat_b_o;

  output is_lui_o;
  output is_auipc_o;
  output is_jal_o;
  output is_jalr_o;
  output is_branch_o;
  output is_mem_o;
  output we_mem_o;
  output is_misc_mem_o;
  output is_system_o;
  output is_alu_alt_op_o;

  wire [6:0] opcode;

  assign opcode          = instruction_i[6:0];
  assign funct3_o        = instruction_i[14:12];
  assign rs1_o           = instruction_i[19:15];
  assign rs2_o           = instruction_i[24:20];
  assign rd              = instruction_i[11:7];
  assign is_alu_alt_op_o = instruction_i[30];  


  always @(instruction_i) begin
    is_lui_o      = 0;
    is_auipc_o    = 0;
    is_jal_o      = 0;
    is_jalr_o     = 0;
    is_branch_o   = 0;
    is_mem_o      = 0;
    we_mem_o      = 0;
    is_misc_mem_o = 0;
    is_system_o   = 0;

    case(opcode)
      LUI: begin
        sel_dat_a_o = SEL_PC;
        sel_dat_b_o = SEL_IMM;
        imm_op_o    = IMM_U;
        is_lui_o    = 1;
      end

      AUIPC: begin
        sel_dat_a_o = SEL_PC;
        sel_dat_b_o = SEL_IMM;    
        imm_op_o    = IMM_U;    
        is_auipc_o  = 1;
      end

      JAL: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_ZERO;         
        imm_op_o    = IMM_J;       
        is_jal_o    = 1;
      end

      JALR: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_IMM;            
        imm_op_o    = IMM_I;    
        is_jalr_o   = 1;
      end

      BRANCH: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_REG;           
        imm_op_o    = IMM_B;     
        is_branch_o = 1;
      end

      LOAD: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_IMM;                
        imm_op_o    = IMM_I;
        is_mem_o    = 1;
      end

      STORE: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_IMM;                     
        imm_op_o    = IMM_S;   
        is_mem_o    = 1;
        we_mem_o    = 1;
      end

      OP_IMM: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_IMM;           
        imm_op_o    = IMM_I;     
      end

      OP: begin
        sel_dat_a_o = SEL_REG;
        sel_dat_b_o = SEL_REG;        
      end

      MISC_MEM: begin
        is_misc_mem_o = 1;
      end

      SYSTEM: begin
        is_system_o = 1;
        // Check if is CSR with immediate instruction
        if (funct3_o[2])
          sel_dat_a_o = SEL_IMM;
        else
          sel_dat_a_o = SEL_REG;
      end
    endcase
    
  end
endmodule