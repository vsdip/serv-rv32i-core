#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p build

iverilog -g2012 -s serv_rf_top \
  -Pserv_rf_top.W=1 \
  -Pserv_rf_top.WITH_CSR=1 \
  -Pserv_rf_top.COMPRESSED=0 \
  -Pserv_rf_top.ALIGN=0 \
  -Pserv_rf_top.MDU=0 \
  -Pserv_rf_top.PRE_REGISTER=1 \
  -Pserv_rf_top.DEBUG=0 \
  -Pserv_rf_top.RF_WIDTH=2 \
  -Pserv_rf_top.RESET_PC=0 \
  '-Pserv_rf_top.RESET_STRATEGY="MINI"' \
  -o build/serv_compile.vvp \
  third_party/serv/rtl/*.v

echo "SERV RTL compile/elaboration passed."
