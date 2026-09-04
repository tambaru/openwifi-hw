#!/bin/bash

home_dir=$(pwd)

set -ex

git submodule update --init --recursive adi-hdl
git -C adi-hdl clean -fdx

git submodule update --init --recursive ip/openofdm_rx
git -C ip/openofdm_rx clean -fdx

cd $home_dir
