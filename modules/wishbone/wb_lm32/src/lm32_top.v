// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2006 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                         FILE DETAILS
// Project          : LatticeMico32
// File             : lm32_top.v
// Title            : Top-level of CPU.
// Dependencies     : lm32_include.v
// Version          : 6.1.17
//                  : removed SPI - 04/12/07
// Version          : 7.0SP2, 3.0
//                  : No Change
// Version          : 3.1
//                  : No Change
// =============================================================================

`include "system_conf.v"
`include "lm32_include.v"

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////

module lm32_top (
    // ----- Inputs -------
    clk_i,
    rst_i,
    // From external devices
//`ifdef CFG_INTERRUPTS_ENABLED
    interrupt,
//`endif
    // From user logic
`ifdef CFG_USER_ENABLED
    user_result,
    user_complete,
`endif     
`ifdef CFG_IWB_ENABLED
    // Instruction Wishbone master
    I_DAT_I,
    I_ACK_I,
    I_ERR_I,
    I_RTY_I,
`endif
    // Data Wishbone master
    D_DAT_I,
    D_ACK_I,
    D_ERR_I,
    D_RTY_I,
    // ----- Outputs -------
`ifdef CFG_USER_ENABLED    
    user_valid,
    user_opcode,
    user_operand_0,
    user_operand_1,
`endif    
`ifdef CFG_IWB_ENABLED
    // Instruction Wishbone master
    I_DAT_O,
    I_ADR_O,
    I_CYC_O,
    I_SEL_O,
    I_STB_O,
    I_WE_O,
    I_CTI_O,
    I_LOCK_O,
    I_BTE_O,
`endif
    // Data Wishbone master
    D_DAT_O,
    D_ADR_O,
    D_CYC_O,
    D_SEL_O,
    D_STB_O,
    D_WE_O,
    D_CTI_O,
    D_LOCK_O,
    D_BTE_O
    );

parameter eba_reset = 32'h00000000;
parameter sdb_address = 32'h00000000;
/////////////////////////////////////////////////////
// Inputs
/////////////////////////////////////////////////////

input clk_i;                                    // Clock
input rst_i;                                    // Reset

//`ifdef CFG_INTERRUPTS_ENABLED
input [`LM32_INTERRUPT_RNG] interrupt;          // Interrupt pins
//`endif

`ifdef CFG_USER_ENABLED
input [`LM32_WORD_RNG] user_result;             // User-defined instruction result
input user_complete;                            // Indicates the user-defined instruction result is valid
`endif    

`ifdef CFG_IWB_ENABLED
input [`LM32_WORD_RNG] I_DAT_I;                 // Instruction Wishbone interface read data
input I_ACK_I;                                  // Instruction Wishbone interface acknowledgement
input I_ERR_I;                                  // Instruction Wishbone interface error
input I_RTY_I;                                  // Instruction Wishbone interface retry
`endif

input [`LM32_WORD_RNG] D_DAT_I;                 // Data Wishbone interface read data
input D_ACK_I;                                  // Data Wishbone interface acknowledgement
input D_ERR_I;                                  // Data Wishbone interface error
input D_RTY_I;                                  // Data Wishbone interface retry

/////////////////////////////////////////////////////
// Outputs
/////////////////////////////////////////////////////

`ifdef CFG_USER_ENABLED
output user_valid;                              // Indicates that user_opcode and user_operand_* are valid
wire   user_valid;
output [`LM32_USER_OPCODE_RNG] user_opcode;     // User-defined instruction opcode
reg    [`LM32_USER_OPCODE_RNG] user_opcode;
output [`LM32_WORD_RNG] user_operand_0;         // First operand for user-defined instruction
wire   [`LM32_WORD_RNG] user_operand_0;
output [`LM32_WORD_RNG] user_operand_1;         // Second operand for user-defined instruction
wire   [`LM32_WORD_RNG] user_operand_1;
`endif

`ifdef CFG_IWB_ENABLED
output [`LM32_WORD_RNG] I_DAT_O;                // Instruction Wishbone interface write data
wire   [`LM32_WORD_RNG] I_DAT_O;
output [`LM32_WORD_RNG] I_ADR_O;                // Instruction Wishbone interface address
wire   [`LM32_WORD_RNG] I_ADR_O;
output I_CYC_O;                                 // Instruction Wishbone interface cycle
wire   I_CYC_O;
output [`LM32_BYTE_SELECT_RNG] I_SEL_O;         // Instruction Wishbone interface byte select
wire   [`LM32_BYTE_SELECT_RNG] I_SEL_O;
output I_STB_O;                                 // Instruction Wishbone interface strobe
wire   I_STB_O;
output I_WE_O;                                  // Instruction Wishbone interface write enable
wire   I_WE_O;
output [`LM32_CTYPE_RNG] I_CTI_O;               // Instruction Wishbone interface cycle type 
wire   [`LM32_CTYPE_RNG] I_CTI_O;
output I_LOCK_O;                                // Instruction Wishbone interface lock bus
wire   I_LOCK_O;
output [`LM32_BTYPE_RNG] I_BTE_O;               // Instruction Wishbone interface burst type 
wire   [`LM32_BTYPE_RNG] I_BTE_O;
`endif

output [`LM32_WORD_RNG] D_DAT_O;                // Data Wishbone interface write data
wire   [`LM32_WORD_RNG] D_DAT_O;
output [`LM32_WORD_RNG] D_ADR_O;                // Data Wishbone interface address
wire   [`LM32_WORD_RNG] D_ADR_O;
output D_CYC_O;                                 // Data Wishbone interface cycle
wire   D_CYC_O;
output [`LM32_BYTE_SELECT_RNG] D_SEL_O;         // Data Wishbone interface byte select
wire   [`LM32_BYTE_SELECT_RNG] D_SEL_O;
output D_STB_O;                                 // Data Wishbone interface strobe
wire   D_STB_O;
output D_WE_O;                                  // Data Wishbone interface write enable
wire   D_WE_O;
output [`LM32_CTYPE_RNG] D_CTI_O;               // Data Wishbone interface cycle type 
wire   [`LM32_CTYPE_RNG] D_CTI_O;
output D_LOCK_O;                                // Date Wishbone interface lock bus
wire   D_LOCK_O;
output [`LM32_BTYPE_RNG] D_BTE_O;               // Data Wishbone interface burst type 
wire   [`LM32_BTYPE_RNG] D_BTE_O;
  
/////////////////////////////////////////////////////
// Internal nets and registers 
/////////////////////////////////////////////////////
 
`ifdef CFG_JTAG_ENABLED
// Signals between JTAG interface and CPU
wire [`LM32_BYTE_RNG] jtag_reg_d;
wire [`LM32_BYTE_RNG] jtag_reg_q;
wire jtag_update;
wire [2:0] jtag_reg_addr_d;
wire [2:0] jtag_reg_addr_q;
wire jtck;
wire jrstn;
`endif

// TODO: get the trace signals out
`ifdef CFG_TRACE_ENABLED
// PC trace signals
wire [`LM32_PC_RNG] trace_pc;                   // PC to trace (address of next non-sequential instruction)
wire trace_pc_valid;                            // Indicates that a new trace PC is valid
wire trace_exception;                           // Indicates an exception has occured
wire [`LM32_EID_RNG] trace_eid;                 // Indicates what type of exception has occured
wire trace_eret;                                // Indicates an eret instruction has been executed
`ifdef CFG_DEBUG_ENABLED
wire trace_bret;                                // Indicates a bret instruction has been executed
`endif
`endif

/////////////////////////////////////////////////////
// Functions
/////////////////////////////////////////////////////

`include "lm32_functions.v"
/////////////////////////////////////////////////////
// Instantiations
///////////////////////////////////////////////////// 
   
// LM32 CPU   
lm32_cpu 
	#(
		.eba_reset(eba_reset),
    .sdb_address(sdb_address)
	) cpu (
    // ----- Inputs -------
    .clk_i                 (clk_i),
`ifdef CFG_EBR_NEGEDGE_REGISTER_FILE
    .clk_n_i               (clk_n),
`endif
    .rst_i                 (rst_i),
    // From external devices
`ifdef CFG_INTERRUPTS_ENABLED
    .interrupt             (interrupt),
`endif
    // From user logic
`ifdef CFG_USER_ENABLED
    .user_result           (user_result),
    .user_complete         (user_complete),
`endif     
`ifdef CFG_JTAG_ENABLED
    // From JTAG
    .jtag_clk              (jtck),
    .jtag_update           (jtag_update),
    .jtag_reg_q            (jtag_reg_q),
    .jtag_reg_addr_q       (jtag_reg_addr_q),
`endif
`ifdef CFG_IWB_ENABLED
     // Instruction Wishbone master
    .I_DAT_I               (I_DAT_I),
    .I_ACK_I               (I_ACK_I),
    .I_ERR_I               (I_ERR_I),
    .I_RTY_I               (I_RTY_I),
`endif
    // Data Wishbone master
    .D_DAT_I               (D_DAT_I),
    .D_ACK_I               (D_ACK_I),
    .D_ERR_I               (D_ERR_I),
    .D_RTY_I               (D_RTY_I),
    // ----- Outputs -------
`ifdef CFG_TRACE_ENABLED
    .trace_pc              (trace_pc),
    .trace_pc_valid        (trace_pc_valid),
    .trace_exception       (trace_exception),
    .trace_eid             (trace_eid),
    .trace_eret            (trace_eret),
`ifdef CFG_DEBUG_ENABLED
    .trace_bret            (trace_bret),
`endif
`endif
`ifdef CFG_JTAG_ENABLED
    .jtag_reg_d            (jtag_reg_d),
    .jtag_reg_addr_d       (jtag_reg_addr_d),
`endif
`ifdef CFG_USER_ENABLED    
    .user_valid            (user_valid),
    .user_opcode           (user_opcode),
    .user_operand_0        (user_operand_0),
    .user_operand_1        (user_operand_1),
`endif    
`ifdef CFG_IWB_ENABLED
    // Instruction Wishbone master
    .I_DAT_O               (I_DAT_O),
    .I_ADR_O               (I_ADR_O),
    .I_CYC_O               (I_CYC_O),
    .I_SEL_O               (I_SEL_O),
    .I_STB_O               (I_STB_O),
    .I_WE_O                (I_WE_O),
    .I_CTI_O               (I_CTI_O),
    .I_LOCK_O              (I_LOCK_O),
    .I_BTE_O               (I_BTE_O),
    `endif
    // Data Wishbone master
    .D_DAT_O               (D_DAT_O),
    .D_ADR_O               (D_ADR_O),
    .D_CYC_O               (D_CYC_O),
    .D_SEL_O               (D_SEL_O),
    .D_STB_O               (D_STB_O),
    .D_WE_O                (D_WE_O),
    .D_CTI_O               (D_CTI_O),
    .D_LOCK_O              (D_LOCK_O),
    .D_BTE_O               (D_BTE_O)
    );
   
`ifdef CFG_JTAG_ENABLED		   
// JTAG cores 
jtag_cores jtag_cores (
    // ----- Inputs -----
    .reg_d                 (jtag_reg_d),
    .reg_addr_d            (jtag_reg_addr_d),
    // ----- Outputs -----
    .reg_update            (jtag_update),
    .reg_q                 (jtag_reg_q),
    .reg_addr_q            (jtag_reg_addr_q),
    .jtck                  (jtck),
    .jrstn                 (jrstn)
    );
`endif        
   
endmodule
