# Verilog 7-Segment Display Controller

This project implements a Verilog-based controller for a 7-segment display. The controller takes input from switches, processes the input data, and displays the result on a 7-segment display. The project consists of two main modules: `top_module` and `seven_segment_alternating`.

## File Structure

- `top_module.v`: The top-level module that handles input processing, state management, and output control.
- `seven_segment_display.v`: A module for alternating display of unit and tens digits on a single 7-segment display.

## Modules

### top_module

The `top_module` handles the main logic of the project. It processes input from switches, manages different states, and controls the output to the 7-segment display and LEDs.

#### Inputs
- `switches`: 8-bit input from switches.
- `clk`: Clock signal.
- `button`: Button input for confirming data.

#### Outputs
- `segment`: 7-segment display output.
- `digit1`: Indicates tens digit.
- `digit0`: Indicates unit digit.
- `led`: 4-bit output for LEDs.

#### Internal Variables
- `age`: Stores age input.
- `gender`: Stores gender input.
- `weight`: Stores weight input.
- `body_fat`: Stores calculated body fat result.
- `state`: Manages the current state of data input.

#### States
- `AGE`: State for inputting age.
- `GENDER`: State for inputting gender.
- `WEIGHT`: State for inputting weight.
- `CONFIRM`: State for confirming data and calculating body fat.

### seven_segment_alternating

The `seven_segment_alternating` module handles the display of unit and tens digits on a single 7-segment display by alternating between the digits.

#### Inputs
- `switches`: 8-bit input number (1-99 in binary).
- `clk`: Clock signal for timing control.

#### Outputs
- `segment`: Segments for the single 7-segment display.
- `digit1`: Signal to indicate tens digit.
- `digit0`: Signal to indicate unit digit.

## Usage

1. Connect the switches, clock, and button inputs to the `top_module`.
2. The `top_module` will process the input data and manage the state transitions.
3. The `seven_segment_alternating` module will handle the display of the input data on the 7-segment display.
4. The LEDs will indicate the current state of the input process.

## Example

Here is an example of how to instantiate the `top_module` in your Verilog code:

```verilog
module example (
    input [7:0] switches,
    input clk,
    input button,
    output [6:0] segment,
    output digit1,
    output digit0,
    output [3:0] led
);

    top_module u_top_module (
        .switches(switches),
        .clk(clk),
        .button(button),
        .segment(segment),
        .digit1(digit1),
        .digit0(digit0),
        .led(led)
    );

endmodule
```

### License

This project is licensed under the MIT License - see the LICENSE file for details.