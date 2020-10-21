EESchema Schematic File Version 4
LIBS:cpuboard-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 5 5
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74xx:74LS377 UIR1
U 1 1 6023114E
P 2050 6450
F 0 "UIR1" V 2096 5609 50  0000 R CNN
F 1 "74HC377" V 2005 5609 50  0000 R CNN
F 2 "" H 2050 6450 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 2050 6450 50  0001 C CNN
	1    2050 6450
	0    -1   -1   0   
$EndComp
$Comp
L 74xx:74HC74 USTATE1
U 1 1 6024D445
P 5050 6350
F 0 "USTATE1" V 5096 6009 50  0000 R CNN
F 1 "74HC74" V 5005 6009 50  0000 R CNN
F 2 "" H 5050 6350 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 5050 6350 50  0001 C CNN
	1    5050 6350
	0    -1   -1   0   
$EndComp
$Comp
L 74xx:74HC74 USTATE1
U 2 1 6024D49F
P 3900 6350
F 0 "USTATE1" V 3946 6009 50  0000 R CNN
F 1 "74HC74" V 3855 6009 50  0000 R CNN
F 2 "" H 3900 6350 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 3900 6350 50  0001 C CNN
	2    3900 6350
	0    -1   -1   0   
$EndComp
$Comp
L 74xx:74HC74 USTATE1
U 3 1 6024D4E4
P 6100 6450
F 0 "USTATE1" H 6330 6496 50  0000 L CNN
F 1 "74HC74" H 6330 6405 50  0000 L CNN
F 2 "" H 6100 6450 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 6100 6450 50  0001 C CNN
	3    6100 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	1550 7550 1550 6950
Wire Wire Line
	1650 7550 1650 6950
Wire Wire Line
	1750 7550 1750 6950
Wire Wire Line
	1850 7550 1850 6950
Wire Wire Line
	1950 7550 1950 6950
Wire Wire Line
	2050 7550 2050 6950
Wire Wire Line
	2150 7550 2150 6950
Wire Wire Line
	2250 7550 2250 6950
$Comp
L power:GND #PWR0185
U 1 1 6024D888
P 2600 6950
F 0 "#PWR0185" H 2600 6700 50  0001 C CNN
F 1 "GND" V 2605 6822 50  0000 R CNN
F 2 "" H 2600 6950 50  0001 C CNN
F 3 "" H 2600 6950 50  0001 C CNN
	1    2600 6950
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0186
U 1 1 6024D93F
P 2850 6500
F 0 "#PWR0186" H 2850 6250 50  0001 C CNN
F 1 "GND" H 2855 6327 50  0000 C CNN
F 2 "" H 2850 6500 50  0001 C CNN
F 3 "" H 2850 6500 50  0001 C CNN
	1    2850 6500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0187
U 1 1 6024D970
P 1250 6400
F 0 "#PWR0187" H 1250 6250 50  0001 C CNN
F 1 "+5V" H 1265 6573 50  0000 C CNN
F 2 "" H 1250 6400 50  0001 C CNN
F 3 "" H 1250 6400 50  0001 C CNN
	1    1250 6400
	1    0    0    -1  
$EndComp
Wire Wire Line
	1250 6400 1250 6450
Wire Wire Line
	2850 6450 2850 6500
$Comp
L power:+5V #PWR0188
U 1 1 6024DDC2
P 6100 6000
F 0 "#PWR0188" H 6100 5850 50  0001 C CNN
F 1 "+5V" H 6115 6173 50  0000 C CNN
F 2 "" H 6100 6000 50  0001 C CNN
F 3 "" H 6100 6000 50  0001 C CNN
	1    6100 6000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0189
U 1 1 6024DDF3
P 6100 6900
F 0 "#PWR0189" H 6100 6650 50  0001 C CNN
F 1 "GND" H 6105 6727 50  0000 C CNN
F 2 "" H 6100 6900 50  0001 C CNN
F 3 "" H 6100 6900 50  0001 C CNN
	1    6100 6900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 6050 6100 6000
Wire Wire Line
	6100 6850 6100 6900
$Comp
L power:+5V #PWR0190
U 1 1 6024E18C
P 3600 6300
F 0 "#PWR0190" H 3600 6150 50  0001 C CNN
F 1 "+5V" H 3615 6473 50  0000 C CNN
F 2 "" H 3600 6300 50  0001 C CNN
F 3 "" H 3600 6300 50  0001 C CNN
	1    3600 6300
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0191
U 1 1 6024E1B6
P 4200 6300
F 0 "#PWR0191" H 4200 6150 50  0001 C CNN
F 1 "+5V" H 4215 6473 50  0000 C CNN
F 2 "" H 4200 6300 50  0001 C CNN
F 3 "" H 4200 6300 50  0001 C CNN
	1    4200 6300
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0192
U 1 1 6024E1E0
P 4750 6300
F 0 "#PWR0192" H 4750 6150 50  0001 C CNN
F 1 "+5V" H 4765 6473 50  0000 C CNN
F 2 "" H 4750 6300 50  0001 C CNN
F 3 "" H 4750 6300 50  0001 C CNN
	1    4750 6300
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0193
U 1 1 6024E20A
P 5350 6300
F 0 "#PWR0193" H 5350 6150 50  0001 C CNN
F 1 "+5V" H 5365 6473 50  0000 C CNN
F 2 "" H 5350 6300 50  0001 C CNN
F 3 "" H 5350 6300 50  0001 C CNN
	1    5350 6300
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 6350 3600 6300
Wire Wire Line
	4200 6350 4200 6300
Wire Wire Line
	4750 6350 4750 6300
Wire Wire Line
	5350 6350 5350 6300
NoConn ~ 5150 6050
Connection ~ 2450 7100
Wire Wire Line
	2450 7100 2450 6950
Connection ~ 3900 7100
Wire Wire Line
	3900 7100 3900 6650
Wire Wire Line
	3900 7100 5050 7100
Wire Wire Line
	5050 7100 5050 6650
Wire Wire Line
	2450 7100 2450 7550
Wire Wire Line
	2450 7100 3900 7100
Wire Wire Line
	3800 7500 3800 6650
Text Label 3800 5950 1    50   ~ 0
SRESET#
Text Label 4950 5950 1    50   ~ 0
PHASE0
Text Label 4950 7000 1    50   ~ 0
P0NEXT
Wire Wire Line
	4950 7000 4950 6650
Text Label 2250 5950 1    50   ~ 0
OP3
Text Label 2150 5950 1    50   ~ 0
OP2
Text Label 2050 5950 1    50   ~ 0
OP1
Text Label 1950 5950 1    50   ~ 0
OP0
Wire Wire Line
	1550 5950 1550 5850
Wire Wire Line
	1650 5950 1650 5850
Wire Wire Line
	1750 5950 1750 5850
Wire Wire Line
	1850 5950 1850 5850
$Comp
L 74xx:74LS138 UDEC1
U 1 1 60258CFE
P 2250 4650
F 0 "UDEC1" V 2500 4100 50  0000 R CNN
F 1 "74HC138" V 2400 4100 50  0000 R CNN
F 2 "" H 2250 4650 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS138" H 2250 4650 50  0001 C CNN
	1    2250 4650
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2050 5150 2050 5600
Wire Wire Line
	2150 5150 2150 5700
Wire Wire Line
	3800 5400 2450 5400
Wire Wire Line
	2450 5400 2450 5150
Wire Wire Line
	3800 5400 3800 6050
Wire Wire Line
	4950 5200 4300 5200
Wire Wire Line
	4950 5200 4950 6050
Text Label 1950 4100 1    50   ~ 0
ST#
Wire Wire Line
	1950 600  1950 1400
Text Label 2050 4100 1    50   ~ 0
LD#
Text Label 2150 4100 1    50   ~ 0
SET#
Text Label 2250 4100 1    50   ~ 0
DP#
Wire Wire Line
	2250 600  2250 1200
Text Label 2350 4100 1    50   ~ 0
JMP#
Text Label 3550 4200 1    50   ~ 0
BRANCH#
$Comp
L 74xx:74LS32 U2
U 1 1 60262DE4
P 3550 4500
F 0 "U2" V 3650 4350 50  0000 R CNN
F 1 "74HC32" V 3750 4450 50  0000 R CNN
F 2 "" H 3550 4500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 3550 4500 50  0001 C CNN
	1    3550 4500
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0194
U 1 1 60267005
P 2950 4700
F 0 "#PWR0194" H 2950 4450 50  0001 C CNN
F 1 "GND" H 2955 4527 50  0000 C CNN
F 2 "" H 2950 4700 50  0001 C CNN
F 3 "" H 2950 4700 50  0001 C CNN
	1    2950 4700
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0195
U 1 1 6026703A
P 1650 4600
F 0 "#PWR0195" H 1650 4450 50  0001 C CNN
F 1 "+5V" H 1665 4773 50  0000 C CNN
F 2 "" H 1650 4600 50  0001 C CNN
F 3 "" H 1650 4600 50  0001 C CNN
	1    1650 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2950 4700 2950 4650
Wire Wire Line
	1650 4600 1650 4650
$Comp
L 74xx:74LS00 U4
U 1 1 602693E7
P 1050 4900
F 0 "U4" V 1050 4700 50  0000 R CNN
F 1 "74HC00" V 950 4700 50  0000 R CNN
F 2 "" H 1050 4900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 1050 4900 50  0001 C CNN
	1    1050 4900
	0    -1   -1   0   
$EndComp
Text Label 4200 4200 1    50   ~ 0
FETCH#
Wire Wire Line
	4200 4200 4200 3900
Wire Wire Line
	2650 4050 3200 4050
Wire Wire Line
	3200 4050 3200 4900
Wire Wire Line
	3200 4900 3450 4900
Wire Wire Line
	3450 4900 3450 4800
Wire Wire Line
	2650 4050 2650 4150
Wire Wire Line
	4100 4800 4100 5400
Wire Wire Line
	4100 5400 3950 5400
Connection ~ 3800 5400
Wire Wire Line
	4300 4800 4300 5200
Connection ~ 4300 5200
$Comp
L 74xx:74HC00 U4
U 2 1 60280158
P 4200 4500
F 0 "U4" V 4500 4700 50  0000 R CNN
F 1 "74HC00" V 4600 4850 50  0000 R CNN
F 2 "" H 4200 4500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74hc00" H 4200 4500 50  0001 C CNN
	2    4200 4500
	0    -1   -1   0   
$EndComp
Connection ~ 2250 5300
Wire Wire Line
	2250 5300 2250 5800
Text Label 1150 3650 1    50   ~ 0
ALUOP#
Wire Wire Line
	5550 750  6150 750 
Wire Wire Line
	4950 650  2050 650 
Wire Wire Line
	4950 750  2150 750 
Wire Wire Line
	2050 650  1150 650 
Connection ~ 1150 650 
Wire Wire Line
	1150 650  1150 600 
Wire Wire Line
	2050 750  2150 750 
Connection ~ 2050 750 
Wire Wire Line
	1150 650  1150 1050
Wire Wire Line
	2050 600  2050 750 
Wire Wire Line
	2150 600  2150 850 
Wire Wire Line
	4950 850  2150 850 
Connection ~ 2150 850 
$Comp
L 74xx:74LS08 U3
U 1 1 602A0402
P 5250 1500
F 0 "U3" H 5500 1750 50  0000 C CNN
F 1 "74HC08" H 5550 1650 50  0000 C CNN
F 2 "" H 5250 1500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 5250 1500 50  0001 C CNN
	1    5250 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 1200 2250 1200
Connection ~ 2250 1200
$Comp
L 74xx:74LS08 U3
U 2 1 602ACB77
P 5250 2400
F 0 "U3" H 5500 2650 50  0000 C CNN
F 1 "74HC08" H 5550 2550 50  0000 C CNN
F 2 "" H 5250 2400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 5250 2400 50  0001 C CNN
	2    5250 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 1500 5600 1500
Wire Wire Line
	4950 1400 1950 1400
Connection ~ 1950 1400
Wire Wire Line
	4950 1600 2350 1600
Connection ~ 2350 1600
Wire Wire Line
	2350 1600 2350 600 
$Comp
L 74xx:74LS11 U5
U 2 1 602C06A8
P 5250 3350
F 0 "U5" H 5500 3600 50  0000 C CNN
F 1 "74HC11" H 5550 3500 50  0000 C CNN
F 2 "" H 5250 3350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 5250 3350 50  0001 C CNN
	2    5250 3350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U3
U 3 1 6030F158
P 9500 5300
F 0 "U3" H 9750 5550 50  0000 C CNN
F 1 "74HC08" H 9800 5450 50  0000 C CNN
F 2 "" H 9500 5300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 9500 5300 50  0001 C CNN
	3    9500 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS11 U5
U 1 1 6031EE13
P 5250 750
F 0 "U5" H 5500 950 50  0000 C CNN
F 1 "74HC11" H 5550 850 50  0000 C CNN
F 2 "" H 5250 750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 5250 750 50  0001 C CNN
	1    5250 750 
	1    0    0    -1  
$EndComp
Connection ~ 1950 3250
Wire Wire Line
	1950 3250 1950 4150
Connection ~ 2050 3350
Wire Wire Line
	2050 3350 2050 4150
Text Label 6200 3800 0    50   ~ 0
P0NEXT
Wire Wire Line
	5550 3800 6200 3800
Connection ~ 2250 3800
Wire Wire Line
	2250 3800 2250 4150
Wire Wire Line
	4950 3900 4200 3900
Connection ~ 4200 3900
$Comp
L 74xx:74LS32 U2
U 3 1 603435D4
P 7500 2350
F 0 "U2" H 7500 2650 50  0000 C CNN
F 1 "74HC32" H 7500 2550 50  0000 C CNN
F 2 "" H 7500 2350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 7500 2350 50  0001 C CNN
	3    7500 2350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74HC00 U4
U 3 1 60354C6C
P 9500 4600
F 0 "U4" H 9700 4750 50  0000 C CNN
F 1 "74HC00" H 9950 4700 50  0000 C CNN
F 2 "" H 9500 4600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74hc00" H 9500 4600 50  0001 C CNN
	3    9500 4600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74HC00 U4
U 5 1 60354D96
P 9850 3000
F 0 "U4" H 10080 3046 50  0000 L CNN
F 1 "74HC00" H 10080 2955 50  0000 L CNN
F 2 "" H 9850 3000 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74hc00" H 9850 3000 50  0001 C CNN
	5    9850 3000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS11 U5
U 4 1 603557C0
P 10600 3000
F 0 "U5" H 10830 3046 50  0000 L CNN
F 1 "74HC11" H 10830 2955 50  0000 L CNN
F 2 "" H 10600 3000 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 10600 3000 50  0001 C CNN
	4    10600 3000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U3
U 5 1 60355874
P 10600 1400
F 0 "U3" H 10830 1446 50  0000 L CNN
F 1 "74HC08" H 10830 1355 50  0000 L CNN
F 2 "" H 10600 1400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 10600 1400 50  0001 C CNN
	5    10600 1400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U2
U 5 1 60356671
P 9850 1400
F 0 "U2" H 10080 1446 50  0000 L CNN
F 1 "74HC32" H 10080 1355 50  0000 L CNN
F 2 "" H 9850 1400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 9850 1400 50  0001 C CNN
	5    9850 1400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS11 U5
U 3 1 603A498A
P 5250 3800
F 0 "U5" H 5600 4000 50  0000 R CNN
F 1 "74HC11" H 5750 3900 50  0000 R CNN
F 2 "" H 5250 3800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS11" H 5250 3800 50  0001 C CNN
	3    5250 3800
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0196
U 1 1 604481E0
P 9850 2450
F 0 "#PWR0196" H 9850 2300 50  0001 C CNN
F 1 "+5V" H 9865 2623 50  0000 C CNN
F 2 "" H 9850 2450 50  0001 C CNN
F 3 "" H 9850 2450 50  0001 C CNN
	1    9850 2450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0197
U 1 1 6044823E
P 9850 850
F 0 "#PWR0197" H 9850 700 50  0001 C CNN
F 1 "+5V" H 9865 1023 50  0000 C CNN
F 2 "" H 9850 850 50  0001 C CNN
F 3 "" H 9850 850 50  0001 C CNN
	1    9850 850 
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0198
U 1 1 6044829C
P 10600 850
F 0 "#PWR0198" H 10600 700 50  0001 C CNN
F 1 "+5V" H 10615 1023 50  0000 C CNN
F 2 "" H 10600 850 50  0001 C CNN
F 3 "" H 10600 850 50  0001 C CNN
	1    10600 850 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0199
U 1 1 6045FAD0
P 9850 3550
F 0 "#PWR0199" H 9850 3300 50  0001 C CNN
F 1 "GND" H 9855 3377 50  0000 C CNN
F 2 "" H 9850 3550 50  0001 C CNN
F 3 "" H 9850 3550 50  0001 C CNN
	1    9850 3550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0200
U 1 1 6045FB2E
P 9850 1950
F 0 "#PWR0200" H 9850 1700 50  0001 C CNN
F 1 "GND" H 9855 1777 50  0000 C CNN
F 2 "" H 9850 1950 50  0001 C CNN
F 3 "" H 9850 1950 50  0001 C CNN
	1    9850 1950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0201
U 1 1 6045FB8C
P 10600 1950
F 0 "#PWR0201" H 10600 1700 50  0001 C CNN
F 1 "GND" H 10605 1777 50  0000 C CNN
F 2 "" H 10600 1950 50  0001 C CNN
F 3 "" H 10600 1950 50  0001 C CNN
	1    10600 1950
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0202
U 1 1 6045FDC3
P 10600 2450
F 0 "#PWR0202" H 10600 2300 50  0001 C CNN
F 1 "+5V" H 10615 2623 50  0000 C CNN
F 2 "" H 10600 2450 50  0001 C CNN
F 3 "" H 10600 2450 50  0001 C CNN
	1    10600 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0205
U 1 1 60465C71
P 10600 3550
F 0 "#PWR0205" H 10600 3300 50  0001 C CNN
F 1 "GND" H 10605 3377 50  0000 C CNN
F 2 "" H 10600 3550 50  0001 C CNN
F 3 "" H 10600 3550 50  0001 C CNN
	1    10600 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	9850 2500 9850 2450
Wire Wire Line
	9850 3550 9850 3500
Wire Wire Line
	9850 1950 9850 1900
Wire Wire Line
	9850 900  9850 850 
Wire Wire Line
	10600 900  10600 850 
Wire Wire Line
	10600 1950 10600 1900
Wire Wire Line
	10600 3550 10600 3500
Wire Wire Line
	10600 2500 10600 2450
Wire Wire Line
	1250 4700 1700 4700
Wire Wire Line
	1700 4700 1700 5200
Wire Wire Line
	2550 6950 2600 6950
Text HLabel 1850 7550 3    50   Input ~ 0
D0
Text HLabel 1750 7550 3    50   Input ~ 0
D1
Text HLabel 1650 7550 3    50   Input ~ 0
D2
Text HLabel 1550 7550 3    50   Input ~ 0
D3
Text HLabel 1950 7550 3    50   Input ~ 0
D4
Text HLabel 2050 7550 3    50   Input ~ 0
D5
Text HLabel 2150 7550 3    50   Input ~ 0
D6
Text HLabel 2250 7550 3    50   Input ~ 0
D7
Text HLabel 2450 7550 3    50   Input ~ 0
CLK
Text HLabel 3800 7500 3    50   Input ~ 0
RES#
Wire Wire Line
	1950 1400 1950 1750
Text HLabel 7900 1850 2    50   Input ~ 0
WR#
Wire Wire Line
	7900 1850 7800 1850
Wire Wire Line
	1950 1750 7200 1750
Connection ~ 1950 1750
Text HLabel 7900 2350 2    50   Input ~ 0
RD#
Wire Wire Line
	7900 2350 7800 2350
Wire Wire Line
	7200 2250 6200 2250
Text HLabel 7050 1950 0    50   Input ~ 0
CLK
Text HLabel 7050 2450 0    50   Input ~ 0
CLK
Wire Wire Line
	7050 1950 7200 1950
Wire Wire Line
	7050 2450 7200 2450
Text HLabel 6150 5400 2    50   Input ~ 0
PCRES#
Wire Wire Line
	4100 5400 6150 5400
Connection ~ 4100 5400
Text HLabel 6150 2400 2    50   Input ~ 0
SELPC
Text HLabel 6150 3350 2    50   Input ~ 0
COUNT
Text HLabel 6150 2850 2    50   Input ~ 0
LOADLOW#
Text HLabel 6150 1500 2    50   Input ~ 0
OEA#
Text HLabel 6150 1200 2    50   Input ~ 0
WRDP#
Text HLabel 6150 1050 2    50   Input ~ 0
SELALU#
Text HLabel 6150 750  2    50   Input ~ 0
WRC#
Wire Wire Line
	1150 1050 6150 1050
Connection ~ 1150 1050
Wire Wire Line
	1150 3700 4950 3700
Wire Wire Line
	2250 3800 4950 3800
Text HLabel 3500 7400 3    50   Input ~ 0
ISTRUE
Wire Wire Line
	3500 7400 3500 5000
Wire Wire Line
	3500 5000 3650 5000
Wire Wire Line
	3650 4800 3650 5000
Text HLabel 1850 5850 1    50   Input ~ 0
REGA0
Text HLabel 1750 5850 1    50   Input ~ 0
REGA1
Text HLabel 1650 5850 1    50   Input ~ 0
REGB0
Text HLabel 1550 5850 1    50   Input ~ 0
REGB1
Text HLabel 2500 5600 2    50   Input ~ 0
OP1
Text HLabel 2500 5700 2    50   Input ~ 0
OP2
Text HLabel 2500 5800 2    50   Input ~ 0
OP3
Wire Wire Line
	2500 5600 2050 5600
Wire Wire Line
	2500 5700 2150 5700
Wire Wire Line
	2500 5800 2250 5800
Connection ~ 2250 5800
Wire Wire Line
	2250 5800 2250 5950
Connection ~ 2050 5600
Connection ~ 2150 5700
Wire Wire Line
	2150 5700 2150 5950
Wire Wire Line
	2050 5600 2050 5950
NoConn ~ 2450 4150
NoConn ~ 2550 4150
Wire Wire Line
	1950 5150 1950 5300
Wire Wire Line
	1950 3250 4950 3250
Wire Wire Line
	2050 3350 4950 3350
$Comp
L 74xx:74LS32 U2
U 2 1 5F9AE1AE
P 1150 4100
AR Path="/6088908D/5F9AE1AE" Ref="U2"  Part="2" 
AR Path="/60888F9A/5F9AE1AE" Ref="U?"  Part="2" 
F 0 "U2" H 1150 4400 50  0000 C CNN
F 1 "74HC32" H 1150 4300 50  0000 C CNN
F 2 "" H 1150 4100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 1150 4100 50  0001 C CNN
	2    1150 4100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1700 5200 2550 5200
Wire Wire Line
	2650 5300 2650 5150
Wire Wire Line
	2250 5300 2650 5300
Wire Wire Line
	2550 5200 2550 5150
Connection ~ 2550 5200
Wire Wire Line
	2550 5200 4300 5200
Text HLabel 6150 3100 2    50   Input ~ 0
LOADHIGH#
$Comp
L 74xx:74LS08 U3
U 4 1 5FA7BFF7
P 5250 2850
AR Path="/6088908D/5FA7BFF7" Ref="U3"  Part="4" 
AR Path="/60888F9A/5FA7BFF7" Ref="U?"  Part="4" 
F 0 "U3" H 5250 3050 50  0000 C CNN
F 1 "74HC08" H 5500 3000 50  0000 C CNN
F 2 "" H 5250 2850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 5250 2850 50  0001 C CNN
	4    5250 2850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U2
U 4 1 5FA7BFFE
P 7500 1850
AR Path="/6088908D/5FA7BFFE" Ref="U2"  Part="4" 
AR Path="/60888F9A/5FA7BFFE" Ref="U?"  Part="4" 
F 0 "U2" V 7700 2050 50  0000 C CNN
F 1 "74HC32" V 7800 2050 50  0000 C CNN
F 2 "" H 7500 1850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 7500 1850 50  0001 C CNN
	4    7500 1850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74HC00 U4
U 4 1 5FAA4DC6
P 5250 2000
AR Path="/6088908D/5FAA4DC6" Ref="U4"  Part="4" 
AR Path="/60888F9A/5FAA4DC6" Ref="U?"  Part="4" 
F 0 "U4" H 5350 2200 50  0000 R CNN
F 1 "74HC00" H 5700 2150 50  0000 R CNN
F 2 "" H 5250 2000 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74hc00" H 5250 2000 50  0001 C CNN
	4    5250 2000
	1    0    0    -1  
$EndComp
NoConn ~ 4000 6050
Connection ~ 2450 5400
Wire Wire Line
	1950 5300 1950 5950
Wire Wire Line
	1250 4400 1250 4700
Wire Wire Line
	1050 4600 1050 4400
Wire Wire Line
	950  5400 2450 5400
Wire Wire Line
	1150 5200 1150 5300
Wire Wire Line
	1150 5300 2250 5300
Wire Wire Line
	950  5200 950  5400
Wire Wire Line
	1150 3800 1150 3700
Connection ~ 1150 3700
Wire Wire Line
	1150 1050 1150 3700
Wire Wire Line
	2050 750  2050 2500
Wire Wire Line
	2150 850  2150 4150
Wire Wire Line
	2250 1200 2250 3800
Wire Wire Line
	4200 600  4200 3900
Connection ~ 3950 5400
Wire Wire Line
	3950 5400 3800 5400
Text Label 3950 4200 1    50   ~ 0
SRESET#
Wire Wire Line
	3950 600  3950 2100
Wire Wire Line
	4950 2100 3950 2100
Connection ~ 3950 2100
Wire Wire Line
	3950 2100 3950 5400
Wire Wire Line
	6150 2850 5550 2850
Wire Wire Line
	2350 1600 2350 2950
Wire Wire Line
	3550 600  3550 2750
Wire Wire Line
	5550 2000 6200 2000
Wire Wire Line
	6200 2000 6200 2250
Wire Wire Line
	6150 3100 2350 3100
Connection ~ 2350 3100
Wire Wire Line
	5550 3350 6150 3350
Wire Wire Line
	5550 2400 6150 2400
Wire Wire Line
	4950 2950 2350 2950
Connection ~ 2350 2950
Wire Wire Line
	2350 2950 2350 3100
Wire Wire Line
	4950 2750 3550 2750
Connection ~ 3550 2750
Wire Wire Line
	3550 2750 3550 3450
Wire Wire Line
	4950 2500 2050 2500
Connection ~ 2050 2500
Wire Wire Line
	2050 2500 2050 3350
Wire Wire Line
	4950 2300 1950 2300
Connection ~ 1950 2300
Wire Wire Line
	1950 2300 1950 3250
Wire Wire Line
	2350 3100 2350 4150
Wire Wire Line
	4950 3450 3550 3450
Connection ~ 3550 3450
Wire Wire Line
	3550 3450 3550 4200
NoConn ~ 9750 4600
NoConn ~ 9800 5300
$Comp
L power:GND #PWR?
U 1 1 6019375C
P 9150 5500
F 0 "#PWR?" H 9150 5250 50  0001 C CNN
F 1 "GND" H 9155 5327 50  0000 C CNN
F 2 "" H 9150 5500 50  0001 C CNN
F 3 "" H 9150 5500 50  0001 C CNN
	1    9150 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 5500 9150 5400
Wire Wire Line
	9150 5400 9200 5400
Wire Wire Line
	9150 5400 9150 5200
Wire Wire Line
	9150 5200 9200 5200
Connection ~ 9150 5400
Wire Wire Line
	9150 5200 9150 4700
Wire Wire Line
	9150 4700 9200 4700
Connection ~ 9150 5200
Wire Wire Line
	9150 4700 9150 4500
Wire Wire Line
	9150 4500 9200 4500
Connection ~ 9150 4700
Wire Wire Line
	1950 1750 1950 2300
Wire Wire Line
	4950 1900 4850 1900
Wire Wire Line
	4850 1900 4850 1700
Wire Wire Line
	4850 1700 5600 1700
Wire Wire Line
	5600 1700 5600 1500
Connection ~ 5600 1500
Wire Wire Line
	5600 1500 6150 1500
$EndSCHEMATC
