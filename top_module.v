module top_module (
    input [7:0] switches,  // สวิทช์ 8 ตัวสำหรับกรอกข้อมูล
    input clk,              // สัญญาณนาฬิกา
    input button,           // ปุ่มกดยืนยันข้อมูล
    output reg [6:0] segment,  // 7-segment display output
    output reg digit1,          // แสดงค่าหลักสิบ
    output reg digit0,          // แสดงค่าหลักหน่วย
    output reg [3:0] led       // ไฟ LED 4 ดวง
);

    // ตัวแปรเพื่อเก็บค่าข้อมูล
    reg [7:0] age;           // อายุ
    reg [1:0] gender;        // เพศ
    reg [7:0] weight;        // น้ำหนัก
    reg [7:0] body_fat;      // ผลลัพธ์ของ Body Fat
    reg [1:0] state;         // สถานะการกรอกข้อมูล

    // สถานะการกรอกข้อมูล
    parameter AGE = 2'b00;
    parameter GENDER = 2'b01;
    parameter WEIGHT = 2'b10;
    parameter CONFIRM = 2'b11;

    // ตัวแปรสำหรับการคำนวณการแสดงผล 7-segment
    wire [6:0] segment_out_1, segment_out_2;
    wire digit1_out_1, digit0_out_1;
    wire digit1_out_2, digit0_out_2;

    // ตัวแปรเก็บสถานะปุ่ม debounce
    reg [15:0] button_debounce_counter;
    reg button_debounced;

    // Debounce Logic
    always @(posedge clk) begin
        if (button == 1'b1) begin
            if (button_debounce_counter < 16'hFFFF) begin
                button_debounce_counter <= button_debounce_counter + 1;
            end
        end else begin
            button_debounce_counter <= 0;
        end
        button_debounced <= (button_debounce_counter == 16'hFFFF);
    end

    // การอัปเดตสถานะและการกรอกข้อมูลจากปุ่ม `button`
    always @(posedge clk) begin
        if (button_debounced) begin  // ใช้ตัวแปรที่ผ่าน debounce
            case (state)
                AGE: begin
                    if (switches > 0) begin // ตรวจสอบให้แน่ใจว่า switches มีค่าที่เหมาะสม
                        age <= switches;    // รับค่าจาก switches สำหรับอายุ
                        state <= GENDER;    // ไปกรอกเพศ
                    end
                end
                GENDER: begin
                    if (switches[1:0] > 0) begin // ตรวจสอบว่าค่าที่กรอกเป็นเพศเหมาะสม
                        gender <= switches[1:0]; // รับค่าจาก switches สำหรับเพศ
                        state <= WEIGHT;        // ไปกรอกน้ำหนัก
                    end
                end
                WEIGHT: begin
                    if (switches > 0) begin // ตรวจสอบให้แน่ใจว่าน้ำหนักมีค่าที่เหมาะสม
                        weight <= switches;     // รับค่าจาก switches สำหรับน้ำหนัก
                        state <= CONFIRM;       // ยืนยันข้อมูล
                    end
                end
                CONFIRM: begin
                    // คำนวณ Body Fat และกลับไปเริ่มต้นใหม่
                    if (gender == 2'b00) begin // ชาย
                        body_fat <= ((weight * 41535) + (age * 160500) - (5260))/ 1000000; //26300 * voltage ซึ่งอันนี้คือ 0.2 v
                    end else begin // หญิง
                        body_fat <= ((weight * 84195) + (age * 580000) - (18400))/ 1000000; //92000* voltage
                    end
                    state <= AGE;
                end
                default: state <= AGE;  // กรณีสถานะเริ่มต้น
            endcase
        end
    end

    // ใช้ `seven_segment` สำหรับแสดงผลการคำนวณ
    seven_segment_alternating display_1 (
        .switches(switches),  // ส่งค่า switches ไปที่ seven_segment สำหรับแสดงผล
        .clk(clk),
        .segment(segment_out_1),
        .digit1(digit0_out_1),  // แสดงผลหลักหน่วยของ switches
        .digit0(digit1_out_1)   // แสดงผลหลักสิบของ switches
    );

    seven_segment_alternating display_2 (
        .switches(body_fat),  // ส่งค่า body_fat ไปที่ seven_segment สำหรับแสดงผล
        .clk(clk),
        .segment(segment_out_2),
        .digit1(digit0_out_2),  // แสดงผลหลักหน่วยของ body_fat
        .digit0(digit1_out_2)   // แสดงผลหลักสิบของ body_fat
    );

    // ใช้สถานะ `state` ในการกำหนดว่าแสดงผลจาก display ไหน
    always @(posedge clk) begin
        case (state)
            CONFIRM: begin
                // เมื่ออยู่ในสถานะ CONFIRM ให้แสดงผลจาก display_2 (body_fat)
                segment <= segment_out_2;
                digit1 <= digit1_out_2;
                digit0 <= digit0_out_2;
                // ไฟ LED แสดงสถานะ CONFIRM
                led <= 4'b1000;
            end
            WEIGHT: begin
                // ไฟ LED แสดงสถานะ WEIGHT
                segment <= segment_out_1;
                digit1 <= digit1_out_1;
                digit0 <= digit0_out_1;
                led <= 4'b0100;
            end
            GENDER: begin
                // ไฟ LED แสดงสถานะ GENDER
                segment <= segment_out_1;
                digit1 <= digit1_out_1;
                digit0 <= digit0_out_1;
                led <= 4'b0010;
            end
            AGE: begin
                // ไฟ LED แสดงสถานะ AGE
                segment <= segment_out_1;
                digit1 <= digit1_out_1;
                digit0 <= digit0_out_1;
                led <= 4'b0001;
            end
            default: begin
                // ไฟ LED แสดงสถานะเริ่มต้น
                led <= 4'b0000;
            end
        endcase
    end

endmodule
