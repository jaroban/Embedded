; version 4.0

;p4      data    080h
sp      data    081h
dpl     data    082h
dph     data    083h
dpl1    data    084h
dph1    data    085h
dps     data    086h
pcon    data    087h
tcon    data    088h
tmod    data    089h
tl0     data    08ah
tl1     data    08bh
th0     data    08ch
th1     data    08dh
ckcon   data    08eh

p1      data    090h
exif    data    091h
;p4cnt   data    092h
dpx     data    093h
dpx1    data    095h
;c0rms0  data    096h
;c0rms1  data    097h
scon    data    098h
sbuf    data    099h

esp     data    09bh
;ap      data    09ch
acon    data    09dh
;c0tma0  data    09eh
;c0tma1  data    09fh
;p2      data    0a0h
;p5      data    0a1h
p5cnt   data    0a2h
c0c     data    0a3h
c0s     data    0a4h
;c0ir    data    0a5h
c0te    data    0a6h
c0re    data    0a7h
ie      data    0a8h
;wds     data    0a9h
;wdk     data    0aah
c0m1c   data    0abh
c0m2c   data    0ach
c0m3c   data    0adh
c0m4c   data    0aeh
c0m5c   data    0afh
p3      data    0b0h

c0m6c   data    0b3h
c0m7c   data    0b4h
c0m8c   data    0b5h
c0m9c   data    0b6h
c0m10c  data    0b7h
ip      data    0b8h

c0m11c  data    0bbh
c0m12c  data    0bch
c0m13c  data    0bdh
c0m14c  data    0beh
c0m15c  data    0bfh
;p7      data    0c0h

pmr     data    0c4h

;mcon    data    0c6h
ta      data    0c7h
t2con   data    0c8h
t2mod   data    0c9h
rcap2l  data    0cah
rcap2h  data    0cbh
tl2     data    0cch
th2     data    0cdh
cor     data    0ceh

psw     data    0d0h

;c1rms0  data    0d6h
;c1rms1  data    0d7h
wdcon   data    0d8h

;c1tma0  data    0deh
;c1tma1  data    0dfh
acc     data    0e0h

c1c     data    0e3h
;c1s     data    0e4h
;c1ir    data    0e5h
c1te    data    0e6h
;c1re    data    0e7h
;eie     data    0e8h

c1m1c   data    0ebh
c1m2c   data    0ech
c1m3c   data    0edh
c1m4c   data    0eeh
c1m5c   data    0efh
b       data    0f0h

c1m6c   data    0f3h
c1m7c   data    0f4h
c1m8c   data    0f5h
c1m9c   data    0f6h
c1m10c  data    0f7h

c1m11c  data    0fbh
c1m12c  data    0fch
c1m13c  data    0fdh
c1m14c  data    0feh
c1m15c  data    0ffh

;it0     bit     088h
;ie0     bit     089h
;it1     bit     08ah
;ie1     bit     08bh
tr0     bit     08ch
;tf0     bit     08dh
tr1     bit     08eh
;tf1     bit     08fh
ri      bit     098h
ti      bit     099h
;rb8     bit     09ah
;tb8     bit     09bh
;ren     bit     09ch
;sm2     bit     09dh
;sm1     bit     09eh
;sm0     bit     09fh
;ex0     bit     0a8h
et0     bit     0a9h
;ex1     bit     0aah
et1     bit     0abh
es      bit     0ach
ea      bit     0afh
;rxd     bit     0b0h
;txd     bit     0b1h
;int0    bit     0b2h
;int1    bit     0b3h
;t0      bit     0b4h
;t1      bit     0b5h
;wr      bit     0b6h
;rd      bit     0b7h
;px0     bit     0b8h
;pt0     bit     0b9h
;px1     bit     0bah
;pt1     bit     0bbh
;ps      bit     0bch
p       bit     0d0h
;ov      bit     0d2h
;rs0     bit     0d3h
;rs1     bit     0d4h
f0      bit     0d5h
ac      bit     0d6h
;cy      bit     0d7h
;rwt     bit     0d8h
;ewt     bit     0d9h
wtrf    bit     0dah
;wdif    bit     0dbh
;pfi     bit     0dch
;epfi    bit     0ddh
por     bit     0deh
;smod    bit     0dfh

reset   code    000h
exti0   code    003h
timer0  code    00bh
exti1   code    013h
timer1  code    01bh
serp0   code    023h
t2ovflw code    02bh
serp1   code    03bh
extint2 code    043h
extint3 code    04bh
extint4 code    053h
extint5 code    05bh
wdint   code    063h
