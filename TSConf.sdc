# Clock constraints

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# Clock groups
set_clock_groups -asynchronous -group [get_clocks spiclk] -group [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks $hostclk] -group [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks $supportclk] -group [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[*]]

# SDRAM
set_input_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]] -reference_pin [get_ports ${RAM_CLK}] -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]] -reference_pin [get_ports ${RAM_CLK}] -min 3.2 [get_ports ${RAM_IN}]

# SDRAM: max(tCMS, tAS, tDS) = 1.5ns ; max(tCMH, tAH, tDH) = 0.8ns
set_output_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]] -reference_pin [get_ports ${RAM_CLK}] -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]] -reference_pin [get_ports ${RAM_CLK}] -min -0.8 [get_ports ${RAM_OUT}]

# SDRAM_CLK to internal memory clock
set_multicycle_path -from [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]] -to [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[1]] -setup 2

# Some relaxed constrain to the VGA pins. The signals should arrive together, the delay is not really important.
set_output_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[1]] -max 0 [get_ports ${VGA_OUT}]
set_output_delay -clock [get_clocks ${topmodule}pll|altpll_component|auto_generated|pll1|clk[1]] -min -5 [get_ports ${VGA_OUT}]

# Some relaxed constrain for DAC, which is feed by 28 MHz derived clock
set_multicycle_path -to ${topmodule}dac|* -setup 3
set_multicycle_path -to ${topmodule}dac|* -hold 2
set_false_path -to ${FALSE_OUT}
set_false_path -to ${VGA_OUT}
set_false_path -from ${FALSE_IN}

set_multicycle_path -from ${topmodule}tsconf|CPU|* -setup 2
set_multicycle_path -from ${topmodule}tsconf|CPU|* -hold 1
set_multicycle_path -to ${topmodule}tsconf|CPU|* -setup 2
set_multicycle_path -to ${topmodule}tsconf|CPU|* -hold 1

set_multicycle_path -to ${topmodule}tsconf|saa1099|* -setup 2
set_multicycle_path -to ${topmodule}tsconf|saa1099|* -hold 1

set_multicycle_path -to ${topmodule}tsconf|gs_top|gs|CPU|* -setup 2
set_multicycle_path -to ${topmodule}tsconf|gs_top|gs|CPU|* -hold 1
