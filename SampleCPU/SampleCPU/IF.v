`include "lib/defines.vh"
module IF(
    input wire clk,
    input wire rst,
    input wire [`StallBus-1:0] stall,

    // input wire flush,
    // input wire [31:0] new_pc,

    input wire [`BR_WD-1:0] br_bus,  //分支相关信号

    output wire [`IF_TO_ID_WD-1:0] if_to_id_bus,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata
);
    reg [31:0] pc_reg;  //存放当前指令地址
    reg ce_reg; //指令存储器使能寄存器，用于控制指令存储器的访问
    wire [31:0] next_pc; 
    wire br_e;
    wire [31:0] br_addr; //分支地址
    //信号连接
    assign {
        br_e,  //高位
        br_addr  //低位
    } = br_bus;

    //程序计数器更新逻辑
    always @ (posedge clk) begin
        if (rst) begin
            pc_reg <= 32'hbfbf_fffc;
        end
        else if (stall[0]==`NoStop) begin
            pc_reg <= next_pc;
        end
    end
    //指令存储器使能寄存器更新逻辑
    always @ (posedge clk) begin
        if (rst) begin
            ce_reg <= 1'b0;
        end
        else if (stall[0]==`NoStop) begin
            ce_reg <= 1'b1;
        end
    end


    assign next_pc = br_e ? br_addr : pc_reg + 32'h4;

    
    assign inst_sram_en = ce_reg;   //指令存储器使能信号
    assign inst_sram_wen = 4'b0;    //指令存储器写使能信号
    assign inst_sram_addr = pc_reg; //指令存储器地址，读取当前指令
    assign inst_sram_wdata = 32'b0;
    assign if_to_id_bus = {
        ce_reg, //指示当前指令是否有效，便于ID阶段判断是否需要处理当前指令
        pc_reg //当前指令的地址，便于ID阶段进行指令译码和其他操作
    };

endmodule