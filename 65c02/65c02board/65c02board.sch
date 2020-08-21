EESchema Schematic File Version 4
LIBS:65c02board-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "65c02 circuit for ByteMachine"
Date ""
Rev "1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x34_Male J1
U 1 1 5ED92C40
P 5550 4700
F 0 "J1" V 5385 4626 50  0000 C CNN
F 1 "Conn_01x34_Male" V 5476 4626 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x34_P2.54mm_Vertical" H 5550 4700 50  0001 C CNN
F 3 "~" H 5550 4700 50  0001 C CNN
	1    5550 4700
	0    1    -1   0   
$EndComp
Text Label 4550 4450 1    50   ~ 0
D7
Text Label 4450 4450 1    50   ~ 0
D6
Text Label 4350 4450 1    50   ~ 0
D5
Text Label 4250 4450 1    50   ~ 0
D4
Text Label 4150 4450 1    50   ~ 0
D3
Text Label 4050 4450 1    50   ~ 0
D2
Text Label 3950 4450 1    50   ~ 0
D1
Text Label 3850 4450 1    50   ~ 0
D0
Text Label 4650 4450 1    50   ~ 0
A0
Text Label 4750 4450 1    50   ~ 0
A1
Text Label 4850 4450 1    50   ~ 0
A2
Text Label 4950 4450 1    50   ~ 0
A3
Text Label 5050 4450 1    50   ~ 0
A4
Text Label 5150 4450 1    50   ~ 0
A5
Text Label 5250 4450 1    50   ~ 0
A6
Text Label 5350 4450 1    50   ~ 0
A7
Text Label 5450 4450 1    50   ~ 0
A8
Text Label 5550 4450 1    50   ~ 0
A9
Text Label 5650 4450 1    50   ~ 0
A10
Text Label 5750 4450 1    50   ~ 0
A11
Text Label 5850 4450 1    50   ~ 0
A12
Text Label 5950 4450 1    50   ~ 0
A13
Text Label 6050 4450 1    50   ~ 0
A14
Text Label 6550 4450 1    50   ~ 0
ROM
Text Label 6650 4450 1    50   ~ 0
RD#
Text Label 6750 4450 1    50   ~ 0
WR#
Text Label 6850 4450 1    50   ~ 0
RES#
Text Label 6950 4450 1    50   ~ 0
CLK
Text Label 7050 4450 1    50   ~ 0
5V
Text Label 7150 4450 1    50   ~ 0
GND
Wire Wire Line
	3850 4500 3850 4450
Wire Wire Line
	3950 4500 3950 4450
Wire Wire Line
	4050 4500 4050 4450
Wire Wire Line
	4150 4500 4150 4450
Wire Wire Line
	4250 4500 4250 4450
Wire Wire Line
	4350 4500 4350 4450
Wire Wire Line
	4450 4500 4450 4450
Wire Wire Line
	4550 4500 4550 4450
Wire Wire Line
	3500 3800 3650 3800
Wire Wire Line
	3850 2550 3850 2100
Wire Wire Line
	4450 2550 4450 2200
Wire Wire Line
	6550 2550 6550 2500
Wire Wire Line
	6550 3250 6550 3300
Wire Wire Line
	6650 3500 6850 3500
Wire Wire Line
	6950 3250 6950 3400
Wire Wire Line
	5850 4500 5850 4450
Wire Wire Line
	5950 4500 5950 4450
Wire Wire Line
	6050 4500 6050 4450
NoConn ~ 3950 2550
NoConn ~ 3850 3250
NoConn ~ 4050 3250
Connection ~ 4150 3800
Wire Wire Line
	4150 3800 4350 3800
NoConn ~ 4250 3250
Connection ~ 4350 3800
NoConn ~ 4450 3250
Wire Wire Line
	4550 3250 4550 3300
Wire Wire Line
	5750 2550 5750 2500
Text Label 4550 1850 1    50   ~ 0
D0
Text Label 4650 1850 1    50   ~ 0
D1
Text Label 4750 1850 1    50   ~ 0
D2
Text Label 4850 1850 1    50   ~ 0
D3
Text Label 4950 1850 1    50   ~ 0
D4
Text Label 5050 1850 1    50   ~ 0
D5
Text Label 5150 1850 1    50   ~ 0
D6
Text Label 5250 1850 1    50   ~ 0
D7
Text Label 5450 1850 1    50   ~ 0
A14
Text Label 5550 1850 1    50   ~ 0
A13
Text Label 5650 1850 1    50   ~ 0
A12
$Comp
L Device:C_Small C1
U 1 1 5EE8D589
P 5900 2900
F 0 "C1" V 5950 2750 50  0000 L CNN
F 1 "100nF" V 5950 2950 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 5900 2900 50  0001 C CNN
F 3 "~" H 5900 2900 50  0001 C CNN
	1    5900 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 3300 6400 2200
Wire Wire Line
	6400 3300 6550 3300
Connection ~ 6400 2200
Wire Wire Line
	6850 3250 6850 3500
$Comp
L Device:C_Small C2
U 1 1 5EF19D4E
P 7300 2900
F 0 "C2" V 7350 2750 50  0000 L CNN
F 1 "100nF" V 7350 2950 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 7300 2900 50  0001 C CNN
F 3 "~" H 7300 2900 50  0001 C CNN
	1    7300 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 3300 7150 3250
Text Notes 6150 4300 3    50   ~ 0
A15
Text Notes 6250 4300 3    50   ~ 0
A16
Text Notes 6350 4300 3    50   ~ 0
A17
Text Notes 6450 4300 3    50   ~ 0
A18
Wire Wire Line
	4650 1850 4650 2550
Wire Wire Line
	4750 1850 4750 2550
Wire Wire Line
	4850 1850 4850 2550
Wire Wire Line
	4950 1850 4950 2550
Wire Wire Line
	5050 1850 5050 2550
Wire Wire Line
	5150 1850 5150 2550
Wire Wire Line
	5250 1850 5250 2550
Wire Wire Line
	5550 1850 5550 2550
Wire Wire Line
	5650 1850 5650 2550
Wire Wire Line
	6150 3800 6150 4500
Wire Wire Line
	6350 4500 6350 3900
Wire Wire Line
	6750 3600 6750 3250
Connection ~ 7050 3800
Wire Wire Line
	7150 3900 7150 4500
Connection ~ 7150 3900
Wire Wire Line
	3500 3900 6000 3900
Wire Wire Line
	7150 3900 7300 3900
Wire Wire Line
	7050 3800 7050 4500
Wire Wire Line
	4350 3800 5900 3800
Wire Wire Line
	4550 3300 5900 3300
Wire Wire Line
	5750 2500 5900 2500
Connection ~ 7300 3900
Wire Wire Line
	7300 3900 8100 3900
Wire Wire Line
	5900 2800 5900 2500
Connection ~ 5900 2500
Wire Wire Line
	5900 3000 5900 3300
Connection ~ 5900 3800
Wire Wire Line
	5900 2500 6000 2500
Wire Wire Line
	7300 3000 7300 3300
Wire Wire Line
	7300 2800 7300 2500
Connection ~ 7300 2500
Connection ~ 7400 3800
Wire Wire Line
	7400 3800 8100 3800
Wire Wire Line
	7300 2500 7400 2500
Wire Wire Line
	7150 3300 7300 3300
Wire Wire Line
	5450 1850 5450 2550
Wire Wire Line
	4450 2200 6400 2200
Wire Wire Line
	6450 3900 7150 3900
Text Label 8100 3900 2    50   ~ 0
GND
Text Label 8100 3800 2    50   ~ 0
5V
Wire Wire Line
	3650 2500 4050 2500
Connection ~ 3650 3800
Connection ~ 4050 2500
Wire Wire Line
	4050 2500 4050 2550
Wire Wire Line
	4050 2500 4250 2500
Wire Wire Line
	6400 2200 6650 2200
Wire Wire Line
	6750 3600 6650 3600
Wire Wire Line
	6950 3500 6850 3500
Connection ~ 6850 3500
Wire Wire Line
	4550 1850 4550 2550
Wire Wire Line
	4250 2500 4250 2550
Wire Wire Line
	4150 2550 4150 2300
Wire Wire Line
	7300 3800 7300 3900
Wire Wire Line
	4150 3250 4150 3800
Wire Wire Line
	4350 3250 4350 3800
Wire Wire Line
	4650 3250 4650 4500
Wire Wire Line
	4750 3250 4750 4500
Wire Wire Line
	4850 3250 4850 4500
Wire Wire Line
	4950 3250 4950 4500
Wire Wire Line
	5050 3250 5050 4500
Wire Wire Line
	5150 3250 5150 4500
Wire Wire Line
	5250 3250 5250 4500
Wire Wire Line
	5350 3250 5350 4500
Wire Wire Line
	5450 3250 5450 4500
Wire Wire Line
	5550 3250 5550 4500
Wire Wire Line
	5650 3250 5650 4500
Wire Wire Line
	5750 3250 5750 4500
Wire Wire Line
	5900 3300 5900 3800
Connection ~ 5900 3300
Wire Wire Line
	3650 2500 3650 3800
Wire Wire Line
	6000 2500 6000 3800
Wire Wire Line
	6650 3600 6650 4500
Wire Wire Line
	6750 3700 6750 4500
Wire Wire Line
	7050 3250 7050 3700
Wire Wire Line
	6750 3700 7050 3700
Wire Wire Line
	7400 2500 7400 3800
Wire Wire Line
	6950 3500 6950 4500
Connection ~ 7300 3300
Wire Wire Line
	7050 3800 7400 3800
Wire Wire Line
	7300 3300 7300 3800
Wire Wire Line
	6850 4000 7600 4000
Wire Wire Line
	7600 4000 7600 2100
Wire Wire Line
	3850 2100 7600 2100
Wire Wire Line
	6850 4000 6850 4500
Wire Wire Line
	6000 3800 6000 3900
Connection ~ 6000 3900
Wire Wire Line
	6000 3900 6250 3900
Connection ~ 6150 3800
Wire Wire Line
	5900 3800 6150 3800
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5F014942
P 3500 3800
F 0 "#FLG0101" H 3500 3875 50  0001 C CNN
F 1 "PWR_FLAG" V 3500 3928 50  0000 L CNN
F 2 "" H 3500 3800 50  0001 C CNN
F 3 "~" H 3500 3800 50  0001 C CNN
	1    3500 3800
	0    -1   -1   0   
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5F014982
P 3500 3900
F 0 "#FLG0102" H 3500 3975 50  0001 C CNN
F 1 "PWR_FLAG" V 3500 4028 50  0000 L CNN
F 2 "" H 3500 3900 50  0001 C CNN
F 3 "~" H 3500 3900 50  0001 C CNN
	1    3500 3900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6350 3900 6350 3800
Connection ~ 6350 3800
Wire Wire Line
	6350 3800 6450 3800
Connection ~ 6450 3800
Wire Wire Line
	6450 3800 7050 3800
Wire Wire Line
	6250 3900 6450 3900
Wire Wire Line
	6450 3800 6450 4500
Wire Wire Line
	3650 3800 3950 3800
$Comp
L customparts:w65c02 U1
U 1 1 5ED92BAA
P 3800 2900
F 0 "U1" H 3850 2950 50  0000 R CNN
F 1 "W65C02" V 3800 2000 50  0000 R CNN
F 2 "Package_DIP:DIP-40_W15.24mm_Socket" H 3800 2900 50  0001 C CNN
F 3 "" H 3800 2900 50  0001 C CNN
	1    3800 2900
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R1
U 1 1 5EECB72C
P 3950 3500
F 0 "R1" H 4009 3546 50  0000 L CNN
F 1 "1k" H 4009 3455 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 3950 3500 50  0001 C CNN
F 3 "~" H 3950 3500 50  0001 C CNN
	1    3950 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 3250 3950 3400
Wire Wire Line
	3950 3600 3950 3800
Connection ~ 3950 3800
Wire Wire Line
	3950 3800 4150 3800
Wire Wire Line
	4150 2300 6150 2300
Wire Wire Line
	6550 4500 6550 4450
Text Label 5350 1850 1    50   ~ 0
ROM
Wire Wire Line
	5350 1850 5350 2550
Wire Wire Line
	6150 2300 6150 3500
Wire Wire Line
	6150 3500 6650 3500
Connection ~ 6650 3500
Wire Wire Line
	6650 3250 6650 3500
Wire Wire Line
	6950 3400 6300 3400
Wire Wire Line
	6300 3400 6300 2300
Wire Wire Line
	6300 2300 6850 2300
$Comp
L customparts:74HC00 U2
U 1 1 5EDB7C09
P 6450 2900
F 0 "U2" H 6500 2900 50  0000 R CNN
F 1 "74HC00" V 6450 2650 50  0000 R CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6450 2900 50  0001 C CNN
F 3 "" H 6450 2900 50  0001 C CNN
	1    6450 2900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6550 2500 6950 2500
Wire Wire Line
	6650 2550 6650 2200
Connection ~ 6650 2200
Wire Wire Line
	6650 2200 6750 2200
Wire Wire Line
	6750 2200 6750 2550
Wire Wire Line
	6850 2550 6850 2300
Wire Wire Line
	6950 2550 6950 2500
Connection ~ 6950 2500
Wire Wire Line
	6950 2500 7050 2500
Wire Wire Line
	7050 2550 7050 2500
Connection ~ 7050 2500
Wire Wire Line
	7050 2500 7300 2500
NoConn ~ 7150 2550
Connection ~ 6250 3900
Wire Wire Line
	6250 3900 6250 4500
Wire Wire Line
	6150 3800 6350 3800
$EndSCHEMATC
