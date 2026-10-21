## Generated SDC file "golden_top.out.sdc"

## Copyright (C) 2025  Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Altera and sold by Altera or its authorized distributors.  Please
## refer to the Altera Software License Subscription Agreements 
## on the Quartus Prime software download page.


## VENDOR  "Intel Corporation"
## PROGRAM "Quartus Prime"
## VERSION "Version 25.1.0 Build 129 03/26/2025 SC Pro Edition"

## DATE    "Tue Jun 24 09:44:34 2025"

##
## DEVICE  "A3CZ135BB18AE7S"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK0_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK0_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0} -source [get_ports {CLOCK0_50}] -master_clock {CLOCK0_50} [get_pins {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] 
create_generated_clock -name {u_sys_pll|iopll_0_n_cnt_clk} -source [get_pins {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] -duty_cycle 50/1 -multiply_by 1 -divide_by 3 -master_clock {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0} [get_registers {u_sys_pll|iopll_0|tennm_ph2_iopll~ncntr_reg}] 
create_generated_clock -name {u_sys_pll|iopll_0_m_cnt_clk} -source [get_registers {u_sys_pll|iopll_0|tennm_ph2_iopll~ncntr_reg}] -duty_cycle 50/1 -multiply_by 1 -master_clock {u_sys_pll|iopll_0_n_cnt_clk} [get_registers {u_sys_pll|iopll_0|tennm_ph2_iopll~mcntr_reg}] 
create_generated_clock -name {u_sys_pll|iopll_0_outclk0} -source [get_registers {u_sys_pll|iopll_0|tennm_ph2_iopll~ncntr_reg}] -duty_cycle 50/1 -multiply_by 49 -divide_by 11 -master_clock {u_sys_pll|iopll_0_n_cnt_clk} [get_pins {u_sys_pll|iopll_0|tennm_ph2_iopll|out_clk[0]}] 
create_generated_clock -name {u_sys_pll|iopll_0_outclk1} -source [get_registers {u_sys_pll|iopll_0|tennm_ph2_iopll~ncntr_reg}] -duty_cycle 50/1 -multiply_by 49 -divide_by 510 -master_clock {u_sys_pll|iopll_0_n_cnt_clk} [get_pins {u_sys_pll|iopll_0|tennm_ph2_iopll|out_clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CLOCK0_50}] -rise_to [get_clocks {CLOCK0_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK0_50}] -fall_to [get_clocks {CLOCK0_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK0_50}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.470  
set_clock_uncertainty -rise_from [get_clocks {CLOCK0_50}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.470  
set_clock_uncertainty -fall_from [get_clocks {CLOCK0_50}] -rise_to [get_clocks {CLOCK0_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK0_50}] -fall_to [get_clocks {CLOCK0_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK0_50}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.470  
set_clock_uncertainty -fall_from [get_clocks {CLOCK0_50}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.470  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}] -rise_to [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}] -fall_to [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}] -rise_to [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}] -fall_to [get_clocks {u_sys_pll|iopll_0_m_cnt_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}] -rise_to [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}] -fall_to [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}] -rise_to [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}] -fall_to [get_clocks {u_sys_pll|iopll_0_n_cnt_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_outclk0}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_outclk0}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_outclk0}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_outclk0}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk0}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_outclk1}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk1}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0_outclk1}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk1}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_outclk1}] -rise_to [get_clocks {u_sys_pll|iopll_0_outclk1}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0_outclk1}] -fall_to [get_clocks {u_sys_pll|iopll_0_outclk1}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] -rise_to [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}]  0.460  
set_clock_uncertainty -rise_from [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] -fall_to [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}]  0.460  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] -rise_to [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}]  0.460  
set_clock_uncertainty -fall_from [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}] -fall_to [get_clocks {u_sys_pll|iopll_0|tennm_ph2_iopll|ref_clk0}]  0.460  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers -no_duplicates {r0|oRESET}] -to [get_keepers -no_duplicates {hdmi_ins|LTM_ins|reset_sync}]
set_false_path -through [get_pins {u_sys_pll|iopll_0|tennm_ph2_iopll|reset}]  
set_false_path -from [get_keepers -no_duplicates {r0|oRESET}] -to [get_keepers -no_duplicates {hdmi_ins|iRST_n_sync}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

