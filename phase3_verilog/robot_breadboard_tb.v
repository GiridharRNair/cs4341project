`timescale 1ns/1ps

module robot_breadboard_tb;
    reg clk;
    reg reset;
    reg [3:0] opcode;
    reg [7:0] data_in_a;
    reg [7:0] data_in_b;
    reg [1:0] heading_in;

    wire [7:0] speed;
    wire [1:0] heading;
    wire [1:0] led_color;
    wire led_signal;
    wire fire_bullets_signal;
    wire [7:0] x_position;
    wire [7:0] y_position;
    wire [1:0] weapon_type;
    wire [7:0] status;
    wire [15:0] feedback_loop;
    wire [31:0] memory_reg32;

    robot_breadboard dut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .heading_in(heading_in),
        .speed(speed),
        .heading(heading),
        .led_color(led_color),
        .led_signal(led_signal),
        .fire_bullets_signal(fire_bullets_signal),
        .x_position(x_position),
        .y_position(y_position),
        .weapon_type(weapon_type),
        .status(status),
        .feedback_loop(feedback_loop),
        .memory_reg32(memory_reg32)
    );

    always #5 clk = ~clk;

    task run_cmd;
        input [3:0] op;
        input [7:0] a;
        input [7:0] b;
        input [1:0] h;
        begin
            @(negedge clk);
            opcode = op;
            data_in_a = a;
            data_in_b = b;
            heading_in = h;

            @(posedge clk);
            #1;

            $display("t=%0t op=%b a=%02h b=%02h h=%b | speed=%02h heading=%b ledC=%b led=%b fire=%b x=%02h y=%02h weapon=%b status=%02h fb=%04h mem=%08h",
                $time, opcode, data_in_a, data_in_b, heading_in,
                speed, heading, led_color, led_signal, fire_bullets_signal,
                x_position, y_position, weapon_type, status, feedback_loop, memory_reg32);

            if (status != 8'h00) begin
                $display("  status-note: non-zero status indicates warning/error/incomplete behavior");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        opcode = 4'b0000;
        data_in_a = 8'h00;
        data_in_b = 8'h00;
        heading_in = 2'b00;

        $display("--- Robot Breadboard Testbench Start ---");
        #12;
        reset = 1'b0;

        // Basic command coverage with CircuitVerse-aligned datapaths:
        // 0000: speed += data_in_a, 0001: speed += data_in_b.
        run_cmd(4'b0000, 8'h03, 8'h00, 2'b00); // speed += 03
        run_cmd(4'b0000, 8'h07, 8'h00, 2'b00); // speed += 07
        run_cmd(4'b0001, 8'h00, 8'hFE, 2'b00); // speed += FE (effectively -2)

        // 0010: heading += heading_in (mod 4).
        run_cmd(4'b0010, 8'h00, 8'h00, 2'b01); // turn by +1 -> east

        run_cmd(4'b0011, 8'h00, 8'h00, 2'b00); // LED blue
        run_cmd(4'b0100, 8'h00, 8'h00, 2'b00); // LED green
        run_cmd(4'b0101, 8'h00, 8'h00, 2'b00); // LED red
        run_cmd(4'b0110, 8'h00, 8'h00, 2'b00); // LED on
        run_cmd(4'b0111, 8'h00, 8'h00, 2'b00); // LED off

        run_cmd(4'b1000, 8'h00, 8'h00, 2'b00); // Fire on
        run_cmd(4'b1001, 8'h00, 8'h00, 2'b00); // Fire off

        // Move commands now use heading + speed:
        // 1010 = move forward, 1011 = move backward.
        // Heading map: 00 north(+Y), 01 east(+X), 10 south(-Y), 11 west(-X).
        run_cmd(4'b1010, 8'h00, 8'h00, 2'b00); // forward while heading east -> X increases
        run_cmd(4'b1011, 8'h00, 8'h00, 2'b00); // backward while heading east -> X decreases

        run_cmd(4'b0010, 8'h00, 8'h00, 2'b01); // turn by +1 -> south
        run_cmd(4'b1010, 8'h00, 8'h00, 2'b00); // forward while heading south -> Y decreases
        run_cmd(4'b1011, 8'h00, 8'h00, 2'b00); // backward while heading south -> Y increases

        run_cmd(4'b0010, 8'h00, 8'h00, 2'b01); // turn by +1 -> west
        run_cmd(4'b1010, 8'h00, 8'h00, 2'b00); // forward while heading west -> X decreases
        run_cmd(4'b0010, 8'h00, 8'h00, 2'b01); // turn by +1 -> north
        run_cmd(4'b1010, 8'h00, 8'h00, 2'b00); // forward while heading north -> Y increases

        // 1100: weapon_type += heading_in (mod 4).
        run_cmd(4'b1100, 8'h00, 8'h00, 2'b01); // +1
        run_cmd(4'b1100, 8'h00, 8'h00, 2'b10); // +2
        run_cmd(4'b1100, 8'h00, 8'h00, 2'b01); // +1
        run_cmd(4'b1100, 8'h00, 8'h00, 2'b00); // +0 (hold)

        // Reserved opcodes to exercise status handling.
        run_cmd(4'b1111, 8'h00, 8'h00, 2'b00);

        // Additional speed updates using data_in_b path.
        run_cmd(4'b0001, 8'h00, 8'h01, 2'b00);
        run_cmd(4'b0001, 8'h00, 8'h02, 2'b00);
        run_cmd(4'b0001, 8'h00, 8'h03, 2'b00);

        $display("--- Robot Breadboard Testbench End ---");
        $finish;
    end
endmodule
