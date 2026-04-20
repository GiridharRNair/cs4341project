`timescale 1ns/1ps

module robot_breadboard_tb;
    reg clk;
    reg reset;
    reg [3:0] opcode;

    wire [7:0] speed;
    wire [1:0] heading;
    wire [1:0] led_color;
    wire led_signal;
    wire fire_signal;
    wire [7:0] x_position;
    wire [7:0] y_position;
    wire [1:0] weapon_type;
    wire [7:0] status_code;
    wire [15:0] feedback_loop;
    wire [31:0] memory_snapshot;

    robot_breadboard dut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .speed(speed),
        .heading(heading),
        .led_color(led_color),
        .led_signal(led_signal),
        .fire_signal(fire_signal),
        .x_position(x_position),
        .y_position(y_position),
        .weapon_type(weapon_type),
        .status_code(status_code),
        .feedback_loop(feedback_loop),
        .memory_snapshot(memory_snapshot)
    );

    always #5 clk = ~clk;

    task run_cmd;
        input [3:0] op;
        begin
            @(negedge clk);
            opcode = op;

            @(posedge clk);
            #1;

            $display("Time=%0t | Opcode=%b | Speed=%0d | Heading=%b | LED-Color=%b | LED-On=%b | Fire-On=%b | X-Position=%02h | Y-Position=%02h | Weapon-Type=%b | Status-Code=%02h | Feedback-Loop=%04h | Memory-Snapshot=%08h",
                $time, opcode,
                speed, heading, led_color, led_signal, fire_signal,
                x_position, y_position, weapon_type, status_code, feedback_loop, memory_snapshot);

            if (status_code != 8'h00) begin
                $display("  Status Warning: Reserved opcode detected -- non-zero Status-Code indicates a warning or error condition");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        opcode = 4'b0000;

        $display("--- Robot Breadboard Testbench Start ---");
        #12;
        reset = 1'b0;

        // 0000: speed += 1, 0001: speed -= 1.
        run_cmd(4'b0000); // speed += 1
        run_cmd(4'b0000); // speed += 1
        run_cmd(4'b0001); // speed -= 1

        // 0010: heading += 1 (mod 4).
        run_cmd(4'b0010); // turn +1 -> east
        run_cmd(4'b0011); // LED blue
        run_cmd(4'b0100); // LED green
        run_cmd(4'b0101); // LED red
        run_cmd(4'b0110); // LED on
        run_cmd(4'b0111); // LED off

        run_cmd(4'b1000); // Fire on
        run_cmd(4'b1001); // Fire off

        // 1010 = move forward, 1011 = move backward.
        // Heading map: 00 north(+Y), 01 east(+X), 10 south(-Y), 11 west(-X).
        run_cmd(4'b1010); // forward heading east  -> X increases
        run_cmd(4'b1011); // backward heading east -> X decreases

        run_cmd(4'b0010); // turn +1 -> south
        run_cmd(4'b1010); // forward heading south  -> Y decreases
        run_cmd(4'b1011); // backward heading south -> Y increases

        run_cmd(4'b0010); // turn +1 -> west
        run_cmd(4'b1010); // forward heading west   -> X decreases
        run_cmd(4'b0010); // turn +1 -> north
        run_cmd(4'b1010); // forward heading north  -> Y increases

        // 1100: weapon_type += 1 (mod 4).
        run_cmd(4'b1100); // weapon +1
        run_cmd(4'b1100); // weapon +1
        run_cmd(4'b1100); // weapon +1
        run_cmd(4'b1100); // weapon +1 (wraps back to 00)

        // Reserved opcodes to exercise status handling.
        run_cmd(4'b1101);
        run_cmd(4'b1110);
        run_cmd(4'b1111);

        // Additional speed updates.
        run_cmd(4'b0001);
        run_cmd(4'b0000);
        run_cmd(4'b0001);

        $display("--- Robot Breadboard Testbench End ---");
        $finish;
    end
endmodule
