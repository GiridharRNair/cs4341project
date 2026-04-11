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
    wire [3:0] heading_dir_lines;

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
    wire [7:0] speed_operand;
    wire speed_cout_0;

    wire [1:0] heading_plus_one;
    wire heading_cout;

    wire [1:0] led_color_sel0;

    wire [7:0] speed_neg;

    wire [7:0] x_delta_fwd;
    wire [7:0] x_delta_bwd;
    wire [7:0] y_delta_fwd;
    wire [7:0] y_delta_bwd;
    wire [7:0] x_forward_next;
    wire [7:0] x_backward_next;
    wire [7:0] y_forward_next;
    wire [7:0] y_backward_next;
    wire x_cout_0;
    wire x_cout_1;
    wire y_cout_0;
    wire y_cout_1;

    wire reserved_opcode;

    decoder4to16 u_opcode_decoder (
        .in(opcode),
        .out(opcode_lines)
    );

    decoder2to4 u_heading_decoder (
        .in(heading_q),
        .out(heading_dir_lines)
    );

    mux2_1 #(.WIDTH(8)) u_speed_operand_mux (
        .d0(data_in_a),
        .d1(data_in_b),
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

    assign speed_en = opcode_lines[0] | opcode_lines[1];

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
        .y(led_color_d)
    );

    assign led_color_en = opcode_lines[3] | opcode_lines[4] | opcode_lines[5];

    assign led_signal_d = {opcode_lines[6]};
    assign led_signal_en = opcode_lines[6] | opcode_lines[7];

    assign fire_d = {opcode_lines[8]};
    assign fire_en = opcode_lines[8] | opcode_lines[9];

    twos_complement_n #(.WIDTH(8)) u_speed_neg (
        .in(speed_q),
        .out(speed_neg)
    );

    assign x_delta_fwd = ({8{heading_dir_lines[1]}} & speed_q) |
                         ({8{heading_dir_lines[3]}} & speed_neg);
    assign x_delta_bwd = ({8{heading_dir_lines[1]}} & speed_neg) |
                         ({8{heading_dir_lines[3]}} & speed_q);
    assign y_delta_fwd = ({8{heading_dir_lines[0]}} & speed_q) |
                         ({8{heading_dir_lines[2]}} & speed_neg);
    assign y_delta_bwd = ({8{heading_dir_lines[0]}} & speed_neg) |
                         ({8{heading_dir_lines[2]}} & speed_q);

    adder_n #(.WIDTH(8)) u_x_forward (
        .a(x_q),
        .b(x_delta_fwd),
        .cin(1'b0),
        .sum(x_forward_next),
        .cout(x_cout_0)
    );

    adder_n #(.WIDTH(8)) u_x_backward (
        .a(x_q),
        .b(x_delta_bwd),
        .cin(1'b0),
        .sum(x_backward_next),
        .cout(x_cout_1)
    );

    mux2_1 #(.WIDTH(8)) u_x_move_mux (
        .d0(x_forward_next),
        .d1(x_backward_next),
        .sel(opcode_lines[11]),
        .y(x_d)
    );

    assign x_en = opcode_lines[10] | opcode_lines[11];

    adder_n #(.WIDTH(8)) u_y_forward (
        .a(y_q),
        .b(y_delta_fwd),
        .cin(1'b0),
        .sum(y_forward_next),
        .cout(y_cout_0)
    );

    adder_n #(.WIDTH(8)) u_y_backward (
        .a(y_q),
        .b(y_delta_bwd),
        .cin(1'b0),
        .sum(y_backward_next),
        .cout(y_cout_1)
    );

    mux2_1 #(.WIDTH(8)) u_y_move_mux (
        .d0(y_forward_next),
        .d1(y_backward_next),
        .sel(opcode_lines[11]),
        .y(y_d)
    );

    assign y_en = opcode_lines[10] | opcode_lines[11];

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

    assign reserved_opcode = opcode_lines[13] | opcode_lines[14] | opcode_lines[15];

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
