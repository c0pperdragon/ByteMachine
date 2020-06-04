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
A19
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
Connection ~ 7050 3700
Wire Wire Line
	3550 3800 6250 3800
Connection ~ 7150 3800
Text Label 8050 3700 2    50   ~ 0
5V
Text Label 8050 3800 2    50   ~ 0
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
P 6350 2900
F 0 "U2" H 6400 2900 50  0000 R CNN
F 1 "74HC00" V 6350 2650 50  0000 R CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6350 2900 50  0001 C CNN
F 3 "" H 6350 2900 50  0001 C CNN
	1    6350 2900
	0    -1   -1   0   
$EndComp
Text Label 8050 2000 2    50   ~ 0
5V
Text Label 8050 2100 2    50   ~ 0
GND
Wire Wire Line
	3550 2000 4050 2000
Text Label 3850 1650 3    50   ~ 0
RES
Wire Wire Line
	3850 2550 3850 1650
Wire Wire Line
	4150 2550 4150 2400
Wire Wire Line
	6850 4350 6850 4400
Wire Wire Line
	6650 3250 6650 4400
Wire Wire Line
	6550 3250 6550 3500
Connection ~ 6550 3500
Wire Wire Line
	6550 3500 6200 3500
Wire Wire Line
	6750 3600 6900 3600
Wire Wire Line
	6750 3600 6750 4400
Wire Wire Line
	4450 2550 4450 2300
Wire Wire Line
	6550 2300 6550 2550
Wire Wire Line
	6550 2300 6650 2300
Wire Wire Line
	6650 2300 6650 2550
Connection ~ 6550 2300
Wire Wire Line
	7550 2300 7550 3400
Wire Wire Line
	6950 3500 6950 4400
Wire Wire Line
	6450 2550 6450 2500
Connection ~ 6450 2000
Wire Wire Line
	6750 2550 6750 2300
Wire Wire Line
	6750 2300 7550 2300
Wire Wire Line
	6450 3250 6450 3400
Wire Wire Line
	6550 3500 6750 3500
Wire Wire Line
	6850 3400 7550 3400
Wire Wire Line
	6850 3250 6850 3400
Wire Wire Line
	6900 3300 6950 3300
Wire Wire Line
	6950 3300 6950 3250
Wire Wire Line
	6900 3300 6900 3600
Wire Wire Line
	5850 4400 5850 4350
Wire Wire Line
	5950 4400 5950 4350
Wire Wire Line
	6050 4400 6050 4350
Wire Wire Line
	6550 4400 6550 4350
Wire Wire Line
	7050 3700 7050 4400
Wire Wire Line
	7150 3800 7150 4400
Wire Wire Line
	7850 2100 7850 3800
Connection ~ 7850 2100
Wire Wire Line
	7850 2100 8050 2100
Connection ~ 7850 3800
Wire Wire Line
	7850 3800 8050 3800
Wire Wire Line
	7750 3700 7750 2000
Connection ~ 7750 3700
Wire Wire Line
	7750 3700 8050 3700
Connection ~ 7750 2000
Wire Wire Line
	7750 2000 8050 2000
Wire Wire Line
	6450 2000 7750 2000
Wire Wire Line
	7050 3700 7750 3700
Wire Wire Line
	7150 3800 7250 3800
Wire Wire Line
	5350 2550 5350 2200
Wire Wire Line
	5350 2200 6850 2200
NoConn ~ 3950 2550
Wire Wire Line
	4250 2550 4250 2000
Connection ~ 4250 2000
Wire Wire Line
	4250 2000 6450 2000
Wire Wire Line
	3550 2100 5750 2100
Wire Wire Line
	4050 2550 4050 2000
Connection ~ 4050 2000
Wire Wire Line
	4050 2000 4250 2000
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
Wire Wire Line
	4350 3700 4550 3700
NoConn ~ 4450 3250
Wire Wire Line
	4550 3250 4550 3300
Connection ~ 4550 3700
Wire Wire Line
	5750 2550 5750 2500
Connection ~ 5750 2100
Wire Wire Line
	5750 2100 7850 2100
Text Label 4550 1800 1    50   ~ 0
D0
Wire Wire Line
	4550 2550 4550 1800
Text Label 4650 1800 1    50   ~ 0
D1
Text Label 4750 1800 1    50   ~ 0
D2
Text Label 4850 1800 1    50   ~ 0
D3
Text Label 4950 1800 1    50   ~ 0
D4
Text Label 5050 1800 1    50   ~ 0
D5
Text Label 5150 1800 1    50   ~ 0
D6
Text Label 5250 1800 1    50   ~ 0
D7
Text Label 5450 1800 1    50   ~ 0
A14
Text Label 5550 1800 1    50   ~ 0
A13
Text Label 5650 1800 1    50   ~ 0
A12
Wire Wire Line
	5450 2550 5450 1800
Wire Wire Line
	5550 2550 5550 1800
Wire Wire Line
	5650 2550 5650 1800
Wire Wire Line
	5250 1800 5250 2550
Wire Wire Line
	5150 2550 5150 1800
Wire Wire Line
	5050 2550 5050 1800
Wire Wire Line
	4950 2550 4950 1800
Wire Wire Line
	4850 2550 4850 1800
Wire Wire Line
	4750 2550 4750 1800
Wire Wire Line
	4650 2550 4650 1800
Wire Wire Line
	7050 2550 7050 1800
Text Label 7050 1800 1    50   ~ 0
A19
Wire Wire Line
	6250 3800 6250 4400
Connection ~ 6250 3800
Wire Wire Line
	6250 3800 6350 3800
Wire Wire Line
	6350 3800 6350 4400
Connection ~ 6350 3800
Wire Wire Line
	6350 3800 6450 3800
Wire Wire Line
	6450 3800 6450 4400
Connection ~ 6450 3800
Wire Wire Line
	6450 3800 7150 3800
Wire Wire Line
	6150 3700 6150 4400
Connection ~ 6150 3700
Wire Wire Line
	6150 3700 7050 3700
$Comp
L Device:C_Small C1
U 1 1 5EE8D589
P 5900 2900
F 0 "C1" H 6000 2900 50  0000 L CNN
F 1 "100nF" H 5950 2800 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 5900 2900 50  0001 C CNN
F 3 "~" H 5900 2900 50  0001 C CNN
	1    5900 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 3400 6300 2300
Wire Wire Line
	6300 3400 6450 3400
Connection ~ 6300 2300
Wire Wire Line
	6300 2300 6550 2300
Wire Wire Line
	4450 2300 6300 2300
Wire Wire Line
	6200 2400 6200 3500
Wire Wire Line
	4150 2400 6200 2400
Wire Wire Line
	4550 3700 6150 3700
Wire Wire Line
	5750 2500 5900 2500
Connection ~ 5750 2500
Wire Wire Line
	5750 2500 5750 2100
Wire Wire Line
	5900 2500 5900 2800
Wire Wire Line
	4550 3300 5900 3300
Connection ~ 4550 3300
Wire Wire Line
	5900 3300 5900 3000
Wire Wire Line
	4550 3300 4550 3700
Connection ~ 6750 3500
Wire Wire Line
	6750 3250 6750 3500
Wire Wire Line
	6750 3500 6950 3500
Wire Wire Line
	6850 2200 6950 2200
Connection ~ 6850 2200
Wire Wire Line
	6850 2200 6850 2550
Wire Wire Line
	6950 2200 6950 2550
$Comp
L Device:C_Small C2
U 1 1 5EF19D4E
P 7250 2900
F 0 "C2" H 7350 2900 50  0000 L CNN
F 1 "100nF" H 7300 2800 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.0mm_W2.0mm_P2.50mm" H 7250 2900 50  0001 C CNN
F 3 "~" H 7250 2900 50  0001 C CNN
	1    7250 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7250 2800 7250 2500
Connection ~ 6450 2500
Wire Wire Line
	6450 2500 6450 2000
Wire Wire Line
	7250 3000 7250 3300
Wire Wire Line
	7250 3300 7050 3300
Wire Wire Line
	7050 3300 7050 3250
Wire Wire Line
	7250 3300 7250 3800
Connection ~ 7250 3300
Connection ~ 7250 3800
Wire Wire Line
	7250 3800 7850 3800
Wire Wire Line
	6450 2500 7250 2500
Text Label 3550 2100 0    50   ~ 0
GND
Text Label 3550 2000 0    50   ~ 0
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
$EndSCHEMATC
