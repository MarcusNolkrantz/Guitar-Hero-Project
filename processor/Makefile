# Makefile for hardware implementation on Xilinx FPGAs and ASICs
# Author: Andreas Ehliar <ehliar@isy.liu.se>
#
# T is the testbench file for this project
# S is the synthesizable sources for this project
# U is the UCF file
# PART is the part

# Important makefile targets:
# make lab.sim		GUI simulation
# make lab.simc		batch simulation
# make lab.synth	Synthesize
# make lab.route	Route the design
# make lab.bitgen	Generate bit file
# make lab.timing	Generate timing report
# make lab.clean	Use whenever you change settings in the Makefile!
# make lab.prog		Downloads the bitfile to the FPGA. NOTE: Does not
#                       rebuild bitfile if source files have changed!
# make clean            Removes all generated files for all projects. Also
#                       backup files (*~) are removed.
#
# VIKTIG NOTERING: 	Om du ändrar vilka filer som finns med i projektet så måste du köra
#                  	make lab.clean
#
# Syntesrapporten ligger i lab-synthdir/xst/synth/design.syr
# Maprapporten (bra att kolla i för arearapportens skull) ligger i lab-synthdir/layoutdefault/design_map.mrp
# Timingrapporten (skapas av make lab.timing) ligger i lab-synthdir/layoutdefault/design.trw

# (Or proj2.simc, proj2.sim, etc, depending on the name of the
# project)

XILINX_INIT = source /sw/xilinx/ise_12.4i/ISE_DS/settings64.sh;
PART=xc6slx16-3-csg324


proj.%: S=pipeCPU.vhd PM/PM.vhd ALU/ALU.vhd registers/REG.vhd tile_pic_mem/tile_pic_mem.vhd tile_mem/tile_mem.vhd RAM/RAM.vhd audio/audio.vhd audio_map_mem/audio_map_mem.vhd audio_motor/audio_motor.vhd kb_enc/kb_unit.vhd sprite_pic_mem/sprite_pic_mem.vhd VGA_motor/VGA_motor.vhd AD/AD.vhd sprite_mem/sprite_mem.vhd kb_enc/kb_mem.vhd kb_enc/kb_enc.vhd DM/DM.vhd
proj.%: T=pipeCPU_tb.vhd
proj.%: U=pipeCPU.ucf

#kb_enc/kb_mem.vhd kb_enc/kb_enc.vhd kb_enc/kb_unit.vhd
# Det här är ett exempel på hur man kan skriva en testbänk som är
# relevant, även om man kör en simulering i batchläge (make batchlab.simc)
#batchlab.%: S=cpu_embryo.vhd
#batchlab.%: T=cpu_embryo_tb.vhd
#batchlab.%: U=Nexys3_Master.ucf


# Misc functions that are good to have
include build/util.mk
# Setup simulation environment
include build/vsim.mk
# Setup synthesis environment
include build/xst.mk
# Setup backend flow environment
include build/xilinx-par.mk
# Setup tools for programming the FPGA
include build/digilentprog.mk



# Alternative synthesis methods
# The following is for ASIC synthesis
#include design_compiler.mk
# The following is for synthesis to a Xilinx target using Precision.
#include precision-xilinx.mk
