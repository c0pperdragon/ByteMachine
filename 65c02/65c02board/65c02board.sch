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
L Connector:Conn_01x34_Male J1
U 1 1 5ED92C40
P 5550 4600
F 0 "J1" V 5385 4526 50  0000 C CNN
F 1 "Conn_01x34_Male" V 5476 4526 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x34_P2.54mm_Vertical" H 5550 4600 50  0001 C CNN
F 3 "~" H 5550 4600 50  0001 C CNN
	1    5550 4600
	0    1    -1   0   
$EndComp
Text Label 4550 4350 1    50   ~ 0
D7
Text Label 4450 4350 1    50   ~ 0
D6
Text Label 4350 4350 1    50   ~ 0
D5
Text Label 4250 4350 1    50   ~ 0
D4
Text Label 4150 4350 1    50   ~ 0
D3
Text Label 4050 4350 1    50   ~ 0
D2
Text Label 3950 4350 1    50   ~ 0
D1
Text Label 3850 4350 1    50   ~ 0
D0
Text Label 4650 4350 1    50   ~ 0
A0
Text Label 4750 4350 1    50   ~ 0
A1
Text Label 4850 4350 1    50   ~ 0
A2
Text Label 4950 4350 1    50   ~ 0
A3
Text Label 5050 4350 1    50   ~ 0
A4
Text Label 5150 4350 1    50   ~ 0
A5
Text Label 5250 4350 1    50   ~ 0
A6
Text Label 5350 4350 1    50   ~ 0
A7
Text Label 5450 4350 1    50   ~ 0
A8
Text Label 5550 4350 1    50   ~ 0
A9
Text Label 5650 4350 1    50   ~ 0
A10
Text Label 5750 4350 1    50   ~ 0
A11
Text Label 5850 4350 1    50   ~ 0
A12
Text Label 5950 4350 1    50   ~ 0
A13
Text Label 6050 4350 1    50   ~ 0
A14
Text Label 6550 4350 1    50   ~ 0
RAM
Text Label 6650 4350 1    50   ~ 0
RD
Text Label 6750 4350 1    50   ~ 0
WR
Text Label 6850 4350 1    50   ~ 0
RES
Text Label 6950 4350 1    50   ~ 0
CLK
Text Label 7050 4350 1    50   ~ 0
5V
Text Label 7150 4350 1    50   ~ 0
GND
Wire Wire Line
	3850 4400 3850 4350
Wire Wire Line
	3950 4400 3950 4350
Wire Wire Line
	4050 4400 4050 4350
Wire Wire Line
	4150 4400 4150 4350
Wire Wire Line
	4250 4400 4250 4350
Wire Wire Line
	4350 4400 4350 4350
Wire Wire Line
	4450 4400 4450 4350
Wire Wire Line
	4550 4400 4550 4350
Wire Wire Line
	3550 3700 3950 3700
Text Label 8100 3700 2    50   ~ 0
5V
Text Label 8100 3800 2    50   ~ 0
GND
Wire Wire Line
	4650 3250 4650 4400
Wire Wire Line
	4750 3250 4750 4400
Wire Wire Line
	4850 3250 4850 4400
Wire Wire Line
	4950 3250 4950 4400
Wire Wire Line
	5050 3250 5050 4400
Wire Wire Line
	5150 3250 5150 4400
Wire Wire Line
	5250 3250 5250 4400
Wire Wire Line
	5350 3250 5350 4400
Wire Wire Line
	5450 3250 5450 4400
Wire Wire Line
	5550 3250 5550 4400
Wire Wire Line
	5650 3250 5650 4400
Wire Wire Line
	5750 3250 5750 4400
$Comp
L customparts:74HC00 U2
U 1 1 5EDB7C09
P 6400 2900
F 0 "U2" H 6450 2900 50  0000 R CNN
F 1 "74HC00" V 6400 2650 50  0000 R CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6400 2900 50  0001 C CNN
F 3 "" H 6400 2900 50  0001 C CNN
	1    6400 2900
	0    -1   -1   0   
$EndComp
Text Label 8100 1900 2    50   ~ 0
5V
Text Label 8100 2000 2    50   ~ 0
GND
Wire Wire Line
	3550 1900 4050 1900
Wire Wire Line
	3850 2550 3850 2100
Wire Wire Line
	4150 2550 4150 2400
Wire Wire Line
	6600 3250 6600 3500
Connection ~ 6600 3500
Wire Wire Line
	6600 3500 6150 3500
Wire Wire Line
	4450 2550 4450 2300
Wire Wire Line
	6600 2300 6600 2550
Wire Wire Line
	6600 2300 6700 2300
Wire Wire Line
	6700 2300 6700 2550
Connection ~ 6600 2300
Wire Wire Line
	7600 2300 7600 3400
Wire Wire Line
	6500 2550 6500 2500
Wire Wire Line
	6800 2550 6800 2300
Wire Wire Line
	6800 2300 7600 2300
Wire Wire Line
	6500 3250 6500 3400
Wire Wire Line
	6600 3500 6800 3500
Wire Wire Line
	6900 3400 7600 3400
Wire Wire Line
	6900 3250 6900 3400
Wire Wire Line
	5850 4400 5850 4350
Wire Wire Line
	5950 4400 5950 4350
Wire Wire Line
	6050 4400 6050 4350
Connection ~ 7900 2000
Wire Wire Line
	7900 2000 8100 2000
Connection ~ 7800 1900
Wire Wire Line
	7800 1900 8100 1900
Wire Wire Line
	5350 2550 5350 2200
NoConn ~ 3950 2550
Connection ~ 4050 1900
Wire Wire Line
	4050 1900 4250 1900
$Comp
L Device:R_Small R1
U 1 1 5EE39056
P 3950 3450
F 0 "R1" H 4009 3496 50  0000 L CNN
F 1 "1k" H 4009 3405 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 3950 3450 50  0001 C CNN
F 3 "~" H 3950 3450 50  0001 C CNN
	1    3950 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 3250 3950 3350
Wire Wire Line
	3950 3550 3950 3700
Connection ~ 3950 3700
Wire Wire Line
	3950 3700 4150 3700
NoConn ~ 3850 3250
NoConn ~ 4050 3250
Wire Wire Line
	4150 3250 4150 3700
Connection ~ 4150 3700
Wire Wire Line
	4150 3700 4350 3700
NoConn ~ 4250 3250
Wire Wire Line
	4350 3250 4350 3700
Connection ~ 4350 3700
NoConn ~ 4450 3250
Wire Wire Line
	4550 3250 4550 3300
Wire Wire Line
	5750 2550 5750 2500
Text Label 4550 1700 1    50   ~ 0
D0
Text Label 4650 1700 1    50   ~ 0
D1
Text Label 4750 1700 1    50   ~ 0
D2
Text Label 4850 1700 1    50   ~ 0
D3
Text Label 4950 1700 1    50   ~ 0
D4
Text Label 5050 1700 1    50   ~ 0
D5
Text Label 5150 1700 1    50   ~ 0
D6
Text Label 5250 1700 1    50   ~ 0
D7
Text Label 5450 1700 1    50   ~ 0
A14
Text Label 5550 1700 1    50   ~ 0
A13
Text Label 5650 1700 1    50   ~ 0
A12
Wire Wire Line
	7100 2550 7100 2400
$Comp
L Device:C_Small C1
U 1 1 5EE8D589
P 5900 2900
F 0 "C1" H 6000 2900 50  0000 L CNN
F 1 "100nF" H 5900 2800 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 5900 2900 50  0001 C CNN
F 3 "~" H 5900 2900 50  0001 C CNN
	1    5900 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 3400 6350 2300
Wire Wire Line
	6350 3400 6500 3400
Connection ~ 6350 2300
Wire Wire Line
	6350 2300 6600 2300
Wire Wire Line
	6150 2400 6150 3500
Wire Wire Line
	5750 2500 5900 2500
Wire Wire Line
	5900 2500 5900 2800
Wire Wire Line
	4550 3300 5900 3300
Wire Wire Line
	5900 3300 5900 3000
Connection ~ 6800 3500
Wire Wire Line
	6800 3250 6800 3500
Wire Wire Line
	6800 3500 6950 3500
Wire Wire Line
	6900 2200 7000 2200
Connection ~ 6900 2200
Wire Wire Line
	6900 2200 6900 2550
Wire Wire Line
	7000 2200 7000 2550
$Comp
L Device:C_Small C2
U 1 1 5EF19D4E
P 7300 2900
F 0 "C2" H 7400 2900 50  0000 L CNN
F 1 "100nF" H 7350 2800 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 7300 2900 50  0001 C CNN
F 3 "~" H 7300 2900 50  0001 C CNN
	1    7300 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 2800 7300 2500
Wire Wire Line
	7300 3000 7300 3300
Wire Wire Line
	7300 3300 7100 3300
Wire Wire Line
	7100 3300 7100 3250
Wire Wire Line
	7300 3300 7300 3800
Connection ~ 7300 3300
Connection ~ 7300 3800
Wire Wire Line
	6500 2500 7300 2500
Text Label 3550 2000 0    50   ~ 0
GND
Text Label 3550 1900 0    50   ~ 0
5V
Text Label 3550 3700 0    50   ~ 0
5V
Text Label 3550 3800 0    50   ~ 0
GND
Text Notes 6150 4200 3    50   ~ 0
A15
Text Notes 6250 4200 3    50   ~ 0
A16
Text Notes 6350 4200 3    50   ~ 0
A17
Text Notes 6450 4200 3    50   ~ 0
A18
Wire Wire Line
	5900 3300 5900 3700
Connection ~ 5900 3300
Wire Wire Line
	4350 3700 5900 3700
Wire Wire Line
	3550 2000 5900 2000
Connection ~ 7300 1900
Wire Wire Line
	7300 1900 7800 1900
Wire Wire Line
	7700 2100 7700 3900
Wire Wire Line
	6850 3900 6850 4400
Wire Wire Line
	7100 2400 6250 2400
Wire Wire Line
	6250 2400 6250 3600
Wire Wire Line
	6250 3600 6550 3600
Wire Wire Line
	5900 2400 6150 2400
Wire Wire Line
	7900 3700 8100 3700
Wire Wire Line
	7300 3800 7900 3800
Wire Wire Line
	4050 1900 4050 2550
Wire Wire Line
	4250 1900 4250 2550
Wire Wire Line
	4250 1900 7300 1900
Connection ~ 4250 1900
Wire Wire Line
	3850 2100 7700 2100
Wire Wire Line
	4150 2400 5900 2400
Wire Wire Line
	4450 2300 6350 2300
Wire Wire Line
	5350 2200 6900 2200
Wire Wire Line
	5900 2000 7900 2000
Connection ~ 5900 2000
Connection ~ 5900 2500
Wire Wire Line
	5900 2000 5900 2500
Wire Wire Line
	4550 1700 4550 2550
Wire Wire Line
	4650 1700 4650 2550
Wire Wire Line
	4750 1700 4750 2550
Wire Wire Line
	4850 1700 4850 2550
Wire Wire Line
	4950 1700 4950 2550
Wire Wire Line
	5050 1700 5050 2550
Wire Wire Line
	5150 1700 5150 2550
Wire Wire Line
	5250 1700 5250 2550
Wire Wire Line
	5450 1700 5450 2550
Wire Wire Line
	5550 1700 5550 2550
Wire Wire Line
	5650 1700 5650 2550
Wire Wire Line
	5900 3700 6150 3700
Connection ~ 5900 3700
Wire Wire Line
	6150 3700 6150 4400
Connection ~ 6150 3700
Wire Wire Line
	6150 3700 7050 3700
Wire Wire Line
	6250 4400 6250 3800
Connection ~ 6250 3800
Wire Wire Line
	6250 3800 6350 3800
Wire Wire Line
	6350 4400 6350 3800
Connection ~ 6350 3800
Wire Wire Line
	6350 3800 6450 3800
Wire Wire Line
	6450 4400 6450 3800
Connection ~ 6450 3800
Wire Wire Line
	6450 3800 7150 3800
Wire Wire Line
	6550 3600 6550 4400
Wire Wire Line
	6650 3600 6650 4400
Wire Wire Line
	6650 3600 6700 3600
Wire Wire Line
	6700 3600 6700 3250
Wire Wire Line
	6750 3600 6750 4400
Wire Wire Line
	6850 3900 7700 3900
Wire Wire Line
	7300 1900 7300 2500
Connection ~ 7300 2500
Wire Wire Line
	7050 3600 7050 3350
Wire Wire Line
	7050 3350 7000 3350
Wire Wire Line
	6750 3600 7050 3600
Wire Wire Line
	6950 3500 6950 4400
Wire Wire Line
	7000 3250 7000 3350
Wire Wire Line
	7050 3700 7050 4400
Connection ~ 7050 3700
Wire Wire Line
	7050 3700 7800 3700
Wire Wire Line
	7150 3800 7150 4400
Connection ~ 7150 3800
Wire Wire Line
	7150 3800 7300 3800
Wire Wire Line
	7800 1900 7800 3700
Connection ~ 7800 3700
Wire Wire Line
	7800 3700 7900 3700
Connection ~ 7900 3800
Wire Wire Line
	7900 3800 8100 3800
Wire Wire Line
	7900 2000 7900 3800
Wire Wire Line
	3550 3800 6250 3800
$EndSCHEMATC
