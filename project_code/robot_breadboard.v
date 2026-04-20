module robot_breadboard (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    output wire [7:0] speed,
    output wire [1:0] heading,
    output wire [1:0] led_color,
    output wire led_signal,
    output wire fire_signal,
    output wire [7:0] x_position,
    output wire [7:0] y_position,
    output wire [1:0] weapon_type,
    output wire [7:0] status_code,
    output wire [15:0] feedback_loop,
    output wire [31:0] memory_snapshot
);
    wire [1:0] heading_input = 2'b01;

    wire [15:0] opcode_lines;
    wire [3:0] movement_direction_lines;

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

    wire [0:0] fire_signal_q;
    wire [0:0] fire_signal_d;
    wire fire_signal_en;

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

    wire [31:0] memory_snapshot_q;
    wire [31:0] memory_snapshot_d;

    wire [7:0] status_code_q;
    wire [7:0] status_code_d;

    wire [7:0] speed_next;
    wire [7:0] speed_operand;
    wire speed_cout_0;

    wire [1:0] heading_next;
    wire heading_cout;

    wire [1:0] led_color_sel0;

    wire [7:0] speed_negated;

    wire [7:0] x_movement_operand;
    wire [7:0] y_movement_operand;
    wire [7:0] x_position_next;
    wire [7:0] y_position_next;
    wire x_sign_select;
    wire y_sign_select;
    wire x_movement_enable;
    wire y_movement_enable;
    wire move_command;

    wire reserved_opcode_signal;

    decoder4to16 Opcode_Decoder (
        .in(opcode),
        .out(opcode_lines)
    );

    demux1to4 Movement_Demultiplexer (
        .in(move_command),
        .sel(heading_q),
        .out(movement_direction_lines)
    );

    or2 Speed_Command_Or (
        .a(opcode_lines[0]),
        .b(opcode_lines[1]),
        .y(speed_en)
    );

    mux2_1 #(.WIDTH(8)) Speed_Operand_Mux (
        .d0(8'h01),
        .d1(8'hFF),
        .sel(opcode_lines[1]),
        .y(speed_operand)
    );

    adder_n #(.WIDTH(8)) Speed_Update_Adder (
        .a(speed_q),
        .b(speed_operand),
        .cin(1'b0),
        .sum(speed_next),
        .cout(speed_cout_0)
    );

    assign speed_d = speed_next;

    adder_n #(.WIDTH(2)) Heading_Update_Adder (
        .a(heading_q),
        .b(heading_input),
        .cin(1'b0),
        .sum(heading_next),
        .cout(heading_cout)
    );

    assign heading_d = heading_next;
    assign heading_en = opcode_lines[2];

    mux2_1 #(.WIDTH(2)) LED_Color_Mux0 (
        .d0(2'b01),
        .d1(2'b10),
        .sel(opcode_lines[4]),
        .y(led_color_sel0)
    );

    mux2_1 #(.WIDTH(2)) LED_Color_Mux1 (
        .d0(led_color_sel0),
        .d1(2'b11),
        .sel(opcode_lines[5]),
        .y(led_color_raw)
    );

    splitter2 LED_Color_Splitter (
        .in(led_color_raw),
        .bit0(led_color_bit0),
        .bit1(led_color_bit1),
        .out(led_color_d)
    );

    or4 LED_Color_Enable_Or (
        .a(opcode_lines[3]),
        .b(opcode_lines[4]),
        .c(opcode_lines[5]),
        .d(1'b0),
        .y(led_color_en)
    );

    mux2_1 #(.WIDTH(1)) LED_Signal_Mux (
        .d0(1'b1),
        .d1(1'b0),
        .sel(opcode_lines[7]),
        .y(led_signal_d)
    );

    or2 LED_Signal_Enable_Or (
        .a(opcode_lines[6]),
        .b(opcode_lines[7]),
        .y(led_signal_en)
    );

    mux2_1 #(.WIDTH(1)) Fire_Mux (
        .d0(1'b1),
        .d1(1'b0),
        .sel(opcode_lines[9]),
        .y(fire_signal_d)
    );

    or2 Fire_Enable_Or (
        .a(opcode_lines[8]),
        .b(opcode_lines[9]),
        .y(fire_signal_en)
    );

    twos_complement_n #(.WIDTH(8)) Speed_Negation_Block (
        .in(speed_q),
        .out(speed_negated)
    );

    or2 Move_Command_Or (
        .a(opcode_lines[10]),
        .b(opcode_lines[11]),
        .y(move_command)
    );

    xor2 X_Sign_Selector (
        .a(opcode_lines[11]),
        .b(movement_direction_lines[3]),
        .y(x_sign_select)
    );

    xor2 Y_Sign_Selector (
        .a(opcode_lines[11]),
        .b(movement_direction_lines[2]),
        .y(y_sign_select)
    );

    or2 X_Movement_Enable_Or (
        .a(movement_direction_lines[1]),
        .b(movement_direction_lines[3]),
        .y(x_movement_enable)
    );

    or2 Y_Movement_Enable_Or (
        .a(movement_direction_lines[0]),
        .b(movement_direction_lines[2]),
        .y(y_movement_enable)
    );

    mux2_1 #(.WIDTH(8)) X_Operand_Mux (
        .d0(speed_q),
        .d1(speed_negated),
        .sel(x_sign_select),
        .y(x_movement_operand)
    );

    mux2_1 #(.WIDTH(8)) Y_Operand_Mux (
        .d0(speed_q),
        .d1(speed_negated),
        .sel(y_sign_select),
        .y(y_movement_operand)
    );

    adder_n #(.WIDTH(8)) X_Move_Adder (
        .a(x_q),
        .b(x_movement_operand),
        .cin(1'b0),
        .sum(x_position_next),
        .cout()
    );

    mux2_1 #(.WIDTH(8)) X_Move_Mux (
        .d0(x_q),
        .d1(x_position_next),
        .sel(x_movement_enable),
        .y(x_d)
    );

    assign x_en = x_movement_enable;

    adder_n #(.WIDTH(8)) Y_Move_Adder (
        .a(y_q),
        .b(y_movement_operand),
        .cin(1'b0),
        .sum(y_position_next),
        .cout()
    );

    mux2_1 #(.WIDTH(8)) Y_Move_Mux (
        .d0(y_q),
        .d1(y_position_next),
        .sel(y_movement_enable),
        .y(y_d)
    );

    assign y_en = y_movement_enable;

    adder_n #(.WIDTH(2)) Weapon_Cycle_Adder (
        .a(weapon_q),
        .b(heading_input),
        .cin(1'b0),
        .sum(weapon_d),
        .cout(weapon_cout)
    );

    assign weapon_en = opcode_lines[12];

    assign feedback_d = {x_q, y_q};
    assign memory_snapshot_d = {opcode, heading_input, weapon_q, status_code_q, feedback_q};

    or4 Reserved_Opcode_Or (
        .a(opcode_lines[13]),
        .b(opcode_lines[14]),
        .c(opcode_lines[15]),
        .d(1'b0),
        .y(reserved_opcode_signal)
    );

    assign status_code_d = reserved_opcode_signal ? 8'hE1 : 8'h00;

    reg_n #(.WIDTH(8)) Speed_Register (
        .clk(clk),
        .reset(reset),
        .en(speed_en),
        .d(speed_d),
        .q(speed_q)
    );

    reg_n #(.WIDTH(2)) Heading_Register (
        .clk(clk),
        .reset(reset),
        .en(heading_en),
        .d(heading_d),
        .q(heading_q)
    );

    reg_n #(.WIDTH(2)) LED_Color_Register (
        .clk(clk),
        .reset(reset),
        .en(led_color_en),
        .d(led_color_d),
        .q(led_color_q)
    );

    reg_n #(.WIDTH(1)) LED_Signal_Register (
        .clk(clk),
        .reset(reset),
        .en(led_signal_en),
        .d(led_signal_d),
        .q(led_signal_q)
    );

    reg_n #(.WIDTH(1)) Fire_Bullets_Register (
        .clk(clk),
        .reset(reset),
        .en(fire_signal_en),
        .d(fire_signal_d),
        .q(fire_signal_q)
    );

    reg_n #(.WIDTH(8)) X_Position_Register (
        .clk(clk),
        .reset(reset),
        .en(x_en),
        .d(x_d),
        .q(x_q)
    );

    reg_n #(.WIDTH(8)) Y_Position_Register (
        .clk(clk),
        .reset(reset),
        .en(y_en),
        .d(y_d),
        .q(y_q)
    );

    reg_n #(.WIDTH(2)) Weapon_Type_Register (
        .clk(clk),
        .reset(reset),
        .en(weapon_en),
        .d(weapon_d),
        .q(weapon_q)
    );

    reg_n #(.WIDTH(16)) Feedback_Register (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(feedback_d),
        .q(feedback_q)
    );

    reg_n #(.WIDTH(32)) Memory_Snapshot_Register (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(memory_snapshot_d),
        .q(memory_snapshot_q)
    );

    reg_n #(.WIDTH(8)) Status_Register (
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(status_code_d),
        .q(status_code_q)
    );

    assign speed = speed_q;
    assign heading = heading_q;
    assign led_color = led_color_q;
    assign led_signal = led_signal_q[0];
    assign fire_signal = fire_signal_q[0];
    assign x_position = x_q;
    assign y_position = y_q;
    assign weapon_type = weapon_q;
    assign status_code = status_code_q;
    assign feedback_loop = feedback_q;
    assign memory_snapshot = memory_snapshot_q;
endmodule
