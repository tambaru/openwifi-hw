#!/bin/bash

# Author: Xianjun jiao
# SPDX-FileCopyrightText: 2022 UGent
# SPDX-License-Identifier: AGPL-3.0-or-later

print_usage () {
  echo "usage:"
  echo "create_ip_repo.sh \$VITIS_DIR"
  echo "or"
  echo "create_ip_repo.sh \$XILINX_DIR \$IP1_NAME \$DEF1 \$DEF2 ... \$IP2_NAME \$DEF1 ..."
  echo " -IP_NAME: only xpu/tx_intf/rx_intf/openofdm_tx/openofdm_rx/side_ch are allowed"
  echo " -   DEFx: will be \"\`define IP_NAME_DEFx\" in ip_name_pre_def.v for \$IP_NAME"
  echo " "
}

print_usage

if [ "$#" -lt 1 ]; then
    exit 1
fi

XILINX_DIR=$1

start_to_write=0
mkdir -p ip_config
rm -rf ip_config/*

BOARD_NAME=${PWD##*/}
echo "BOARD_NAME $BOARD_NAME"
echo "XILINX_DIR $XILINX_DIR"
echo "VITIS_DIR ${VITIS_DIR:=$XILINX_DIR/Vitis/2023.2/}"

XILINX_ENV_FILE=$VITIS_DIR/settings64.sh
echo "Expect env file $XILINX_ENV_FILE"

if [ -f "$XILINX_ENV_FILE" ]; then
    echo "$XILINX_ENV_FILE is found!"
else
    echo "$XILINX_ENV_FILE is not correct. Please check!"
    exit 1
fi

MODULE_NAME=""
for ARGUMENT in "$@"
do
    if [ "$ARGUMENT" = "xpu" ] || [ "$ARGUMENT" = "tx_intf" ] || [ "$ARGUMENT" = "rx_intf" ] || [ "$ARGUMENT" = "openofdm_tx" ] || [ "$ARGUMENT" = "openofdm_rx" ] || [ "$ARGUMENT" = "side_ch" ]; then
        start_to_write=1
    fi

    if [ $start_to_write == "1" ]; then
        if [ "$ARGUMENT" = "xpu" ] || [ "$ARGUMENT" = "tx_intf" ] || [ "$ARGUMENT" = "rx_intf" ] || [ "$ARGUMENT" = "openofdm_tx" ] || [ "$ARGUMENT" = "openofdm_rx" ] || [ "$ARGUMENT" = "side_ch" ]; then
            filename_to_write=ip_config/$ARGUMENT"_pre_def.v"
            echo "" >> $filename_to_write
            echo "//Pre defines for IP $ARGUMENT. Please align with those when you design/customize/modify the IP" >> $filename_to_write
            
            echo ""
            MODULE_NAME=${ARGUMENT^^}
            echo "$MODULE_NAME:"
        else
            echo "\`define ${MODULE_NAME}_${ARGUMENT}" >> $filename_to_write

            echo "\`define ${MODULE_NAME}_${ARGUMENT}"
        fi
    fi
done

source $XILINX_ENV_FILE

set -x

if [[ "$VIVADO_BATCH_MODE" == "1" || "$VIVADO_BATCH_MODE" == "true" ]]; then
    vivado -mode batch -source ../ip_repo_gen.tcl
else 
    vivado -source ../ip_repo_gen.tcl
fi

set +x
