/*************************************************************************
 * File:			fetch.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Structural for fetch block. Changed from bdf to vhdl.
 * 	16-entry BHT with 2-bit saturating counters indexing with pc[5..2]
 *		Branch target calculation in fetch to remove penalty for correctly
 *		predicted branches and JAL.
*************************************************************************/