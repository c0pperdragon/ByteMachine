WDC816CC -ML -MV -MU -MK -MT ledanimation.c
WDC816AS startup.asm
WDC816AS portio.asm
WDCLN -HI -Areset=80FFF8,FFF8 -C800000,00000 -D010000,  ledanimation.obj startup.obj portio.obj
