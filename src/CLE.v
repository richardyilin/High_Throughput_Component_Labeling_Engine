`timescale 1ns/10ps
module CLE ( clk, reset, rom_q, rom_a, sram_a, sram_d, sram_wen, finish);
input          clk;
input          reset;
input   [7:0]  rom_q;
output  [6:0]  rom_a;
output  [9:0]  sram_a;
output  [7:0]  sram_d;
output         sram_wen;
output         finish;

parameter INIT    = 0;
parameter FIRST   = 1;
parameter MERGE   = 2;
parameter SECOND1 = 3;
parameter MERGE1  = 4;
parameter MERGE2  = 5;
parameter MERGE3  = 6;
parameter SECOND2 = 7;

parameter CA = 0;
parameter CB = 1;
parameter CC = 2;
parameter CD = 3;
parameter CE = 4;
parameter CF = 5;
parameter CG = 6;
parameter CH = 7;
parameter CI = 8;

wire [7:0] q_even, q_odd;
wire [5:0] label;
wire cen;
wire [5:0] y_plus_2;
wire [2:0] y_r_mod, y_plus_2_mod;
wire [5:0] n1, n2, n3, n4, n5;
wire [9:0] position;
wire n1_not0, n3_not0;
wire [1:0] n1_n3_not0;
wire [5:0] label_to_read;
wire [5:0] label_index_to_read;
wire [8:0] a_even, a_odd;
wire [7:0] d_even, d_odd;
wire wen_even, wen_odd;
reg [5:0] merger_table_w [0:48];
reg [5:0] merger_table_r [0:48];
reg [5:0] column_buffer_w[0:31];
reg [5:0] column_buffer_r[0:31];
reg [5:0] label_index_w, label_index_r;
reg [2:0] state_w, state_r;
reg [3:0] conf_w, conf_r;
reg [1:0] count_w, count_r;
reg [4:0] x_r, x_w, y_r, y_w;
reg [5:0] last_a_r, last_a_w, last_b_r, last_b_w;
reg a_w, a_r, b_w, b_r, next_a_w, next_a_r, next_b_w, next_b_r; // from rom
reg finish_w, finish_r;
reg [6:0] rom_x;
reg [1:0] rom_y;
reg [2:0] rom_y_index;
reg [5:0] merger_w, merger_r, mergee_w, mergee_r;
reg [5:0] a,b;
reg [9:0] sram_a_w, sram_a_r;
reg [7:0] sram_d_r, sram_d_w;
reg sram_wen_r, sram_wen_w;
reg [6:0] rom_a_w, rom_a_r;
reg just_merge_w, just_merge_r;
reg temp_a_w, temp_a_r, temp_b_w, temp_b_r;
reg [7:0] q_even_w, q_even_r, q_odd_w, q_odd_r;
reg wen_even_w, wen_even_r, wen_odd_w, wen_odd_r;
reg [7:0] d_even_w, d_even_r, d_odd_w, d_odd_r;
reg [8:0] a_even_w, a_even_r, a_odd_w, a_odd_r;

assign cen = 0;
assign label = label_index_r + 2;
assign y_plus_2 = y_r + 2;
assign y_r_mod = y_r[2:0];
assign y_plus_2_mod = y_plus_2[2:0];
assign n1 = (x_r == 0)? 0 : column_buffer_r[x_r-1];
assign n2 =  column_buffer_r[x_r];
assign n3 =  (x_r == 31)? 0 : column_buffer_r[x_r+1];
assign n4 = last_a_r;
assign n5 = last_b_r;
assign position = {x_r,y_r};
assign n1_not0 = (n1 != 0);
assign n3_not0 = (n3 != 0);
assign n1_n3_not0 = {n1_not0, n3_not0};
assign finish = finish_r;
assign label_to_read = (count_r == 0)? q_even_r: q_odd_r;
assign label_index_to_read = label_to_read - 2;
assign sram_a = sram_a_r;
assign sram_d = sram_d_r;
assign sram_wen = sram_wen_r;
assign rom_a = rom_a_r;
assign d_even = d_even_r;
assign d_odd = d_odd_r;
assign a_even = a_even_r;
assign a_odd = a_odd_r;
assign wen_even = wen_even_r;
assign wen_odd = wen_odd_r;


integer i,j;

sram_512x8 even (.Q(q_even),.CLK(clk),.CEN(cen),.WEN(wen_even),.A(a_even),.D(d_even));
sram_512x8 odd (.Q(q_odd),.CLK(clk),.CEN(cen),.WEN(wen_odd),.A(a_odd),.D(d_odd));

always@(*) begin

    rom_a_w = rom_a_r;
    sram_a_w = sram_a_r;
    sram_d_w = sram_d_r;
    sram_wen_w = sram_wen_r;
    a_even_w = a_even_r;
    a_odd_w = a_odd_r;
    wen_even_w = 1;
    wen_odd_w = 1;
    d_even_w = d_even_r;
    d_odd_w = d_odd_r;
    for (i = 0 ; i < 64; i = i + 1) begin
        merger_table_w[i] = merger_table_r[i];
    end
    for (i = 0 ; i < 32; i = i + 1) begin
        column_buffer_w[i] = column_buffer_r[i];
    end
    label_index_w = label_index_r;
    state_w = state_r;
    conf_w = conf_r;
    count_w = count_r;
    x_w = x_r;
    y_w = y_r;
    last_a_w = last_a_r;
    last_b_w = last_b_r;
    finish_w = finish_r;
    a_w = a_r;
    b_w = b_r;
    next_a_w = next_a_r;
    next_b_w = next_b_r;
    rom_x = 0;
    rom_y = 0;
    rom_y_index = 0;
    merger_w = merger_r;
    mergee_w = mergee_r;
    a = 0;
    b = 0;
    just_merge_w = 0;
    temp_a_w = temp_a_r;
    temp_b_w = temp_b_r;
    q_even_w = q_even;
    q_odd_w = q_odd;
    case (state_r)
        INIT: begin
            case (count_r)
                2'd0: begin
                    rom_a_w = 0;
                    count_w = count_r + 1;
                end
                2'd1: begin
                    count_w=count_r + 1;
                    rom_a_w = 4;
                end
                2'd2: begin
                    count_w = count_r + 1;
                    rom_a_w = 8;
                    a_w = rom_q[7];
                    b_w = rom_q[6];
                end
                2'd3: begin
                    count_w = 0;
                    next_a_w = rom_q[7];
                    next_b_w = rom_q[6];
                    state_w = FIRST;
                    rom_a_w = 12;
                    if (a_r) begin
                        conf_w =CB;
                    end
                    else begin
                        if (b_r) begin
                            conf_w = CC;
                        end
                        else begin
                            conf_w = CA;
                        end
                    end
                end
            endcase
        end
        FIRST: begin
            merger_table_w[label_index_r] = label;
            case (x_r)
                5'd28: begin
                    rom_x = 0;
                    rom_y_index = 6 - y_r_mod;
                    rom_y = y_plus_2 >> 3;
                end
                5'd29: begin
                    rom_x = 4;
                    rom_y_index = 6 - y_r_mod;
                    rom_y = y_plus_2 >> 3;
                end
                5'd30: begin
                    rom_x = 8;
                    rom_y_index = 6 - y_plus_2_mod;
                    rom_y = y_plus_2 >> 3;
                end
                5'd31: begin
                    rom_x = 12;
                    rom_y_index = 6 - y_plus_2_mod;
                    rom_y = y_plus_2 >> 3;
                end
                default: begin
                    rom_x = ((x_r + 4) << 2);
                    rom_y_index = 6 - y_r_mod;
                    rom_y = y_r >> 3;
                end
            endcase
            rom_a_w = rom_x + rom_y;
            case (conf_r)
                CA: begin
                    a = 0;
                    b = 0;
                    last_a_w = a;
                    last_b_w = b;
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    if (just_merge_r == 0) begin
                        next_a_w = rom_q[rom_y_index+1];
                        next_b_w = rom_q[rom_y_index];
                    end
                    else begin
                        next_a_w = temp_a_r;
                        next_b_w = temp_b_r;
                    end
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = (position >> 1);
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end
                        end
                    end
                    else if (next_a_r) begin
                        conf_w = CB;
                    end
                    else if (next_b_r) begin
                        conf_w = CC;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CC: begin
                    label_index_w = label_index_r + 1;
                    a = 0;
                    b = label;
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    next_a_w = rom_q[rom_y_index+1];
                    next_b_w = rom_q[rom_y_index];
                    if (x_r == 31) begin
                        x_w=0;
                        if (y_r==30) begin
                            y_w=0;
                        end
                        else begin
                            y_w = y_r+2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end

                        end
                    end
                    else if (next_a_r) begin
                        conf_w = CH;
                    end
                    else if (next_b_r) begin
                        conf_w = CI;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CD: begin
                    a = n4;
                    if (b_r) begin
                        b = a;
                    end
                    else begin
                        b = 0;
                    end
                    if (n2 == 0 && n3 != 0) begin
                        state_w = MERGE;
                        merger_w = n4;
                        mergee_w = n3;
                    end
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    if (just_merge_r == 0) begin
                        next_a_w = rom_q[rom_y_index+1];
                        next_b_w = rom_q[rom_y_index];
                    end
                    else begin
                        next_a_w = temp_a_r;
                        next_b_w = temp_b_r;
                    end
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r+1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end
                        end
                    end
                    else if (next_a_r) begin
                        if (n2 != 0) begin
                            conf_w = CD;
                        end
                        else if (n3 != 0) begin
                            conf_w = CE;
                        end
                        else begin
                            conf_w = CF;
                        end
                    end
                    else if (next_b_r) begin
                        conf_w = CG;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CE: begin
                    a = n4;
                    if (b_r) begin
                        b = a;
                    end
                    else begin
                        b = 0;
                    end
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    if (just_merge_r == 0) begin
                        next_a_w = rom_q[rom_y_index+1];
                        next_b_w = rom_q[rom_y_index];
                    end
                    else begin
                        next_a_w = temp_a_r;
                        next_b_w = temp_b_r;
                    end
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end
                        end
                    end
                    else if (next_a_r) begin
                        conf_w = CD;
                    end
                    else if (next_b_r) begin
                        conf_w = CG;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CF: begin
                    a = n4;
                    if (b_r) begin
                        b = a;
                    end
                    else begin
                        b = 0;
                    end
                    if (n3 != 0) begin
                        state_w = MERGE;
                        mergee_w = n3;
                        merger_w = n4;
                    end
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    if (just_merge_r == 0) begin
                        next_a_w = rom_q[rom_y_index+1];
                        next_b_w = rom_q[rom_y_index];
                    end
                    else begin
                        next_a_w = temp_a_r;
                        next_b_w = temp_b_r;
                    end
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r+1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end

                        end
                    end
                    else if (next_a_r) begin
                        if (n3 != 0) begin
                           conf_w = CE;
                        end
                        else begin
                            conf_w = CF;
                        end
                    end
                    else if (next_b_r) begin
                        conf_w = CG;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CG: begin
                    a = 0;
                    b = n4;
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    if (just_merge_r == 0) begin
                        next_a_w = rom_q[rom_y_index+1];
                        next_b_w = rom_q[rom_y_index];
                    end
                    else begin
                        next_a_w = temp_a_r;
                        next_b_w = temp_b_r;
                    end
                    if (x_r == 31) begin
                        x_w=0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end
                        end
                    end
                    else if (next_a_r) begin
                        conf_w = CH;
                    end
                    else if (next_b_r) begin
                        conf_w = CI;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                CH: begin
                    a = n5;
                    if (b_r) begin
                        b = a;
                    end
                    else begin
                        b = 0;
                    end
                    if (n2 != 0) begin
                        state_w = MERGE;
                        mergee_w = n2;
                        merger_w = n5;
                    end
                    else begin
                        case (n1_n3_not0)
                            2'd1: begin // !n1 and n3
                                state_w = MERGE;
                                mergee_w = n3;
                                merger_w = n5;
                            end
                            2'd2: begin
                                state_w = MERGE;
                                mergee_w = n1;
                                merger_w = n5;
                            end
                            2'd3: begin
                                state_w = MERGE1;
                                mergee_w = n1;
                                merger_w = n5;
                            end
                            default: ;
                        endcase
                    end
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    next_a_w = rom_q[rom_y_index+1];
                    next_b_w = rom_q[rom_y_index];
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r+1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end

                        end
                    end
                    else if (next_a_r) begin
                        if (n2 != 0) begin
                           conf_w = CD;
                        end
                        else if (n3 != 0) begin
                            conf_w = CE;
                        end
                        else begin
                            conf_w = CF;
                        end
                    end
                    else if (next_b_r) begin
                        conf_w = CG;
                    end
                    else begin
                        conf_w=CA;
                    end
                end
                CI: begin // CI
                    a = 0;
                    b = n5;
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    next_a_w = rom_q[rom_y_index+1];
                    next_b_w = rom_q[rom_y_index];
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = (position >> 1);
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end

                        end
                    end
                    else if (next_a_r) begin
                        conf_w = CH;
                    end
                    else if (next_b_r) begin
                        conf_w = CI;
                    end
                    else begin
                        conf_w = CA;
                    end
                end
                default: begin
                    if ((n2 == 0) && (n1 != 0) && (n3 != 0)) begin
                        // merge n3 to n1
                        merger_w = n3;
                        mergee_w = n1;
                        state_w = MERGE;
                    end
                    if ((n2 == 0) && (n1 == 0) && (n3 == 0)) begin
                        label_index_w = label_index_r + 1;
                    end
                    if (n2 != 0) begin
                        a = n2;
                    end
                    else if (n3 != 0) begin
                        a = n3;
                    end
                    else if (n1 != 0) begin
                        a = n1;
                    end
                    else begin
                        a = label;
                    end
                    if (b_r) begin
                        b = a;
                    end
                    else begin
                        b = 0;
                    end
                    if (x_r == 31) begin
                        last_a_w = 0;
                        last_b_w = 0;
                    end
                    else begin
                        last_a_w = a;
                        last_b_w = b;
                    end
                    if (x_r == 31) begin
                        column_buffer_w[31] = b;
                        column_buffer_w[30] = last_b_r;
                    end
                    else if (x_r != 0) begin
                        column_buffer_w[x_r-1] = last_b_r;
                    end
                    a_w = next_a_r;
                    b_w = next_b_r;
                    next_a_w = rom_q[rom_y_index+1];
                    next_b_w = rom_q[rom_y_index];
                    if (x_r == 31) begin
                        x_w = 0;
                        if (y_r == 30) begin
                            y_w = 0;
                        end
                        else begin
                            y_w = y_r + 2;
                        end
                    end
                    else begin
                        x_w = x_r + 1;
                    end
                    if (y_r == 30 && x_r == 31) begin
                        state_w = SECOND1;
                    end
                    wen_even_w = 0;
                    wen_odd_w = 0;
                    a_even_w = position >> 1;
                    a_odd_w = position >> 1;
                    d_even_w = a;
                    d_odd_w = b;
                    // configuration transition
                    if (x_r == 31) begin
                        if (next_a_r) begin
                            conf_w = CB;
                        end
                        else begin
                            if (next_b_r) begin
                                conf_w = CC;
                            end
                            else begin
                                conf_w = CA;
                            end
                        end
                    end
                    else if (next_a_r) begin
                        if (n2 != 0) begin
                            conf_w = CD;
                        end
                        else if (n3 != 0) begin
                            conf_w = CE;
                        end
                        else begin
                            conf_w = CF;
                        end
                    end
                    else if (next_b_r) begin
                        conf_w = CG;
                    end
                    else begin
                        conf_w = CA;
                    end
                end

            endcase
        end
        MERGE: begin
            state_w = FIRST;
            just_merge_w = 1;
            for (i = 0 ; i < 64 ;i = i + 1) begin
                if (merger_table_r[i] == mergee_r) begin
                    merger_table_w[i] = merger_r;
                end
            end
            for (i = 0 ;i < 32 ;i = i + 1) begin
                if (column_buffer_r[i] == mergee_r) begin
                    column_buffer_w[i] = merger_r;
                end
            end
            case (x_r)
            5'd29: begin
                rom_x = 0;
                rom_y_index = 6 - y_r_mod;
                rom_y = y_plus_2 >> 3;
            end
            5'd30: begin
                rom_x = 4;
                rom_y_index = 6- y_plus_2_mod;
                rom_y = y_plus_2 >> 3;
            end
            5'd31: begin
                rom_x = 8;
                rom_y_index = 6 - y_plus_2_mod;
                rom_y = y_plus_2 >> 3;
            end
            5'd0: begin
                rom_x = 12;
                rom_y_index = 6-y_plus_2_mod;
                rom_y = y_plus_2 >> 3;
            end
            default: begin
                rom_x = ((x_r + 3) << 2);
                rom_y_index = 6 - y_r_mod;
                rom_y = y_r >> 3;
            end
            endcase
            rom_a_w = rom_x+rom_y;
            temp_a_w = rom_q[rom_y_index+1];
            temp_b_w = rom_q[rom_y_index];
        end
        SECOND1: begin
            x_w = 0;
            y_w = 0;
            case (count_r)
                2'd0: begin
                    a_even_w = 0;
                    count_w = count_r + 1;
                end
                2'd1: begin
                    a_odd_w = 0;
                    count_w = count_r + 1;
                end
                default: begin
                    a_even_w = 1;
                    count_w = 0;
                    state_w = SECOND2;
                end
            endcase
        end
        SECOND2: begin
            case (count_r)
                2'd0: begin
                    count_w = 1;
                    a_odd_w = (position >> 1) + 1;
                    sram_a_w = position;
                    sram_d_w = (q_even_r == 0) ? 0 : merger_table_r[label_index_to_read];
                    sram_wen_w = 0;
                    if (y_r == 31) begin
                        y_w = 0;
                        x_w = x_r + 1;
                    end
                    else begin
                        y_w = y_r + 1;
                    end
                end
                2'd1: begin
                    count_w = 0;
                    a_even_w = (position >> 1) + 2;
                    sram_a_w = position;
                    sram_d_w = (q_odd_r == 0) ? 0 : merger_table_r[label_index_to_read];
                    sram_wen_w = 0;
                    if (y_r == 31) begin
                        y_w = 0;
                        x_w = x_r + 1;
                    end
                    else begin
                        y_w = y_r + 1;
                    end
                    if (y_r == 31 && x_r == 31) begin
                        count_w = 3;
                    end
                end
                2'd3: begin
                    finish_w = 1;
                end
            endcase
        end
        MERGE1: begin
            state_w = MERGE2;
            for (i = 0 ; i < 64; i = i + 1) begin
                if (merger_table_r[i] == mergee_r) begin
                    merger_table_w[i] = merger_r;
                end
            end
            for (i = 0 ; i < 32; i = i + 1) begin
                if (column_buffer_r[i] == mergee_r) begin
                    column_buffer_w[i] = merger_r;
                end
            end
            mergee_w = n2;
            merger_w = column_buffer_r[x_r-2];
            if (x_r == 31) begin
                rom_x = 0;
                rom_y = y_plus_2 >> 3;
            end
            else begin
                rom_x = ((x_r+1) << 2);
                rom_y = y_r >> 3;
            end
            rom_a_w = rom_x + rom_y;
        end
        MERGE2: begin
            state_w = MERGE3;
            for (i = 0 ; i < 64; i = i + 1) begin
                if (merger_table_r[i] == mergee_r) begin
                    merger_table_w[i] = merger_r;
                end
            end
            for (i = 0; i < 32; i = i + 1) begin
                if (column_buffer_r[i] == mergee_r) begin
                    column_buffer_w[i] = merger_r;
                end
            end
            if (x_r == 30) begin
                rom_x = 0;
                rom_y = y_plus_2 >> 3;
            end
            else if (x_r == 31) begin
                rom_x = 4;
                rom_y = y_plus_2 >> 3;
            end
            else begin
                rom_x = ((x_r + 2) << 2);
                rom_y = y_r >> 3;
            end
            rom_a_w = rom_x + rom_y;
        end
        default: begin // MERGE3
            state_w = FIRST;
            case (x_r)
            5'd29: begin
                rom_x = 0;
                rom_y_index = 6 - y_r_mod;
                rom_y = y_plus_2 >> 3;
            end
            5'd30: begin
                rom_x = 4;
                rom_y_index = 6 - y_r_mod;
                rom_y = y_plus_2 >> 3;
            end
            5'd31: begin
                rom_x = 8;
                rom_y_index = 6 - y_plus_2_mod;
                rom_y = y_plus_2 >> 3;
            end
            default: begin
                rom_x = ((x_r + 3) << 2);
                rom_y_index = 6 - y_r_mod;
                rom_y = y_r >> 3;
            end
            endcase
            rom_a_w = rom_x + rom_y;
            next_a_w = rom_q[rom_y_index+1];
            next_b_w = rom_q[rom_y_index];
        end
    endcase
end
always@(posedge clk or posedge reset) begin
    if (reset) begin
        for (j = 0 ; j < 64; j = j + 1) begin
            merger_table_r[j] <= 0;
        end
        for (j = 0; j < 32; j = j + 1) begin
            column_buffer_r[j] <= 0;
        end
        label_index_r <= 0;
        state_r <= 0;
        conf_r <= 0;
        count_r <= 0;
        x_r <= 0;
        y_r <= 0;
        last_a_r <= 0;
        last_b_r <= 0;
        finish_r <= 0;
        a_r <= 0;
        b_r <= 0;
        next_a_r <= 0;
        next_b_r <= 0;
        merger_r <= 0;
        mergee_r <= 0;
        sram_wen_r <= 0;
        sram_d_r <= 0;
        sram_a_r <= 0;
        rom_a_r <= 0;
        just_merge_r <= 0;
        temp_a_r <= 0;
        temp_b_r <= 0;
        q_even_r <= 0;
        q_odd_r <= 0;
        wen_even_r <= 0;
        wen_odd_r <= 0;
        d_even_r <= 0;
        d_odd_r <= 0;
        a_even_r <= 0;
        a_odd_r <= 0;
    end
    else begin
        for (j = 0; j < 64; j = j + 1) begin
            merger_table_r[j] <= merger_table_w[j];
        end
        for (j =0;j < 32; j = j + 1) begin
            column_buffer_r[j] <= column_buffer_w[j];
        end
        label_index_r <= label_index_w;
        state_r <= state_w;
        conf_r <= conf_w;
        count_r <= count_w;
        x_r <= x_w;
        y_r <= y_w;
        last_a_r <= last_a_w;
        last_b_r <= last_b_w;
        finish_r <= finish_w;
        a_r <= a_w;
        b_r <= b_w;
        next_a_r <= next_a_w;
        next_b_r <= next_b_w;
        merger_r <= merger_w;
        mergee_r <= mergee_w;
        sram_a_r <= sram_a_w;
        sram_d_r <= sram_d_w;
        sram_wen_r <= sram_wen_w;
        rom_a_r <= rom_a_w;
        just_merge_r <= just_merge_w;
        temp_a_r <= temp_a_w;
        temp_b_r <= temp_b_w;
        q_even_r <= q_even_w;
        q_odd_r <= q_odd_w;
        wen_even_r <= wen_even_w;
        wen_odd_r <= wen_odd_w;
        d_even_r <= d_even_w;
        d_odd_r <= d_odd_w;
        a_even_r <= a_even_w;
        a_odd_r <= a_odd_w;
    end
end

endmodule
