module instruction_fetch(
    input         clk,
    input         rst_n,
    input         memory_stall, 
    input  [31:0] IF_DWrite,     
    input         IF_flush,     
    input         PC_write,      
    input         PC_src,        
    input  [31:0] instruction_in,
    input  [31:0] branch_address,
    output [29:0] I_addr,       
    output        I_ren,         
    output [31:0] PC_1,
    output [31:0] instruction_1
);

// regs
reg [31:0] PC_r, PC_w;
reg [31:0] PC_out_r, PC_out_w;
reg [31:0] instruction_out_r, instruction_out_w;

// wires
reg [29:0] I_addr_w;
reg I_ren_w;
wire[31:0] instruction_little; //instruction input with little_end

assign PC_1              = PC_out_r;
assign instruction_1     = instruction_out_r;
assign I_addr            = I_addr_w;
assign I_ren             = I_ren_w;
assign instruction_little= {instruction_in[7:0],instruction_in[15:8],instruction_in[23:16],instruction_in[31:24]}; //instruction with little_end




wire  [31:0] instruction;//real output instruction 
assign instruction = instruction_little ;

// ===== PC ===== //
always @(*) begin
    if(PC_write || memory_stall) begin
        PC_w = PC_r;
    end
    else begin
        if(PC_src) // branch taken
            PC_w = branch_address;
        else
            PC_w = PC_r + 4;
    end
end

// ===== PC_out ===== //
always @(*) begin
    if(memory_stall) begin
        PC_out_w = PC_out_r ;
    end
    else begin
        if(PC_write) begin // load-use hazard
            PC_out_w = PC_r - 4;
        end
        else begin
            if(IF_flush) begin // branch hazard(insert NOP)
                PC_out_w = 32'd0;  
            end
            else begin
                PC_out_w = PC_r;
            end    
        end
    end
end

// ===== instruction_out ===== //
always @(*) begin
    if(memory_stall) begin
        instruction_out_w = instruction_out_r;
    end
    else begin
        if(PC_write) begin
            instruction_out_w = IF_DWrite;
        end
        else begin
            if(IF_flush) begin
                instruction_out_w = 32'h00000013; // NOP
            end
            else begin
                instruction_out_w = instruction;
            end    
        end
    end
end

// ===== I_cache ===== //
always @(*) begin
    I_addr_w            = PC_r[31:2];
    I_ren_w             = 1'b1;  // always reading I_cache
end

always @(posedge clk) begin
    if(!rst_n) begin
        PC_r                <= 32'd0;
        PC_out_r            <= 32'd0;
        instruction_out_r   <= 32'd0;
    end
    else begin
        PC_r                <= PC_w;
        PC_out_r            <= PC_out_w;
        instruction_out_r   <= instruction_out_w;
    end
end  
endmodule