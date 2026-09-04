  
#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "You must enter exactly 1 arguments: \$XILINX_DIR"
    exit 1
fi

XILINX_DIR=$1

echo "VIVADO_DIR ${VIVADO_DIR:=$XILINX_DIR/Vivado/2023.2}"

if [ -d "$VIVADO_DIR" ]; then
    echo "\$VIVADO_DIR is found!"
else
    echo "\$VIVADO_DIR is not correct. Please check!"
    exit 1
fi

home_dir=$(pwd)

set -x

cd adi-hdl
git clean -fdx

echo "The build process uses ${NUM_THREADS:=$(nproc)} theads"

if [ -f "$VIVADO_DIR/settings64.sh" ]; then
    source "$VIVADO_DIR/settings64.sh"
else
    echo "ERROR: Vivado settings file not found!"
    exit 1
fi

cd library/
make -j${NUM_THREADS}

cd $home_dir
