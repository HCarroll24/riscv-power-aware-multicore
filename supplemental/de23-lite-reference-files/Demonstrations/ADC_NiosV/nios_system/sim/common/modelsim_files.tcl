source [file join [file dirname [info script]] ./../../../ip/nios_system/reset_bridge/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/sysid_qsys/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/iopll/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/onchip_memory/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/mm_bridge_peripheral/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/niosv_g/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/nios_system_spi_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/clock_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/pio_sw/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/reset_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/jtag_uart/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/nios_system/reset_release/sim/common/modelsim_files.tcl]

namespace eval nios_system {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [reset_bridge::get_design_libraries]]
    set libraries [dict merge $libraries [sysid_qsys::get_design_libraries]]
    set libraries [dict merge $libraries [iopll::get_design_libraries]]
    set libraries [dict merge $libraries [onchip_memory::get_design_libraries]]
    set libraries [dict merge $libraries [mm_bridge_peripheral::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_g::get_design_libraries]]
    set libraries [dict merge $libraries [nios_system_spi_0::get_design_libraries]]
    set libraries [dict merge $libraries [clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [pio_sw::get_design_libraries]]
    set libraries [dict merge $libraries [reset_in::get_design_libraries]]
    set libraries [dict merge $libraries [jtag_uart::get_design_libraries]]
    set libraries [dict merge $libraries [reset_release::get_design_libraries]]
    dict set libraries altera_merlin_axi_translator_1974    1
    dict set libraries altera_merlin_slave_translator_191   1
    dict set libraries altera_merlin_axi_master_ni_19100    1
    dict set libraries altera_merlin_slave_agent_1930       1
    dict set libraries altera_avalon_sc_fifo_1932           1
    dict set libraries altera_merlin_router_1921            1
    dict set libraries altera_merlin_traffic_limiter_1921   1
    dict set libraries altera_avalon_st_pipeline_stage_1930 1
    dict set libraries altera_merlin_burst_adapter_1940     1
    dict set libraries altera_merlin_demultiplexer_1921     1
    dict set libraries altera_merlin_multiplexer_1922       1
    dict set libraries altera_mm_interconnect_1920          1
    dict set libraries altera_merlin_master_translator_193  1
    dict set libraries altera_merlin_master_agent_1931      1
    dict set libraries altera_irq_mapper_2001               1
    dict set libraries altera_reset_controller_1924         1
    dict set libraries nios_system                          1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [reset_bridge::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/reset_bridge/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [sysid_qsys::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/sysid_qsys/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [iopll::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/iopll/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [onchip_memory::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/onchip_memory/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [mm_bridge_peripheral::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/mm_bridge_peripheral/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_g::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/niosv_g/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [nios_system_spi_0::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/nios_system_spi_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pio_sw::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/pio_sw/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [jtag_uart::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/jtag_uart/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [reset_release::get_memory_files "$QSYS_SIMDIR/../../ip/nios_system/reset_release/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [reset_bridge::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_bridge/sim/"]]
    set design_files [dict merge $design_files [sysid_qsys::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/sysid_qsys/sim/"]]
    set design_files [dict merge $design_files [iopll::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/iopll/sim/"]]
    set design_files [dict merge $design_files [onchip_memory::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/onchip_memory/sim/"]]
    set design_files [dict merge $design_files [mm_bridge_peripheral::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/mm_bridge_peripheral/sim/"]]
    set design_files [dict merge $design_files [niosv_g::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/niosv_g/sim/"]]
    set design_files [dict merge $design_files [nios_system_spi_0::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/nios_system_spi_0/sim/"]]
    set design_files [dict merge $design_files [clock_in::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/clock_in/sim/"]]
    set design_files [dict merge $design_files [pio_sw::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/pio_sw/sim/"]]
    set design_files [dict merge $design_files [reset_in::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_in/sim/"]]
    set design_files [dict merge $design_files [jtag_uart::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/jtag_uart/sim/"]]
    set design_files [dict merge $design_files [reset_release::get_common_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_release/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [reset_bridge::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_bridge/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [sysid_qsys::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/sysid_qsys/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [iopll::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/iopll/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [onchip_memory::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/onchip_memory/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [mm_bridge_peripheral::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/mm_bridge_peripheral/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_g::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/niosv_g/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [nios_system_spi_0::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/nios_system_spi_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [clock_in::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pio_sw::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/pio_sw/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [reset_in::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [jtag_uart::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/jtag_uart/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [reset_release::get_design_files "$QSYS_SIMDIR/../../ip/nios_system/reset_release/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "-makelib altera_merlin_axi_translator_1974 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_translator_1974/sim/nios_system_altera_merlin_axi_translator_1974_xfkiwxi.sv"]\"   -end"                            
    lappend design_files "-makelib altera_merlin_slave_translator_191 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/nios_system_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_axi_master_ni_19100 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19100/sim/altera_merlin_address_alignment.sv"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_axi_master_ni_19100 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19100/sim/nios_system_altera_merlin_axi_master_ni_19100_y3ctica.sv"]\"   -end"                            
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/nios_system_altera_merlin_slave_agent_1930_jxauz3i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/altera_merlin_burst_uncompressor.sv"]\"   -end"                                                       
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/nios_system_altera_avalon_sc_fifo_1932_22gxxgi.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_gmm3fdq.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_hukm2cq.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_qyvgeei.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_xnxkgda.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/nios_system_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_te3kfhq.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                   
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/nios_system_altera_merlin_traffic_limiter_1921_5pm4apa.sv"]\"   -end"                         
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/nios_system_altera_avalon_st_pipeline_stage_1930_oiupeiq.sv"]\"   -end"                   
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                              
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/nios_system_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1940_amki4ia.v"]\"   -end"
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/nios_system_altera_merlin_burst_adapter_1940_d2k55uq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_uncmpr.sv"]\"   -end"                                                 
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_13_1.sv"]\"   -end"                                                   
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_new.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_incr_burst_converter.sv"]\"   -end"                                                        
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_wrap_burst_converter.sv"]\"   -end"                                                        
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_default_burst_converter.sv"]\"   -end"                                                     
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_address_alignment.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/nios_system_altera_merlin_demultiplexer_1921_usuzvxq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/nios_system_altera_merlin_demultiplexer_1921_whzax3q.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_cvbulrq.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_33mlhei.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/nios_system_altera_merlin_demultiplexer_1921_ajr4npq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_gilod4i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_r6mavia.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/nios_system_altera_mm_interconnect_1920_gvlg2ai.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_master_translator_193 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/nios_system_altera_merlin_master_translator_193_lgcew2q.sv"]\"   -end"                      
    lappend design_files "-makelib altera_merlin_master_agent_1931 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1931/sim/nios_system_altera_merlin_master_agent_1931_jtx3eyy.sv"]\"   -end"                                  
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_r4sqfxq.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/nios_system_altera_merlin_router_1921_pfc4ega.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/nios_system_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_a53nykq.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                   
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/nios_system_altera_merlin_traffic_limiter_1921_p3fvlba.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/nios_system_altera_merlin_demultiplexer_1921_bixj62q.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_vgugpha.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/nios_system_altera_merlin_demultiplexer_1921_jqica2q.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/nios_system_altera_merlin_multiplexer_1922_dcphjea.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                               
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/nios_system_altera_mm_interconnect_1920_g7zuaki.v"]\"   -end"                                               
    lappend design_files "-makelib altera_irq_mapper_2001 \"[normalize_path "$QSYS_SIMDIR/../altera_irq_mapper_2001/sim/nios_system_altera_irq_mapper_2001_k3auftq.sv"]\"   -end"                                                             
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                                                     
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                                                   
    lappend design_files "-makelib nios_system \"[normalize_path "$QSYS_SIMDIR/nios_system.v"]\"   -end"                                                                                                                                      
    return $design_files
  }
  
  proc get_non_duplicate_elab_option {ELAB_OPTIONS NEW_ELAB_OPTION} {
    set IS_DUPLICATE [string first $NEW_ELAB_OPTION $ELAB_OPTIONS]
    if {$IS_DUPLICATE == -1} {
      return $NEW_ELAB_OPTION
    } else {
      return ""
    }
  }
  
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [reset_bridge::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [sysid_qsys::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [iopll::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [onchip_memory::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [mm_bridge_peripheral::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_g::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [nios_system_spi_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pio_sw::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [jtag_uart::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [reset_release::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [reset_bridge::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [sysid_qsys::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [iopll::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [onchip_memory::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [mm_bridge_peripheral::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_g::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [nios_system_spi_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pio_sw::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [jtag_uart::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [reset_release::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [reset_bridge::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [sysid_qsys::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [iopll::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [onchip_memory::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [mm_bridge_peripheral::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_g::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [nios_system_spi_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pio_sw::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [jtag_uart::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [reset_release::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    set libraries [dict merge $libraries [reset_bridge::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/reset_bridge/sim/"]]
    set libraries [dict merge $libraries [sysid_qsys::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/sysid_qsys/sim/"]]
    set libraries [dict merge $libraries [iopll::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/iopll/sim/"]]
    set libraries [dict merge $libraries [onchip_memory::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/onchip_memory/sim/"]]
    set libraries [dict merge $libraries [mm_bridge_peripheral::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/mm_bridge_peripheral/sim/"]]
    set libraries [dict merge $libraries [niosv_g::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/niosv_g/sim/"]]
    set libraries [dict merge $libraries [nios_system_spi_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/nios_system_spi_0/sim/"]]
    set libraries [dict merge $libraries [clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/clock_in/sim/"]]
    set libraries [dict merge $libraries [pio_sw::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/pio_sw/sim/"]]
    set libraries [dict merge $libraries [reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/reset_in/sim/"]]
    set libraries [dict merge $libraries [jtag_uart::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/jtag_uart/sim/"]]
    set libraries [dict merge $libraries [reset_release::get_dpi_libraries "$QSYS_SIMDIR/../../ip/nios_system/reset_release/sim/"]]
    
    return $libraries
  }
  
}
