`include "defines.sv"

///////////////////////////////////////////////////////////////////////////////
// Bus monitor module. 
//
// Timings are:
//
//	|<------------------------- Cycle time 558ns ---------------------->|
//
//	|__________________________________|--------------------------------|
//
//	|<---- 177ns ---->|XXXXXXXXX Valid Address XXXXXXXXXXXXXXXXXXXXXXXXXXXX|
//
// 	|<------------------------------- 422ns ----------->|XXXXXXX Write XXXXXXX|
//
// 	|<------------------------------- 486ns --------------->|XXXX Read XXXX|
//
//
//	|<------- 195ns ------->| ExtenB
//  |_______________________|-------------------------------------------|
//
//	|<---------- 225 ns ----------| MPD
//  |-----------------------------|_____________________________________|
//
// 
///////////////////////////////////////////////////////////////////////////////

module PriorityEncoder_tb;

	reg clk;                    // The clock

    reg  [7:0] inputs;          // Inputs to the encoder
    wire [3:0] result;          // Output from the encoder

    
	///////////////////////////////////////////////////////////////////////////
	// Create the DUT
	///////////////////////////////////////////////////////////////////////////
    PriorityEncoder dut
        (
        .bits(inputs),                      // Bits sent in
        .index(result)                     // Value coming out
        );
    
	///////////////////////////////////////////////////////////////////////////
	// Set everything going
	///////////////////////////////////////////////////////////////////////////
    initial
        begin
            $dumpfile("PriorityEncoder.vcd");
            $dumpvars(0, PriorityEncoder_tb);

            clk 		= 1'b0;
            		
			// Finish
            #10     inputs = 1;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs *=2;
            #10     inputs = 0;
            #50
            #10     inputs = 1;
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = {inputs[6:0],1'b1};
            #10     inputs = 0;
            #50     inputs = 8'hff;
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
            #10     inputs = {1'b0,inputs[7:1]};
 
            #50 	$stop;
        end

	///////////////////////////////////////////////////////////////////////////
	// Toggle the clocks indefinitely
	///////////////////////////////////////////////////////////////////////////
    always 
        	#5 		clk = ~clk;
			
endmodule
