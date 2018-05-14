
#!/bin/bas
GRLIB="/scratch-local/zhouji/grlib-com-l2c-1.4.3-b4160"




# check if path to GRLib installation is set
if [[ -z "$GRLIB" ]]; then
 echo "Path to GRLib installation (\$GRLIB) not set - terminating!"
 exit 1
fi

# check if path to Mentor ModelSim installation is set
if [[ -z "$MODELSIM_PATH" ]]; then
  if which vsim ; then
    echo "Found Modelsim/Questasim installation"
    export MODELSIM_PATH=`which vsim | sed -e "s#/bin/vsim##"`
  else
    echo "Path to Mentor ModelSim installation (\$MODELSIM_PATH) not set - terminating!"
    exit 1
  fi
fi


GRLIB_PATH=$GRLIB

echo GRLIB_PATH = $GRLIB
echo MODELSIM_PATH = $MODELSIM_PATH

echo $GRLIB_PATH


# Compile unisim and stuff 

mkdir -p ./xilinx_lib
if [ -d ./xilinx_lib/unisims_ver ]; then 
	echo "Xilinx library already compiled"; 
else 
	echo "compile_simlib -directory ./xilinx_lib/ -family all -language all -library all -simulator questasim" > ./xilinx_lib/invasic_simlib.tcl; 
	vivado -mode batch -source ./xilinx_lib/invasic_simlib.tcl ; 
fi;


# Map Libraries

if [ -d ./xilinx_lib/unisims_ver ]; then 
	vmap secureip_ver ./xilinx_lib/secureip ; 
	vmap secureip ./xilinx_lib/secureip ; 
	vmap axi_bfm ./xilinx_lib/secureip ; 
	vmap unisims_ver ./xilinx_lib/unisims_ver ; 
	vmap unisim ./xilinx_lib/unisim ; 
	vmap unimacro_ver ./xilinx_lib/unimacro_ver ; 
	vmap unimacro ./xilinx_lib/unimacro ; 
	vmap simprim_ver ./xilinx_lib/simprims_ver ; 
	vmap unifast_ver ./xilinx_lib/unifast_ver ; 
	vmap unifast ./xilinx_lib/unifast_ver ; 
else 
	echo "Xilinx Library not found. Please make sure you have installed the correct version of the Xilinx Library" ; exit 1 ; 
fi;


if [ -d libs ]; then
	rm -rf libs;
fi;
mkdir libs;

vlib libs/work
vlib libs/grlib
vlib libs/techmap
vlib libs/gaisler
vlib libs/custom
vlib libs/ssram_ctrl
vlib libs/esa
vlib libs/eth
vlib libs/opencores
vlib libs/fmf
vlib libs/micron
vlib libs/testgrouppolito
vlib libs/synplify
vlib libs/gsi
vlib libs/cypress
vlib libs/hynix

vmap work libs/work
vmap grlib libs/grlib
vmap techmap libs/techmap
vmap gaisler libs/gaisler
vmap custom libs/custom
vmap ssram_ctrl libs/ssram_ctrl
vmap esa libs/esa
vmap eth libs/eth
vmap opencores libs/opencores
vmap fmf libs/fmf
vmap micron libs/micron
vmap testgrouppolito libs/testgrouppolito
vmap synplify libs/synplify
vmap gsi libs/gsi
vmap cypress libs/cypress
vmap hynix libs/hynix



## Compile LEON sources

echo "now begin compile LEON sources!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; 

COMPILE_GAISLER_LIB=y

vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/version.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/config_types.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/config.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/stdlib.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/stdio.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/stdlib/testlib.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/util/util.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/sparc/sparc.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/sparc/sparc_disas.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/sparc/cpu_disas.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/modgen/multlib.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/modgen/leaves.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/amba.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/devices.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/defmst.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/apbctrl.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/apb3ctrl.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/ahbctrl.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/dma2ahb_pkg.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/dma2ahb.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/ahbmst.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/ahbmon.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/apbmon.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/apb3mon.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/ambamon.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/dma2ahb_tp.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/amba/amba_tp.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_pkg.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahb_mst_pkg.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahb_slv_pkg.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_util.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahb_mst.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahb_slv.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahbs.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/atf/at_ahb_ctrl.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/dftlib/dftlib.vhd
vcom -quiet  -93  -work grlib $GRLIB_PATH/lib/grlib/dftlib/synciotest.vhd
#vcom -quiet  -93  -work unisim $GRLIB_PATH/lib/tech/unisim/ise/unisim_VPKG.vhd
#vcom -quiet  -93  -work unisim $GRLIB_PATH/lib/tech/unisim/ise/unisim_VCOMP.vhd
#vcom -quiet  -93  -work unisim $GRLIB_PATH/lib/tech/unisim/ise/unisim_VITAL.vhd
vcom -quiet  -93  -work synplify $GRLIB_PATH/lib/synplify/sim/synplify.vhd
vcom -quiet  -93  -work synplify $GRLIB_PATH/lib/synplify/sim/synattr.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/gencomp/gencomp.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/gencomp/netcomp.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/memory_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/tap_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/ddr_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/mul_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/ddr_phy_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/scanreg_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/ddrphy_datapath.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/fifo_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/sim_pll.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/inferred/lpddr2_phy_inferred.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/memory_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/buffer_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/pads_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/clkgen_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/tap_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/ddr_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/ddr_phy_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/sysmon_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/mul_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/unisim/spictrl_unisim.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/allclkgen.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/techbuf.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/allddr.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/allmem.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/allmul.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/allpads.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/alltap.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkgen.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkmux.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkinv.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkand.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/grgates.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/ddr_ireg.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/ddr_oreg.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/clkpad_ds.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/inpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/inpad_ds.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/iodpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/iopad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/iopad_ds.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/lvds_combo.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/odpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/outpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/outpad_ds.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/toutpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/toutpad_ds.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/skew_outpad.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/ddrphy.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram64.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram_2p.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram_dp.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncfifo_2p.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/regfile_3p.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/tap.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/nandtree.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/grlfpw_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/grfpw_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/leon3_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/leon4_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/mul_61x61.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/cpu_disas_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/ringosc.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/grpci2_phy_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/system_monitor.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/inpad_ddr.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/outpad_ddr.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/iopad_ddr.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram128bw.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram256bw.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram128.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram156bw.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/techmult.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/spictrl_net.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/scanreg.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncrambw.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncram_2pbw.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/sdram_phy.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/from.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/syncreg.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/serdes.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/iopad_tm.vhd
vcom -quiet  -93  -work techmap $GRLIB_PATH/lib/techmap/maps/toutpad_tm.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/comp/ethcomp.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_pkg.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/eth_rstgen.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/eth_edcl_ahb_mst.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/eth_ahb_mst_gbit.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/eth_ahb_mst.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_gbit_rx.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_gbit_tx.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_gbit_gtx.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_tx.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_rx.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/greth_gbitc.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/core/grethc.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/wrapper/greth_gen.vhd
vcom -quiet  -93  -work eth $GRLIB_PATH/lib/eth/wrapper/greth_gbit_gen.vhd
vcom -quiet  -93  -work opencores $GRLIB_PATH/lib/opencores/i2c/i2c_master_bit_ctrl.vhd
vcom -quiet  -93  -work opencores $GRLIB_PATH/lib/opencores/i2c/i2c_master_byte_ctrl.vhd
vcom -quiet  -93  -work opencores $GRLIB_PATH/lib/opencores/i2c/i2coc.vhd
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/clean_rst.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/decoder_8b10b.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/encoder_8b10b.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_constants.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_regs.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_test.v
vlog -quiet  -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/timescale.v
vcom -quiet  -93  -work opencores $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_comp.vhd
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX.v
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_an.v
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_mdio.v
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_rx.v
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_sync.v
vlog -quiet  -sv -work opencores +incdir+$GRLIB_PATH/lib/opencores/ge_1000baseX $GRLIB_PATH/lib/opencores/ge_1000baseX/ge_1000baseX_tx.v
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/arith/arith.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/arith/mul32.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/arith/div32.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/memctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/sdctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/sdctrl64.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/sdmctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/srctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/memctrl/ssrctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmuconfig.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmuiface.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/libmmu.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmutlbcam.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmulrue.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmulru.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmutlb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmutw.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/srmmu/mmu.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3/leon3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3/grfpushwx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/tbufmem.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/tbufmem_2p.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/dsu3x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/dsu3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/dsu3_2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/dsu3_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/libfpu.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/libiu.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/libcache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/libleon3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/clk2xsync.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/clk2xqual.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/regfile_3p_l3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/mmu_acache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/mmu_icache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/mmu_dcache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/cachemem.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/mmu_cache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/grfpwx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/grlfpwx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/iu3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/proc3.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/grfpwxsh.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/leon3x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/leon3cg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/leon3s.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/leon3s2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/leon3sh.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/leon3v3/l3stat.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/irqmp/irqmp.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/irqmp/irqmp2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/irqmp/irqamp.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/irqmp/irqamp2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/pkg/l2cache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2clib.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2cfe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2cpipe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2cbe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2cmem.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2cahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cache/v3/l2c.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/misc.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/rstgen.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/gptimer.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbdpram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbtrace_mmb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbtrace_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbtrace.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grgpio.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbstat.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/logan.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/apbps2.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/charrom_package.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/charrom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/apbvga.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahb2ahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbbridge.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/svgactrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grfifo.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/gradcdac.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grsysmon.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/gracectrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grgpreg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahb_mst_iface.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grgprbank.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grclkgatex.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grclkgate.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grclkgate2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grtimer.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grpulse.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/grversion.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/misc/ahbfrom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/net/net.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/uart.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/libdcom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/apbuart.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/dcom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/dcom_uart.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/uart/ahbuart.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/sim.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/sram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/sram16.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/phy.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ser_phy.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ahbrep.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/delay_wire.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/pwm_check.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ramback.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/zbtssram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/slavecheck.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ddrram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ddr2ram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/ddr3ram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/sim/sdrtestmod.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/jtag.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/libjtagcom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/jtagcom.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/bscanctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/bscanregs.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/bscanregsbd.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/jtagcom2.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/ahbjtag.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/ahbjtag_bsd.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/jtag/jtagtst.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/ethernet_mac.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greth.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greth_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greth_gbit.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greths.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greth_gbit_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/greths_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/grethm.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/grethm_mb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/rgmii.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/comma_detect.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/sgmii.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/elastic_buffer.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/gmii_to_mii.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/greth/adapters/word_aligner.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddrpkg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddrintpkg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddrphy_wrap.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr2spax_ahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr2spax_ddr.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr2buf.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr2spax.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr2spa.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr1spax.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddr1spax_ddr.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ddrspa.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ahb2mig_7series_pkg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ahb2mig_7series.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ahb2mig_7series_ddr2.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ahb2avl_async.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/ahb2avl_async_be.vhd
vlog -quiet  -work gaisler $GRLIB_PATH/lib/gaisler/ddr/mig_interface_model.v
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2cmst.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2cmst_gen.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2cslv.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c2ahbx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c2ahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c2ahb_apb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c2ahb_gen.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c2ahb_apb_gen.vhd
vlog -quiet  -work gaisler $GRLIB_PATH/lib/gaisler/i2c/i2c_slave_model.v
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spi.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spimctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spictrlx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spictrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spi2ahbx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spi2ahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spi2ahb_apb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/spi/spi_flash.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/nand/nandpkg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/nand/nandfctrlx.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/nand/nandfctrl.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/clk2x/clk2x.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/clk2x/qmod.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/clk2x/qmod_prect.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/grdmac_pkg.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/apbmem.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/grdmac_ahbmst.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/grdmac_alignram.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/grdmac.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/grdmac/grdmac_1p.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cache.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2clib.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cfe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cpipe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cbe.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cmem.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2cahb.vhd
vcom -quiet  -93  -work gaisler $GRLIB_PATH/lib/gaisler/l2cachev3/l2c.vhd
vcom -quiet  -93  -work esa $GRLIB_PATH/lib/esa/memoryctrl/memoryctrl.vhd
vcom -quiet  -93  -work esa $GRLIB_PATH/lib/esa/memoryctrl/mctrl.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/utilities/conversions.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/utilities/gen_utils.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/flash/flash.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/flash/s25fl064a.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/flash/m25p80.vhd
vcom -quiet  -93  -work fmf $GRLIB_PATH/lib/fmf/fifo/idt7202.vhd
vcom -quiet  -93  -work gsi $GRLIB_PATH/lib/gsi/ssram/functions.vhd
vcom -quiet  -93  -work gsi $GRLIB_PATH/lib/gsi/ssram/core_burst.vhd
vcom -quiet  -93  -work gsi $GRLIB_PATH/lib/gsi/ssram/g880e18bt.vhd
vcom -quiet  -93  -work cypress $GRLIB_PATH/lib/cypress/ssram/components.vhd
vcom -quiet  -93  -work cypress $GRLIB_PATH/lib/cypress/ssram/package_utility.vhd
vcom -quiet  -93  -work cypress $GRLIB_PATH/lib/cypress/ssram/cy7c1354b.vhd
vcom -quiet  -93  -work cypress $GRLIB_PATH/lib/cypress/ssram/cy7c1380d.vhd
vcom -quiet  -93  -work hynix $GRLIB_PATH/lib/hynix/ddr2/HY5PS121621F_PACK.vhd
vcom -quiet  -93  -work hynix $GRLIB_PATH/lib/hynix/ddr2/HY5PS121621F.vhd
vcom -quiet  -93  -work hynix $GRLIB_PATH/lib/hynix/ddr2/components.vhd
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/sdram/mobile_sdr.v
vcom -quiet  -93  -work micron $GRLIB_PATH/lib/micron/sdram/components.vhd
vcom -quiet  -93  -work micron $GRLIB_PATH/lib/micron/sdram/mt48lc16m16a2.vhd
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/ddr2.v
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mobile_ddr.v
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/ddr3.v
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mobile_ddr_fe.v
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/ddr3_model.v
vlog -quiet  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mobile_ddr2_fe.v
vcom -quiet  -93  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mt46v16m16.vhd
vcom -quiet  -93  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mobile_ddr_febe.vhd
vcom -quiet  -93  -work micron $GRLIB_PATH/lib/micron/ddr_sdram/mobile_ddr2_febe.vhd
vcom -quiet  -93  -work work $GRLIB_PATH/lib/work/debug/debug.vhd
vcom -quiet  -93  -work work $GRLIB_PATH/lib/work/debug/grtestmod.vhd
vcom -quiet  -93  -work work $GRLIB_PATH/lib/work/debug/cpu_disas.vhd


vlog -quiet glbl.v

vcom -quiet  -93  -work work config.vhd
vcom -quiet  -93  -work work ahbrom.vhd

#vcom -quiet  -93  -work work amba_interface.vhd  
#vcom -quiet  -93  -work work test_tcpa_comp.vhd

vcom -quiet  -93  -work work $GRLIB_PATH/designs/leon3-minimal/test_connection_only/test_tcpa_comp.vhd
vcom -quiet  -93  -work work $GRLIB_PATH/designs/leon3-minimal/test_connection_only/amba_interface.vhd  
vcom -quiet  -93  -work work $GRLIB_PATH/designs/leon3-minimal/test_connection_only/leon3mp.vhd




vcom -quiet  -93  -work work testbench.vhd




## Start Modelsim


VSIMOPT="-novopt -t 1ps -L unisims_ver -L secureip glbl"
vsim  $VSIMOPT testbench

