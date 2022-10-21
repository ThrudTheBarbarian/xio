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

module BusMonitor_tb;

	reg clk, a8_clk;            // The clocks, both FPGA and A8
	reg a8_rst_n;               // A8 asynchronous reset

    wire a8_addr_strobe;        // The address is valid on the A8 bus
    wire a8_write_strobe;       // Write signals are now valid
    wire a8_read_strobe;        // Read signals are now valid
    wire a8_clk_falling;        // The clock-cycle is now resetting

    
	///////////////////////////////////////////////////////////////////////////
	// Create the DUT
	///////////////////////////////////////////////////////////////////////////
    BusMonitor dut
        (
        .clk(clk),                          // FPGA clock
        .a8_clk(a8_clk),                    // Atari clock from bus
        .a8_rst_n(a8_rst_n),                // Atari reset from bus

        .a8_addr_strobe(a8_addr_strobe),    // Address is valid on the A8 bus
        .a8_write_strobe(a8_write_strobe),  // Write signals are now valid
        .a8_read_strobe(a8_read_strobe),    // Read signals are now valid
        .a8_clk_falling(a8_clk_falling)     // A8 clock-cycle is now resetting
        );
    
	///////////////////////////////////////////////////////////////////////////
	// Set everything going
	///////////////////////////////////////////////////////////////////////////
    initial
        begin
            $dumpfile("busMonitor.vcd");
            $dumpvars(0, BusMonitor_tb);

            clk 		= 1'b0;
            a8_clk 		= 1'b0;
            a8_rst_n   	= 1'b1;
            		
			// Enter a reset cycle		
			#558 	a8_rst_n	= 1'b0;
			#558 	a8_rst_n	= 1'b1;

			// Finish
            #558
            #558
            #558
            #558
            #558 	$stop;
        end

	///////////////////////////////////////////////////////////////////////////
	// Toggle the clocks indefinitely
	///////////////////////////////////////////////////////////////////////////
    always 
        	#2.5 		clk = ~clk;
    always 
			#279	a8_clk = ~a8_clk;
			
endmodule
