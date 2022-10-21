`include "defines.sv"

///////////////////////////////////////////////////////////////////////////////
// Top level module. 
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

module xio_tb;

    reg			    clk;		// Main FPGA clock 

    reg			    a8_clk;	    // A8 clk signal
	reg			    a8_rst_n;	// A8 /RST signal
    reg             a8_halt_n;  // A8 /HALT signal
    reg             a8_ref_n;   // A8 /REF signal
	reg			    a8_rw;	  // A8 read(1) or write(0) signal

 	reg			    a8_rd5;	    // A8 cartridge present
	reg			    a8_rd4;	    // A8 cartridge present
	reg			    a8_s5_n;	// A8 cartridge select
	reg			    a8_s4_n;	// A8 cartridge select

    wire            a8_irq_n;   // IRQ output
    wire            a8_mpd_n;   // /MPD output
    wire            a8_extsel_n;// /EXTSEL output

	reg [15:0]      a8_addr;	// A8 address bus
    wire            a8_data_oe; // data output-enable

    // Model the inout nature of the data-bus
    wire [7:0]      a8d_pin;    // A8 databus bidir signal from dut
	reg  [7:0]	    a8d_drive;	// A8 databus locally driven value
    wire [7:0]      a8d_recv;   // A8 databus locally received value
    
    assign a8d_pin  = a8d_drive;
    assign a8d_recv = a8d_pin;

	///////////////////////////////////////////////////////////////////////////
	// Create the DUT
	///////////////////////////////////////////////////////////////////////////
    xio dut
        (
        .clk(clk),                      // Main FPGA clock @ 200MHz

        .a8_clk(a8_clk),                // A8 clock
        .a8_rst_n(a8_rst_n),            // Reset on A8 bus
        .a8_halt_n(a8_halt_n),          // /HALT signal from Antic
        .a8_ref_n(a8_ref_n),            // /REF signal from Antic
        .a8_rw(a8_rw),                  // read/write on A8 bus
  
        .a8_rd5(a8_rd5),                // A8 cartridge present
        .a8_rd4(a8_rd4),                // A8 cartridge present
        .a8_s5_n(a8_s5_n),              // A8 cartridge select
        .a8_s4_n(a8_s4_n),              // A8 cartridge select
        
        .a8_irq_n(a8_irq_n),            // /IRQ output   
        .a8_mpd_n(a8_mpd_n),            // /MPD output   
        .a8_extsel_n(a8_extsel_n),      // /EXTSEL output   
        
        .a8_data(a8d_pin),              // A8 data bus
        .a8_addr(a8_addr),              // A8 address
        .a8_data_oe(a8_data_oe)         // A8 data output enable
        );
    
	///////////////////////////////////////////////////////////////////////////
	// Set everything going
	///////////////////////////////////////////////////////////////////////////
    initial
        begin
            $dumpfile("xio.vcd");
            $dumpvars(0, xio_tb);

            clk             = 1'b1;
            a8_clk          = 1'b1;
            a8_rst_n        = 1'b1;
            a8_halt_n       = 1'b1;
            a8_ref_n        = 1'b1;
            a8_rd4          = 1'b1;
            a8_s4_n         = 1'b1;
            a8_s5_n         = 1'b1;
            a8_rd5          = 1'b1;
            a8_rw           = 1'b1;
            a8d_drive       = 8'bz;
            a8_addr         = 16'b0;

            ///////////////////////////////////////////////////////////////////
            // Reset
            ///////////////////////////////////////////////////////////////////
            #558        a8_rst_n = 1'b0;
            #558        a8_rst_n = 1'b1;
            
            ///////////////////////////////////////////////////////////////////
            // Write to register 1
            ///////////////////////////////////////////////////////////////////
            writeAP(16'hD700, 8'hff);
    
            writeAP(16'hD701, 8'h65);

            writeAP(16'hD702, 8'h43);

            writeAP(16'hD703, 8'h21);

            writeAP(16'hD704, 8'h06);
  
            writeAP(16'hD705, 8'h06);

            readAP(16'HD700);

            readAP(16'H0602);

            #558 	$stop;
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
                    a8_clk      = 1'b0;
        #127        a8_addr     = addr;
                    a8d_drive   = data;
                    a8_rw       = 1'b0;
        #152        a8_clk      = 1'b1;
        #279        a8_addr     = 16'h0;
                    a8d_drive   = 8'h0;
                    a8_rw       = 1'b1;
                    a8_clk      = 1'b0;
    endtask

	///////////////////////////////////////////////////////////////////////////
	// Create a task to read from a memory aperture
	///////////////////////////////////////////////////////////////////////////
    task readAP(
        input[15:0] addr                    // A8 Address
        );
                    a8_clk      = 1'b0;
        #127        a8_addr     = addr;
                    a8_rw       = 1'b1;
        #152        a8_clk      = 1'b1;
        #279        a8_addr     = 16'h0;
                    a8d_drive   = 8'bz;
                    a8_rw       = 1'b1;
    endtask

endmodule
