#!/bin/bash

iverilog -g2005-sv -Wall -gstrict-ca-eval -gstrict-expr-width -gio-range-error testbench.v ../verilog-md5/md5_design.v
vvp a.out -lxt2
rm a.out
