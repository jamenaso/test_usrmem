#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.2.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Wed Oct 31 17:02:07 -05 2018
# SW Build 2348494 on Mon Oct  1 18:25:39 MDT 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xsim testbench_behav -key {Behavioral:sim_1:Functional:testbench} -tclbatch testbench.tcl -view /home/jamm/Documentos/pruebas_unitarias_TFC/memoria_usuario/testbench_behav.wcfg -log simulate.log
