module robot_breadboard (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    input wire [7:0] data_in_a,
    input wire [7:0] data_in_b,
    input wire [1:0] heading_in,
    output wire [7:0] speed,
    output wire [1:0] heading,
    output wire [1:0] led_color,
    output wire led_signal,
    output wire fire_bullets_signal,
    output wire [7:0] x_position,
    output wire [7:0] y_position,
    output wire [1:0] weapon_type,
    output wire [7:0] status,
    output wire [15:0] feedback_loop,
    output wire [31:0] memory_reg32
);
    wire [15:0] opcode_lines;
    wire [3:0] mode_lines;

    wire heading_bit0;
    wire heading_bit1;
    wire [1:0] heading_split_recombined;

    wire [7:0] speed_q;
    wire [7:0] speed_d;
    wire speed_en;

    wire [1:0] heading_q;
    wire [1:0] heading_d;
    wire heading_en;

    wire [1:0] led_color_q;
    wire [1:0] led_color_d;
    wire led_color_en;

    wire [0:0] led_signal_q;
    wire [0:0] led_signal_d;
    wire led_signal_en;

    wire [0:0] fire_q;
    wire [0:0] fire_d;
    wire fire_en;

    wire [7:0] x_q;
    wire [7:0] x_d;
    wire x_en;

    wire [7:0] y_q;
    wire [7:0] y_d;
    wire y_en;

    wire [1:0] weapon_q;
    wire [1:0] weapon_d;
    wire weapon_en;
    wire weapon_cout;

    wire [15:0] feedback_q;
    wire [15:0] feedback_d;

    wire [31:0] mem32_q;
    wire [31:0] mem32_d;

    wire [7:0] status_q;
    wire [7:0] status_d;

    wire [7:0] speed_plus_one;
    wire [7:0] speed_minus_one;
    wire [7:0] one_neg;
    wire speed_cout_0;
    wire speed_cout_1;

    wire [1:0] heading_plus_one;
    wire heading_cout;

    wire [1:0] led_color_sel0;

    wire [7:0] x_neg_operand;
    wire [7:0] y_neg_operand;

    wire [7:0] x_add_operand;
    wire [7:0] x_sub_operand;
    wire [7:0] x_add_feedback;
    wire [7:0] x_pair_low;
    wire [7:0] x_pair_high;
    wire [7:0] x_mode_selected;
    wire x_cout_0;
    wire x_cout_1;
    wire x_cout_2;

    wire [7:0] y_add_operand;
    wire [7:0] y_sub_operand;
    wire [7:0] y_add_feedback;
    wire [7:0] y_pair_low;
    wire [7:0] y_pair_high;
    wire [7:0] y_mode_selected;
    wire y_cout_0;
    wire y_cout_1;
    wire y_cout_2;

    wire reserved_opcode;
    wire speed_dec_at_zero;
    wire hold_mode_move;

    decoder4to16 u_opcode_decoder (
        .in(opcode),
        .out(opcode_lines)
    );

    splitter2 u_heading_splitter (
        .in(heading_in),
        .bit0(heading_bit0),
        .bit1(heading_bit1),
        .out(heading_split_recombined)
    );

    decoder2to4 u_mode_decoder (
        .in(heading_split_recombined),
        .out(mode_lines)
    );

    twos_complement_n #(.WIDTH(8)) u_one_neg (
        .in(8'h01),
        .out(one_neg)
    );

    adder_n #(.WIDTH(8)) u_speed_inc (
        .a(speed_q),
        .b(8'h01),
        .cin(1'b0),
        .sum(speed_plus_one),
        .cout(speed_cout_0)
    );

    adder_n #(.WIDTH(8)) u_speed_dec (
        .a(speed_q),
        .b(one_neg),
        .cin(1'b0),
        .sum(speed_minus_one),
        .cout(speed_cout_1)
    );

    mux2_1 #(.WIDTH(8)) u_speed_mux (
        .d0(speed_plus_one),
        .d1(speed_minus_one),
        .sel(opcode_lines[1]),
        .y(speed_d)
    );

    assign speed_en = opcode_lines[0] | opcode_lines[1];

    adder_n #(.WIDTH(2)) u_heading_turn (
        .a(heading_q),
        .b(2'b01),
        .cin(1'b0),
        .sum(heading_plus_one),
        .cout(heading_cout)
    );

    assign heading_d = heading_plus_one;
    assign heading_en = opcode_lines[2];

    mux2_1 #(.WIDTH(2)) u_led_color_mux0 (
        .d0(2'b01),
        .d1(2'b10),
        .sel(opcode_lines[4]),
        .y(led_color_sel0)
    );

    mux2_1 #(.WIDTH(2)) u_led_color_mux1 (
        .d0(led_color_sel0),
        .d1(2'b11),
        .sel(opcode_lines[5]),
        .y(led_color_d)
    );

    assign led_color_en = opcode_lines[3] | opcode_lines[4] | opcode_lines[5];

    assign led_signal_d = {opcode_lines[6]};
    assign led_signal_en = opcode_lines[6] | opcode_lines[7];

    assign fire_d = {opcode_lines[8]};
    assign fire_en = opcode_lines[8] | opcode_lines[9];

    twos_complement_n #(.WIDTH(8)) u_x_neg (
        .in(data_in_a),
        .out(x_neg_operand)
    );

    adder_n #(.WIDTH(8)) u_x_add_operand (
        .a(x_q),
        .b(data_in_a),
        .cin(1'b0),
        .sum(x_add_operand),
        .cout(x_cout_0)
    );

    adder_n #(.WIDTH(8)) u_x_sub_operand (
        .a(x_q),
        .b(x_neg_operand),
        .cin(1'b0),
        .sum(x_sub_operand),
        .cout(x_cout_1)
    );

    adder_n #(.WIDTH(8)) u_x_add_feedback (
        .a(x_q),
        .b(feedback_q[7:0]),
        .cin(1'b0),
        .sum(x_add_feedback),
        .cout(x_cout_2)
    );

    mux2_1 #(.WIDTH(8)) u_x_pair_low (
        .d0(x_add_operand),
        .d1(x_sub_operand),
        .sel(heading_bit0),
        .y(x_pair_low)
    );

    mux2_1 #(.WIDTH(8)) u_x_pair_high (
        .d0(x_add_feedback),
        .d1(x_q),
        .sel(heading_bit0),
        .y(x_pair_high)
    );

    mux2_1 #(.WIDTH(8)) u_x_mode_mux (
        .d0(x_pair_low),
        .d1(x_pair_high),
        .sel(heading_bit1),
        .y(x_mode_selected)
    );

    assign x_d = x_mode_selected;
    assign x_en = opcode_lines[10];

    twos_complement_n #(.WIDTH(8)) u_y_neg (
        .in(data_in_b),
        .out(y_neg_operand)
    );

    adder_n #(.WIDTH(8)) u_y_add_operand (
        .a(y_q),
        .b(data_in_b),
        .cin(1'b0),
        .sum(y_add_operand),
        .cout(y_cout_0)
    );

    adder_n #(.WIDTH(8)) u_y_sub_operand (
        .a(y_q),
        .b(y_neg_operand),
        .cin(1'b0),
        .sum(y_sub_operand),
        .cout(y_cout_1)
    );

    adder_n #(.WIDTH(8)) u_y_add_feedback (
        .a(y_q),
        .b(feedback_q[15:8]),
        .cin(1'b0),
        .sum(y_add_feedback),
        .cout(y_cout_2)
    );

    mux2_1 #(.WIDTH(8)) u_y_pair_low (
        .d0(y_add_operand),
        .d1(y_sub_operand),
        .sel(heading_bit0),
        .y(y_pair_low)
    );

    mux2_1 #(.WIDTH(8)) u_y_pair_high (
        .d0(y_add_feedback),
        .d1(y_q),
        .sel(heading_bit0),
        .y(y_pair_high)
    );

    mux2_1 #(.WIDTH(8)) u_y_mode_mux (
        .d0(y_pair_low),
        .d1(y_pair_high),
        .sel(heading_bit1),
        .y(y_mode_selected)
    );

    assign y_d = y_mode_selected;
    assign y_en = opcode_lines[11];

    adder_n #(.WIDTH(2)) u_weapon_cycle (
        .a(weapon_q),
        .b(2'b01),
        .cin(1'b0),
        .sum(weapon_d),
        .cout(weapon_cout)
    );

    assign weapon_en = opcode_lines[12];

    assign feedback_d = {x_q, y_q};
    assign mem32_d = {opcode, data_in_a, data_in_b, weapon_q, feedback_q[15:6]};

    assign reserved_opcode = opcode_lines[13] | opcode_lines[14] | opcode_lines[15];
    assign speed_dec_at_zero = opcode_lines[1] & (speed_q == 8'h00);
    assign hold_mode_move = (opcode_lines[10] | opcode_lines[11]) & mode_lines[3];

    assign status_d = reserved_opcode ? 8'hE1 :
                      speed_dec_at_zero ? 8'h21 :
                      hold_mode_move ? 8'h31 :
                      8'h00;

    reg_n #(.WIDTH(8)) u_speed_reg (
        .clk(clk),
        .reset(reset),
        .en(speed_en),
        .d(speed_d),
        .q(speed_q)
    );

    reg_n #(.WIDTH(2)) u_heading_reg (
        .clk(clk),
        .reset(reset),
        .en(heading_en),
        .d(heading_d),
        .q(heading_q)
    );

    reg_n #(.WIDTH(2)) u_led_color_reg (
        .clk(clk),
        .reset(reset),
        .en(led_color_en),
        .d(led_color_d),
        .q(led_color_q)
    );

    reg_n #(.WIDTH(1)) u_led_signal_reg (
        .clk(clk),
        .reset(reset),
        .en(led_signal_en),
        .d(led_signal_d),
        .q(led_signal_q)
    );

    reg_n #(.WIDTH(1)) u_fire_reg (
        .clk(clk),
        .reset(reset),
        .en(fire_en),
        .d(fire_d),
        .q(fire_q)
    );

    reg_n #(.WIDTH(8)) u_x_reg (
        .clk(clk),
        .reset(reset),
        .en(x_en),
        .d(x_d),
        .q(x_q)
    );

    reg_n #(.WIDTH(8)) u_y_reg (
        .clk(clk),
        .reset(reset),
        .en(y_en),
        .d(y_d),
        .q(y_q)
    );

    reg_n #(.WIDTH(2)) u_weapon_reg (
        .clk(clk),
        .reset(reset),
        .en(weapon_en),
        .d(weapon_d),
        .q(weapon_q)
    );

    reg_n #(.WIDTH(16)) u_feedback_reg (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(feedback_d),
        .q(feedback_q)
    );

    reg_n #(.WIDTH(32)) u_memory32_reg (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(mem32_d),
        .q(mem32_q)
    );

    reg_n #(.WIDTH(8)) u_status_reg (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(status_d),
        .q(status_q)
    );

    assign speed = speed_q;
    assign heading = heading_q;
    assign led_color = led_color_q;
    assign led_signal = led_signal_q[0];
    assign fire_bullets_signal = fire_q[0];
    assign x_position = x_q;
    assign y_position = y_q;
    assign weapon_type = weapon_q;
    assign status = status_q;
    assign feedback_loop = feedback_q;
    assign memory_reg32 = mem32_q;
endmodule
