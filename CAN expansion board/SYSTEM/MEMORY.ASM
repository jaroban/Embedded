; version 4.x

                        bseg at 0
can0_change1:           dbit    1
can0_change2:           dbit    1
can0_change3:           dbit    1
rd_bit:                 dbit    1
wr_bit:                 dbit    1
pol_writing:            dbit    1
pol_clk_hi:             dbit    1

                        dseg at 30h
rd_brd_reg1:            ds      2
rd_brd_reg2:            ds      2
rd_brd_reg3:            ds      2
rd_brd_reg4:            ds      2
rd_brd_reg5:            ds      2
rd_brd_reg6:            ds      2
wr_brd_reg1:            ds      1
wr_brd_reg2:            ds      1
wr_brd_reg3:            ds      1
wr_brd_reg4:            ds      1
wr_brd_reg5:            ds      1
wr_brd_reg6:            ds      1
wr_brd_reg7:            ds      1
polohovka:              ds      1
pol_index:              ds      1
lcom_data:              ds      1

                        iseg at 80h
mjrt_bffr:              ds      10
pol_table:              ds      5

                        xseg at 0f400h
mjrt_table:             ds      5*6

                        cseg
