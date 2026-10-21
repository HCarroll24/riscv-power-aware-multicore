# (C) 2001-2025 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# SPI IP SDC


#-------------------------------------------------------------------------------------
#----------------- Variable Multicycle (MC) constraint for SPI IP --------------------
#-------------------------------------------------------------------------------------


if {[get_current_instance] == ""} { set ipath "" } else { set ipath "[get_current_instance]" } 

#Expected output (if no rename to the IP instance) is spi_0|spi_0 else will be {user_defined_name}|spi_0
post_message -type info "\[SPI_4_WIRE\] Following instance found in the design --- $ipath"

##This is needed to obtain only the topmost (user-facing) hierarchy
##Cannot use string trim command because of repeated name "spi_0|spi_0", else will remove the entire string
#set ipath_modified [regsub {\|spi_0} $ipath {}]
#post_message -type info "ipath_modified is $ipath_modified"

create_generated_clock -name spi_gen_clk -divide_by {400} -source [get_pins $ipath|tx_holding_primed|clk] [get_pins $ipath|SCLK_reg|q]


#---- case: 15011861492 Setup timing violation spotted in JESD IP example design----

#From node tx_holding_reg[MSB] to shift_reg[MSB]

#set_multicycle_path -from [get_keepers $ipath|tx_holding_reg[7]]  -to [get_keepers  $ipath|shift_reg[7]] -setup -start 200
 
#set_multicycle_path -from [get_keepers $ipath|tx_holding_reg[7]]  -to [get_keepers  $ipath|shift_reg[7]] -hold -start 199


#From node shift_reg[MSB] to spi_0_external_MOSI

#set_multicycle_path -from [get_keepers $ipath|shift_reg[7]]  -to [get_keepers spi*MOSI] -setup -start 200

#set_multicycle_path -from [get_keepers $ipath|shift_reg[7]]  -to [get_keepers spi*MOSI] -hold -start 199


#From node stateZero to spi_0_external_SS_n[0]

#set_multicycle_path -from [get_keepers $ipath|stateZero]  -to [get_keepers *SS_n] -setup -start 200

#set_multicycle_path -from [get_keepers $ipath|stateZero]  -to [get_keepers *SS_n] -hold -start 199


#From node spi_slave_select_reg[0] to spi_0_external_SS_n[0]

#set_multicycle_path -from [get_keepers $ipath|spi_slave_select_reg[0]]  -to [get_keepers *SS_n] -setup -start 200

#set_multicycle_path -from [get_keepers $ipath|spi_slave_select_reg[0]]  -to [get_keepers *SS_n] -hold -start 199

#set_multicycle_path -from [get_keepers  $ipath|transmitting] -to [get_keepers  *SS_n] -setup -start 200

#set_multicycle_path -from [get_keepers  $ipath|transmitting] -to [get_keepers  *SS_n] -hold -start 199


# From node SSO_reg to spi_slave_select_reg[*] and transmitting to spi_slave_select_reg[*]
#-----setup-----
#set_multicycle_path -from [get_keepers  $ipath|SSO_reg] -to [get_keepers  $ipath|spi_slave_select_reg[*]] -setup -start 200

#set_multicycle_path -from [get_keepers  $ipath|transmitting] -to [get_keepers  $ipath|spi_slave_select_reg[*]] -setup -start 200

#------hold------
#set_multicycle_path -from [get_keepers  $ipath|SSO_reg] -to [get_keepers  $ipath|spi_slave_select_reg[*]] -hold -start 199

#set_multicycle_path -from [get_keepers  $ipath|transmitting] -to [get_keepers $ipath|spi_slave_select_reg[*]] -hold -start 199

#---------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------
#----------------- FIXED constraint for SPI IP ---------------------------------------
#-------------------------------------------------------------------------------------
# Please add any fixed constraint below



#-------------------------------------------------------------------------------------
#--- Please dont make any changes below as it will be used for SDC naming purpose ----
#-------------------------------------------------------------------------------------

proc apply_sdc_pre_spi {entity_name} {

set inst_list [get_entity_instances $entity_name]

}

apply_sdc_pre_spi nios_system_spi_0_altera_avalon_spi_1926_4ejcwdi
