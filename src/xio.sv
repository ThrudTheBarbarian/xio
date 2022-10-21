`include "defines.sv"

///////////////////////////////////////////////////////////////////////////////
// Top module. 
//
// 
///////////////////////////////////////////////////////////////////////////////
module xio
	#(parameter ANUM=8)					// Number of Apertures
    (
    input               clk,            // Master FPGA clock, target = 200MHz
   
    // A8 bus signals
	input				a8_clk,			// A8 clock @ ~1.8MHz
	input               a8_rst_n,       // A8 /RESET signal
	input				a8_halt_n,	    // A8 /HALT signal input  
  	input				a8_ref_n,	    // A8 Dram refresh (/REF) signal input
 	input				a8_rw,		    // A8 read (=1) / write (=0) signal input

    input				a8_rd5,			// A8 rd5 cartridge signal
	input				a8_rd4,			// A8 rd4 cartridge signal
    input               a8_s4_n,        // A8 /S4 cartridge-present signal
    input               a8_s5_n,        // A8 /S% cartridge-present signal

	output  reg			a8_irq_n,		// A8 /IRQ signal
	output   			a8_mpd_n,		// A8 Math-Pak Disable (/MPD) signal
	output   			a8_extsel_n,	// A8 external selection signal
    
	input	    [15:0]	a8_addr,	    // A8 address bus inputs
   	inout	    [7:0]   a8_data,	    // A8 data bus inputs/outputs
    output  reg         a8_data_oe      // A8 data bus output enable
  
    );

    ///////////////////////////////////////////////////////////////////////////
    // Generate variables
    ///////////////////////////////////////////////////////////////////////////
	genvar i;
	
    ///////////////////////////////////////////////////////////////////////////
    // Instantiate a bus-monitor
    ///////////////////////////////////////////////////////////////////////////
    wire 		a8_addr_strobe;
    wire		a8_read_strobe;
    wire		a8_write_strobe;		
	wire		a8_clk_falling;
	
	BusMonitor busMon
		(
		.clk(clk),
		.a8_clk(a8_clk),
		.a8_rst_n(a8_rst_n),

		.a8_addr_strobe(a8_addr_strobe),
		.a8_write_strobe(a8_write_strobe),
		.a8_read_strobe(a8_read_strobe),
		.a8_clk_falling(a8_clk_falling)
		);

		
    ///////////////////////////////////////////////////////////////////////////
    // Instantiate ANUM memory apertures
    ///////////////////////////////////////////////////////////////////////////
	wire [ANUM-1:0] inRange;			// Flags from each of the apertures
	wire [7:0] apCfg [0:ANUM-1];		// Configuration data from aperture
	wire apCfgValid[ANUM-1:0];			// If config is valid
	wire [26:0] apBase [0:ANUM-1];		// SDRAM addresses
	
	generate for (i=0; i<ANUM; i=i+1)
		begin :aperture_gen
			Aperture aperture
				(
				.clk(clk),
				.a8_rst_n(a8_rst_n),
				.a8_rw(a8_rw),
				.a8_data(a8_data),
				.wValid(a8_write_strobe),
				.aValid(a8_addr_strobe),
				.a8_addr(a8_addr),
				.index(i[3:0]),

				.inRange(inRange[i]),
				.apCfg(apCfg[i]),
				.apCfgValid(apCfgValid[i]),
				.baseAddr(apBase[i])
				);
		end
	endgenerate

	
	
    ///////////////////////////////////////////////////////////////////////////
    // Figure out which aperture is currently signalling that it's in range.
    // Note that the priority encoder is not parameterised... 
    ///////////////////////////////////////////////////////////////////////////
   	wire [$clog2(ANUM):0] apIndex;
    PriorityEncoder pEnc
    	(
    	.bits(inRange),
    	.index(apIndex)
    	);
    	

    ///////////////////////////////////////////////////////////////////////////
    // Determine and save the aperture's effective address
    ///////////////////////////////////////////////////////////////////////////
	wire        sdramRdy = 1'b1;
    reg [26:0] 	sdramAddr;
	reg 		sdramValid;
	
	always @(posedge clk)
		if (a8_rst_n == 1'b0)
			begin
				sdramAddr 	<= 27'b0;
				sdramValid	<= 1'b0;
			end
			
		else if (apIndex[3] == 1'b1)
			begin
				if (a8_clk_falling)
					sdramValid		<= 1'b0;
			end
		else
			begin
				sdramValid 	<= sdramRdy;
                sdramAddr   <= apBase[apIndex[2:0]] + a8_addr[7:0];
			end


    ///////////////////////////////////////////////////////////////////////////
    // Handle /MPD and /EXTSEL
    ///////////////////////////////////////////////////////////////////////////
	reg 		extAccessValid;
	
	always @(posedge clk)
		if (a8_rst_n == 1'b0)
			extAccessValid	<= 1'b0;
			
		else if (apIndex[3] == 1'b1)
			begin
				if (a8_read_strobe)
					extAccessValid	<= 1'b0;
			end
		else
			extAccessValid  <= 1'b1;
			
    wire sdramRead 	    = (a8_rw == 1'b1) & extAccessValid;
    assign a8_mpd_n		    = ~sdramRead;
    assign a8_extsel_n	    = ~sdramRead;

    wire sdramWrite       = (a8_rw == 1'b0) & extAccessValid;
	
    ///////////////////////////////////////////////////////////////////////////
    // Instantiate the SDRAM controller 
    ///////////////////////////////////////////////////////////////////////////

endmodule
