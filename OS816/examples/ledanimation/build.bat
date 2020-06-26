WDC816CC -ML -MV -MU -MK -MT -SOP -WL -WP -I..\..\src ledanimation.c
WDCLN -HI -Areset=80FFF8  -C800000  -K,  -D10000, -U, ledanimation.obj ..\..\bin\startup.obj -l..\..\bin\os816

