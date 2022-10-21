`include "defines.sv"

///////////////////////////////////////////////////////////////////////////////
// Memory apertture module. 
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

module Aperture_tb;

    reg			    clk;		// Main FPGA clock 
	reg			    a8_rst_n;	// A8 /RST signal
	reg			    a8_rw_n;	// A8 read(1) or write(0) signal
	reg [7:0]	    a8_data;	// A8 data bus value
	reg [15:0]      a8_addr;	// A8 address bus
	reg			    aValid;		// Address is valid
	reg			    wValid;		// Write op is valid
	
	wire			inRange;	// Is the page one of ours
	wire [7:0]		apCfg;		// Results of the read op
	wire 			apCfgValid;	// Strobe to say the data is valid
	wire [26:0]	    baseAddr;	// Address currently set in SDRAM

    
	///////////////////////////////////////////////////////////////////////////
	// Create the DUT
	///////////////////////////////////////////////////////////////////////////
    Aperture dut
        (
        .clk(clk),                      // Main FPGA clock @ 200MHz
        .a8_rst_n(a8_rst_n),            // Reset on A8 bus
        .a8_rw_n(a8_rw_n),              // read/write on A8 bus
        .a8_data(a8_data),              // A8 data bus
        .a8_addr(a8_addr),              // A8 address
        .index(4'b0),                  // Which memory aperture
        .aValid(aValid),                // A8 address is valid
        .wValid(wValid),                // A8 write data is valid
        
        .inRange(inRange),              // We're in range for this aperture
        .apCfg(apCfg),                  // Aperture config data
        .apCfgValid(apCfgValid),        // Aperture config data is valid
        .baseAddr(baseAddr)             // Effective address in SDRAM
        );
    
	///////////////////////////////////////////////////////////////////////////
	// Set everything going
	///////////////////////////////////////////////////////////////////////////
    initial
        begin
            $dumpfile("Aperture.vcd");
            $dumpvars(0, Aperture_tb);

            clk         = 1'b1;
            a8_rst_n    = 1'b1;
            a8_rw_n     = 1'b1;
            a8_data     = 8'b0;
            a8_addr     = 16'b0;
            aValid      = 1'b0;
            wValid      = 1'b0;

            ///////////////////////////////////////////////////////////////////
            // Reset
            ///////////////////////////////////////////////////////////////////
            #558        a8_rst_n = 1'b0;
            #558        a8_rst_n = 1'b1;
            
            ///////////////////////////////////////////////////////////////////
            // Write to register 1
            ///////////////////////////////////////////////////////////////////
            writeAP(16'hD700, 8'hff);
            #50
            writeAP(16'hD701, 8'h65);
            #50
            writeAP(16'hD702, 8'h43);
            #50
            writeAP(16'hD703, 8'h21);
            #50
            writeAP(16'hD704, 8'h06);
            #50
            writeAP(16'hD705, 8'h06);
            #50
            readAP(16'HD700);

            readAP(16'H0602);

            #50 	$stop;
        end

	///////////////////////////////////////////////////////////////////////////
	// Toggle the clocks indefinitely
	///////////////////////////////////////////////////////////////////////////
    always 
        	#2.5 		clk = ~clk;


	///////////////////////////////////////////////////////////////////////////
	// Create a task to write to a memory aperture
	///////////////////////////////////////////////////////////////////////////
    task writeAP(
        input[15:0] addr,                   // A8 Address
        input[7:0] data                     // A8 Data to write
        );
    
        #127        a8_addr = addr;
                    a8_data = data;
                    a8_rw_n = 1'b0;
        #50         aValid  = 1'b1;
        #245        wValid  = 1'b1;
        #136        aValid  = 1'b0;
                    wValid  = 1'b0;
                    a8_addr = 16'h0;
                    a8_data = 8'h0;
                    a8_rw_n = 1'b1;
    endtask

	///////////////////////////////////////////////////////////////////////////
	// Create a task to read from a memory aperture
	///////////////////////////////////////////////////////////////////////////
    task readAP(
        input[15:0] addr                    // A8 Address
        );
    
        #127        a8_addr = addr;
                    a8_rw_n = 1'b1;
        #50         aValid  = 1'b1;
        #381        aValid  = 1'b0;
                    wValid  = 1'b0;
                    a8_addr = 16'h0;
                    a8_data = 8'h0;
                    a8_rw_n = 1'b1;
    endtask

endmodule
