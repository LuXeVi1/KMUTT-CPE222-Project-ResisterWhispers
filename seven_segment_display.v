// Verilog Code for Alternating Display of Unit and Tens Digits on a Single 7-Segment Display

module seven_segment_alternating(
    input [7:0] switches, // 8 switches for input number (1-99 in binary)
    input clk,            // Clock signal for timing control
    output reg [6:0] segment, // Segments for the single 7-segment display
    output wire digit1,      // Signal to indicate tens digit
    output wire digit0       // Signal to indicate unit digit
);

    reg [3:0] unit_digit; // Extracted unit digit
    reg [3:0] tens_digit; // Extracted tens digit
    reg digit_select;     // Internal register to alternate between digits
    reg [31:0] counter;   // Counter for clock division

    // Generate digit selection signals
    assign digit1 = (digit_select == 1); // Active when tens digit is selected
    assign digit0 = (digit_select == 0); // Active when unit digit is selected

    // Clock division for alternating display
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter >= 32'd500000) begin // Adjust this value to control speed
            counter <= 0;
            digit_select <= ~digit_select; // Toggle between unit and tens
        end
    end

    // Extract digits from input
    always @(*) begin
        if (switches >= 8'd1 && switches <= 8'd99) begin
            tens_digit = switches / 10; // Integer division to get tens digit
            unit_digit = switches % 10; // Modulo operation to get unit digit
        end else begin
            tens_digit = 4'd0;
            unit_digit = 4'd0;
        end
    end

    // Select the appropriate digit to display
    always @(*) begin
        if (digit0) begin
            // Display unit digit
            case (unit_digit)
                4'b0000: segment = 7'b0111111; // 0 
                4'b0001: segment = 7'b0000110; // 1
                4'b0010: segment = 7'b1011011; // 2
                4'b0011: segment = 7'b1001111; // 3
                4'b0100: segment = 7'b1100110; // 4
                4'b0101: segment = 7'b1101101; // 5
                4'b0110: segment = 7'b1111101; // 6
                4'b0111: segment = 7'b0000111; // 7
                4'b1000: segment = 7'b1111111; // 8
                4'b1001: segment = 7'b1101111; // 9
                default: segment = 7'b0000000; // Off
            endcase
        end else if (digit1) begin
            // Display tens digit
            case (tens_digit)
                4'b0000: segment = 7'b0111111; // 0
                4'b0001: segment = 7'b0000110; // 1
                4'b0010: segment = 7'b1011011; // 2
                4'b0011: segment = 7'b1001111; // 3
                4'b0100: segment = 7'b1100110; // 4
                4'b0101: segment = 7'b1101101; // 5
                4'b0110: segment = 7'b1111101; // 6
                4'b0111: segment = 7'b0000111; // 7
                4'b1000: segment = 7'b1111111; // 8
                4'b1001: segment = 7'b1101111; // 9
                default: segment = 7'b0000000; // Off
            endcase
        end
    end

endmodule
