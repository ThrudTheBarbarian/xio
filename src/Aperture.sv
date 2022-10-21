`include "defines.sv"

///////////////////////////////////////////////////////////////////////////////
// Full Aperture definition:
// 
// $+0000 [4]	: Base address in SDRAM for start of memory aperture
// $+0004 [1]	: Page index in host-memory for start of memory aperture
// $+0005 [1]	: Page index in host-memory for end of memory aperture
// $+0006 [1]	: 'stride', or 256-byte pages per horizontal line
// $+0007 [1]	: Reserved for future use
// 
///////////////////////////////////////////////////////////////////////////////
module Aperture
	(
    input	wire			clk,		// Main FPGA clock 
	input	wire			a8_rst_n,	// A8 /RST signal
	input	wire			a8_rw,  	// A8 read(1) or write(0) signal
	input 	wire [7:0]		a8_data,	// A8 data bus value
	input	wire [15:0]		a8_addr,	// A8 address bus
	input	wire [3:0]		index,		// The identifier
	input	wire			aValid,		// Address is valid
	input 	wire			wValid,		// Write op is valid
	
	output 	wire			inRange,	// Is the page one of ours
	output 	reg [7:0]		apCfg,		// Results of the read op
	output 	reg 			apCfgValid,	// Strobe to say the data is valid
	output	wire [26:0]	    baseAddr	// Address currently set in SDRAM
	);

	parameter CFG_SPACE = 8'hD7;		// We use the RAM at $D7xx (xx:00..7F) 
										// for 16 8-byte descriptors
	parameter RAMH		= 27;			// The DDR3 SDRAM is 1Gbit in size, 
										// so we have 128MBytes of space, which
										// takes 27 bits to represent

    ///////////////////////////////////////////////////////////////////////////
    // Registers to hold the aperture configuration  
    ///////////////////////////////////////////////////////////////////////////
    reg		[RAMH-1:0]	sramAddr;		// Base address in SRAM 
	reg		[7:0]		lo;				// Lowest page
	reg		[7:0]		hi;				// Highest page
	reg		[7:0]		stride;			// # pages per horiz line


    ///////////////////////////////////////////////////////////////////////////
    // Check to see if a8_addr is in range  
    ///////////////////////////////////////////////////////////////////////////
	wire loMatch 		= (lo <= a8_addr[15:8]);
	wire hiMatch		= (hi >= a8_addr[15:8]);
	assign inRange		= loMatch & hiMatch & aValid;


    ///////////////////////////////////////////////////////////////////////////
    // Check to see if we're writing or reading the config space for this 
    // aperture
    ///////////////////////////////////////////////////////////////////////////
	wire addrMatch	= (a8_addr[6:3] == index) & (a8_addr[15:8] == CFG_SPACE);

    ///////////////////////////////////////////////////////////////////////////
    // Tell the parent what the current address is
    ///////////////////////////////////////////////////////////////////////////
	assign baseAddr		= sramAddr;
	
	always @ (posedge clk)
		if (a8_rst_n == 1'b0)
			begin
				sramAddr		<= {RAMH{1'b0}};
				lo				<= 8'b0;
				hi				<= 8'b0;
				apCfgValid		<= 1'b0;
				apCfg			<= 8'hff;
			end
			
		else if (a8_rw == 1'b0)
			begin
				///////////////////////////////////////////////////////////////
				// Have to wait for a8_data to be valid  
				///////////////////////////////////////////////////////////////
				if (wValid && addrMatch)
					case (a8_addr[3:0])
						4'h0:		sramAddr[RAMH-1:24] 	<= a8_data[RAMH-25:0];
						4'h1:		sramAddr[23:16]			<= a8_data;
						4'h2:		sramAddr[15:8]			<= a8_data;
						4'h3:		sramAddr[7:0]			<= a8_data;
						4'h4:		lo 						<= a8_data;
						4'h5:		hi						<= a8_data;
						4'h6:		stride					<= a8_data;
						default:	lo						<= lo;
					endcase
			end
		else
			begin
				///////////////////////////////////////////////////////////////
				// We deliberately (aValid) return the value early  
				///////////////////////////////////////////////////////////////
				if (aValid && addrMatch)
					begin
						case (a8_addr[3:0])
							4'h0:		apCfg <= 	{5'b0,sramAddr[RAMH-1:RAMH-3]};
							4'h1:		apCfg <= 	sramAddr[23:16];
							4'h2:		apCfg <= 	sramAddr[15:8];
							4'h3:		apCfg <= 	sramAddr[7:0];
							4'h4:		apCfg <= 	lo;
							4'h5:		apCfg <= 	hi;
							4'h6:		apCfg <= 	stride;
							default:	apCfg <=	8'hff;
						endcase
						apCfgValid 			  <= 1'b1;
					end
				else
					apCfgValid <= 1'b0;
			end

			
endmodule

