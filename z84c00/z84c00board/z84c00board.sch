EESchema Schematic File Version 4
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
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
L parts:Z84c00 U1
U 1 1 5EF915E5
P 4300 3100
F 0 "U1" V 4300 900 50  0000 L CNN
F 1 "Z84c00" V 4300 2050 50  0000 L CNN
F 2 "" H 4300 3100 50  0001 C CNN
F 3 "" H 4300 3100 50  0001 C CNN
	1    4300 3100
	0    1    1    0   
$EndComp
$Comp
L parts:74HC00 U2
U 1 1 5EF91621
P 4600 3100
F 0 "U2" V 4600 2300 50  0000 R CNN
F 1 "74HC00" V 4600 2800 50  0000 R CNN
F 2 "" H 4600 3100 50  0001 C CNN
F 3 "" H 4600 3100 50  0001 C CNN
	1    4600 3100
	0    -1   -1   0   
$EndComp
$Comp
L Connector:Conn_01x34_Male J1
U 1 1 5EF918F1
P 4000 4850
F 0 "J1" V 3928 4777 50  0000 C CNN
F 1 "Conn_01x34_Male" V 3837 4777 50  0000 C CNN
F 2 "" H 4000 4850 50  0001 C CNN
F 3 "~" H 4000 4850 50  0001 C CNN
	1    4000 4850
	0    -1   -1   0   
$EndComp
Text Label 3200 4600 1    50   ~ 0
A0
Text Label 3300 4600 1    50   ~ 0
A1
Text Label 3400 4600 1    50   ~ 0
A2
Text Label 3500 4600 1    50   ~ 0
A3
Text Label 3600 4600 1    50   ~ 0
A4
Text Label 3700 4600 1    50   ~ 0
A5
Text Label 3800 4600 1    50   ~ 0
A6
Text Label 3900 4600 1    50   ~ 0
A7
Text Label 4000 4600 1    50   ~ 0
A8
Text Label 4100 4600 1    50   ~ 0
A9
Text Label 4200 4600 1    50   ~ 0
A10
Text Label 4300 4600 1    50   ~ 0
A11
Text Label 4400 4600 1    50   ~ 0
A12
Text Label 4500 4600 1    50   ~ 0
A13
Text Label 4600 4600 1    50   ~ 0
A14
Wire Wire Line
	4300 4650 4300 4600
Wire Wire Line
	4400 4650 4400 4600
Wire Wire Line
	4500 4650 4500 4600
Wire Wire Line
	4600 4650 4600 4600
Text Label 2400 4600 1    50   ~ 0
D0
Text Label 2500 4600 1    50   ~ 0
D1
Text Label 2600 4600 1    50   ~ 0
D2
Text Label 2700 4600 1    50   ~ 0
D3
Text Label 2800 4600 1    50   ~ 0
D4
Text Label 2900 4600 1    50   ~ 0
D5
Text Label 3000 4600 1    50   ~ 0
D6
Text Label 3100 4600 1    50   ~ 0
D7
Wire Wire Line
	2400 4650 2400 4600
Wire Wire Line
	2500 4650 2500 4600
Wire Wire Line
	2600 4650 2600 4600
Wire Wire Line
	2700 4650 2700 4600
Wire Wire Line
	2800 4650 2800 4600
Wire Wire Line
	2900 4650 2900 4600
Wire Wire Line
	3000 4650 3000 4600
Wire Wire Line
	3100 4650 3100 4600
Text Notes 4700 4600 1    50   ~ 0
A15
Text Notes 4800 4600 1    50   ~ 0
A16
Text Notes 4900 4600 1    50   ~ 0
A17
Text Notes 5000 4600 1    50   ~ 0
A18
Text Label 5100 4600 1    50   ~ 0
ROM
Text Label 5200 4600 1    50   ~ 0
RD#
Text Label 5300 4600 1    50   ~ 0
WR#
Text Label 5400 4600 1    50   ~ 0
RES#
Text Label 5500 4600 1    50   ~ 0
CLK#
Text Label 5600 4600 1    50   ~ 0
5V
Text Label 5700 4600 1    50   ~ 0
GND
Wire Wire Line
	2000 4250 4350 4250
Wire Wire Line
	5300 3900 5300 4650
Wire Wire Line
	2400 3900 5300 3900
Wire Wire Line
	5200 4000 5200 4650
Wire Wire Line
	2300 4000 5200 4000
Text Label 5900 4150 0    50   ~ 0
5V
Text Label 5900 4250 0    50   ~ 0
GND
$Comp
L power:PWR_FLAG #FLG?
U 1 1 5EFA0569
P 2000 4150
F 0 "#FLG?" H 2000 4225 50  0001 C CNN
F 1 "PWR_FLAG" V 2000 4278 50  0000 L CNN
F 2 "" H 2000 4150 50  0001 C CNN
F 3 "~" H 2000 4150 50  0001 C CNN
	1    2000 4150
	0    -1   -1   0   
$EndComp
$Comp
L power:PWR_FLAG #FLG?
U 1 1 5EFA059A
P 2000 4250
F 0 "#FLG?" H 2000 4325 50  0001 C CNN
F 1 "PWR_FLAG" V 2000 4378 50  0000 L CNN
F 2 "" H 2000 4250 50  0001 C CNN
F 3 "~" H 2000 4250 50  0001 C CNN
	1    2000 4250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5600 4150 5600 4650
Connection ~ 5600 4150
Wire Wire Line
	5700 4250 5700 4650
Connection ~ 5700 4250
Wire Wire Line
	5700 4250 5900 4250
Text Label 2900 2150 1    50   ~ 0
D0
Text Label 2800 2150 1    50   ~ 0
D1
Wire Wire Line
	5400 3800 2800 3800
Wire Wire Line
	5400 3800 5400 4650
Wire Wire Line
	2000 4150 2600 4150
NoConn ~ 2900 3550
NoConn ~ 3000 3550
Wire Wire Line
	3100 3550 3100 3600
Wire Wire Line
	3200 2650 3200 2600
Wire Wire Line
	2800 3550 2800 3800
Wire Wire Line
	2400 3550 2400 3900
Wire Wire Line
	2300 3550 2300 4000
Wire Wire Line
	3200 3550 3200 4650
Wire Wire Line
	3300 3550 3300 4650
Wire Wire Line
	3400 3550 3400 4650
Wire Wire Line
	3500 3550 3500 4650
Wire Wire Line
	3600 3550 3600 4650
Wire Wire Line
	3700 3550 3700 4650
Wire Wire Line
	3800 3550 3800 4650
Wire Wire Line
	3900 3550 3900 4650
Wire Wire Line
	4000 3550 4000 4650
Wire Wire Line
	4100 3550 4100 4650
Wire Wire Line
	4200 3550 4200 4650
Text Label 3000 2150 1    50   ~ 0
D7
Text Label 3100 2150 1    50   ~ 0
D2
Text Label 3300 2150 1    50   ~ 0
D6
Text Label 3400 2150 1    50   ~ 0
D5
Text Label 3500 2150 1    50   ~ 0
D3
Text Label 3600 2150 1    50   ~ 0
D4
Text Label 3900 2150 1    50   ~ 0
A14
Text Label 4000 2150 1    50   ~ 0
A13
Text Label 4100 2150 1    50   ~ 0
A12
Text Label 4200 2150 1    50   ~ 0
A11
Wire Wire Line
	3900 2650 3900 2150
Wire Wire Line
	4000 2650 4000 2150
Wire Wire Line
	4100 2650 4100 2150
Wire Wire Line
	4200 2650 4200 2150
Wire Wire Line
	3600 2650 3600 2150
Wire Wire Line
	3500 2650 3500 2150
Wire Wire Line
	3400 2650 3400 2150
Wire Wire Line
	3300 2650 3300 2150
Wire Wire Line
	3100 2650 3100 2150
Wire Wire Line
	3000 2650 3000 2150
Wire Wire Line
	2900 2650 2900 2150
Wire Wire Line
	2800 2650 2800 2150
Wire Wire Line
	3700 2350 3700 2650
Wire Wire Line
	5000 4650 5000 4150
Connection ~ 5000 4150
Wire Wire Line
	5000 4150 5600 4150
Wire Wire Line
	4900 4650 4900 4150
Connection ~ 4900 4150
Wire Wire Line
	4900 4150 5000 4150
Wire Wire Line
	4800 4650 4800 4150
Connection ~ 4800 4150
Wire Wire Line
	4800 4150 4900 4150
Wire Wire Line
	4700 4650 4700 4250
Connection ~ 4700 4250
Wire Wire Line
	3200 2600 2700 2600
Connection ~ 3200 2600
NoConn ~ 2400 2650
Wire Wire Line
	2600 2650 2600 2600
Wire Wire Line
	2700 2650 2700 2600
Connection ~ 2700 2600
Wire Wire Line
	2700 2600 2600 2600
Wire Wire Line
	3800 2650 3800 2500
NoConn ~ 5000 2750
NoConn ~ 5300 2750
Wire Wire Line
	5500 3800 5900 3800
Wire Wire Line
	5900 3800 5900 2350
Wire Wire Line
	3700 2350 5900 2350
Wire Wire Line
	5500 3800 5500 4650
$Comp
L Device:C_Small C1
U 1 1 5F013FAB
P 4350 3100
F 0 "C1" V 4400 2900 50  0000 L CNN
F 1 "100nF" V 4400 3200 50  0000 L CNN
F 2 "" H 4350 3100 50  0001 C CNN
F 3 "~" H 4350 3100 50  0001 C CNN
	1    4350 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4350 3600 4350 3200
Wire Wire Line
	3100 3600 4350 3600
Wire Wire Line
	4350 3000 4350 2600
Wire Wire Line
	3200 2600 4350 2600
Wire Wire Line
	4350 3600 4350 4250
Connection ~ 4350 3600
Connection ~ 4350 4250
Wire Wire Line
	4450 2600 4350 2600
Connection ~ 4350 2600
Wire Wire Line
	4350 4250 4700 4250
Wire Wire Line
	4450 2600 4450 4150
Connection ~ 4450 4150
Wire Wire Line
	4450 4150 4800 4150
Wire Wire Line
	3800 2500 4600 2500
Wire Wire Line
	5100 3500 5100 3450
NoConn ~ 2300 2650
NoConn ~ 2500 2650
NoConn ~ 2500 3550
Wire Wire Line
	2600 3550 2600 4150
Connection ~ 2600 4150
Wire Wire Line
	2600 4150 2700 4150
Wire Wire Line
	2700 3550 2700 4150
Connection ~ 2700 4150
Wire Wire Line
	2700 4150 4450 4150
Wire Wire Line
	5600 4150 5900 4150
Wire Wire Line
	4450 2600 4700 2600
Connection ~ 4450 2600
Wire Wire Line
	4800 2600 4700 2600
Connection ~ 4700 2600
Wire Wire Line
	4900 2600 4800 2600
Connection ~ 4800 2600
Wire Wire Line
	5100 2600 4900 2600
Connection ~ 4900 2600
Wire Wire Line
	5200 2600 5100 2600
Connection ~ 5100 2600
Wire Wire Line
	5200 2600 5200 2750
Wire Wire Line
	5100 2600 5100 2750
Wire Wire Line
	4900 2600 4900 2750
Wire Wire Line
	4800 2600 4800 2750
Wire Wire Line
	4700 2600 4700 2750
Wire Wire Line
	4350 3600 4700 3600
Wire Wire Line
	5300 3450 5300 3600
Wire Wire Line
	5100 3700 5200 3700
Wire Wire Line
	5200 3700 5200 3450
Wire Wire Line
	5100 3700 5100 4650
Wire Wire Line
	4600 2500 4600 3700
Wire Wire Line
	4600 3700 5000 3700
Wire Wire Line
	5000 3450 5000 3500
Wire Wire Line
	5100 3500 5000 3500
Connection ~ 5000 3500
Wire Wire Line
	5000 3500 5000 3700
Wire Wire Line
	4700 3450 4700 3600
Connection ~ 4700 3600
Wire Wire Line
	4700 3600 4800 3600
Wire Wire Line
	4800 3450 4800 3600
Connection ~ 4800 3600
Wire Wire Line
	4800 3600 5300 3600
NoConn ~ 4900 3450
Wire Wire Line
	4700 4250 5700 4250
$EndSCHEMATC
