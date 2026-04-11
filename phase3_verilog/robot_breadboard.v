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
    wire [3:0] move_dir_lines;

    wire [7:0] speed_q;
    wire [7:0] speed_d;
    wire speed_en;

    wire [1:0] heading_q;
    wire [1:0] heading_d;
    wire heading_en;

    wire [1:0] led_color_q;
    wire [1:0] led_color_d;
    wire led_color_en;
    wire [1:0] led_color_raw;
    wire led_color_bit0;
    wire led_color_bit1;

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
    wire [7:0] speed_operand;
    wire speed_cout_0;

    wire [1:0] heading_plus_one;
    wire heading_cout;

    wire [1:0] led_color_sel0;

    wire [7:0] speed_neg;

    wire [7:0] x_move_operand;
    wire [7:0] y_move_operand;
    wire [7:0] x_move_next;
    wire [7:0] y_move_next;
    wire x_use_neg;
    wire y_use_neg;
    wire x_move_en;
    wire y_move_en;
    wire move_cmd;

    wire reserved_opcode;

    decoder4to16 u_opcode_decoder (
        .in(opcode),
        .out(opcode_lines)
    );

    demux1to4 u_move_demux (
        .in(move_cmd),
        .sel(heading_q),
        .out(move_dir_lines)
    );

    or2 u_speed_command_or (
        .a(opcode_lines[0]),
        .b(opcode_lines[1]),
        .y(speed_en)
    );

    mux2_1 #(.WIDTH(8)) u_speed_operand_mux (
        .d0(data_in_a),
        .d1(8'hFF),
        .sel(opcode_lines[1]),
        .y(speed_operand)
    );

    adder_n #(.WIDTH(8)) u_speed_update (
        .a(speed_q),
        .b(speed_operand),
        .cin(1'b0),
        .sum(speed_plus_one),
        .cout(speed_cout_0)
    );

    assign speed_d = speed_plus_one;

    adder_n #(.WIDTH(2)) u_heading_turn (
        .a(heading_q),
        .b(heading_in),
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
        .y(led_color_raw)
    );

    splitter2 u_led_color_splitter (
        .in(led_color_raw),
        .bit0(led_color_bit0),
        .bit1(led_color_bit1),
        .out(led_color_d)
    );

    or4 u_led_color_enable_or (
        .a(opcode_lines[3]),
        .b(opcode_lines[4]),
        .c(opcode_lines[5]),
        .d(1'b0),
        .y(led_color_en)
    );

    mux2_1 #(.WIDTH(1)) u_led_signal_mux (
        .d0(1'b1),
        .d1(1'b0),
        .sel(opcode_lines[7]),
        .y(led_signal_d)
    );

    or2 u_led_signal_enable_or (
        .a(opcode_lines[6]),
        .b(opcode_lines[7]),
        .y(led_signal_en)
    );

    mux2_1 #(.WIDTH(1)) u_fire_mux (
        .d0(1'b1),
        .d1(1'b0),
        .sel(opcode_lines[9]),
        .y(fire_d)
    );

    or2 u_fire_enable_or (
        .a(opcode_lines[8]),
        .b(opcode_lines[9]),
        .y(fire_en)
    );

    twos_complement_n #(.WIDTH(8)) u_speed_neg (
        .in(speed_q),
        .out(speed_neg)
    );

    or2 u_move_command_or (
        .a(opcode_lines[10]),
        .b(opcode_lines[11]),
        .y(move_cmd)
    );

    xor2 u_x_signed_select (
        .a(opcode_lines[11]),
        .b(move_dir_lines[3]),
        .y(x_use_neg)
    );

    xor2 u_y_signed_select (
        .a(opcode_lines[11]),
        .b(move_dir_lines[2]),
        .y(y_use_neg)
    );

    or2 u_x_move_enable_or (
        .a(move_dir_lines[1]),
        .b(move_dir_lines[3]),
        .y(x_move_en)
    );

    or2 u_y_move_enable_or (
        .a(move_dir_lines[0]),
        .b(move_dir_lines[2]),
        .y(y_move_en)
    );

    mux2_1 #(.WIDTH(8)) u_x_operand_mux (
        .d0(speed_q),
        .d1(speed_neg),
        .sel(x_use_neg),
        .y(x_move_operand)
    );

    mux2_1 #(.WIDTH(8)) u_y_operand_mux (
        .d0(speed_q),
        .d1(speed_neg),
        .sel(y_use_neg),
        .y(y_move_operand)
    );

    adder_n #(.WIDTH(8)) u_x_move_adder (
        .a(x_q),
        .b(x_move_operand),
        .cin(1'b0),
        .sum(x_move_next),
        .cout()
    );

    mux2_1 #(.WIDTH(8)) u_x_move_mux (
        .d0(x_q),
        .d1(x_move_next),
        .sel(x_move_en),
        .y(x_d)
    );

    assign x_en = x_move_en;

    adder_n #(.WIDTH(8)) u_y_move_adder (
        .a(y_q),
        .b(y_move_operand),
        .cin(1'b0),
        .sum(y_move_next),
        .cout()
    );

    mux2_1 #(.WIDTH(8)) u_y_move_mux (
        .d0(y_q),
        .d1(y_move_next),
        .sel(y_move_en),
        .y(y_d)
    );

    assign y_en = y_move_en;

    adder_n #(.WIDTH(2)) u_weapon_cycle (
        .a(weapon_q),
        .b(heading_in),
        .cin(1'b0),
        .sum(weapon_d),
        .cout(weapon_cout)
    );

    assign weapon_en = opcode_lines[12];

    assign feedback_d = {x_q, y_q};
    assign mem32_d = {opcode, data_in_a, data_in_b, weapon_q, feedback_q[15:6]};

    or4 u_reserved_opcode_or (
        .a(opcode_lines[13]),
        .b(opcode_lines[14]),
        .c(opcode_lines[15]),
        .d(1'b0),
        .y(reserved_opcode)
    );

    assign status_d = reserved_opcode ? 8'hE1 : 8'h00;

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
