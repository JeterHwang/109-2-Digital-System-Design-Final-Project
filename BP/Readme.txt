RTL command:
    cd src/
    ncverilog Final_tb.v CHIP.v slow_memory.v +define+[noHazard/hasHazard/mergesort/BrPred]+[noBP/lv1cach/lv1hash/lv2glo/lv2loc] +access+r
SYN command:
    cd src/
    ncverilog Final_tb.v slow_memory.v +define+[noHazard/hasHazard/mergesort/BrPred]+[noBP/lv1cach/lv1hash/lv2glo/lv2loc]+SDF +access+r
