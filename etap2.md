# Projekt WSYZ - etap 2

#### Autorzy

Wojciech Kołodziejak
Mateusz Maj
Aleksandra Majewska
Bartłomiej Rasztabiga



### Producenci

P1 - Błonie
P2 - Książenice
P3 - Góra Kalwaria
P4 - Otwock
P5 - Wołomin
P6 - Legionowo

### Magazyny

M1 - Pruszków
M2 - Piaseczno
M3 - Zielonka

<div style="page-break-after: always;"></div>

### Sklepy

| Sklep | Adres                                             | Współrzędne            | Maksymalna pojemność magazynu przysklepowego [t] |
| ----- | ------------------------------------------------- | ---------------------- | ------------------------------------------------ |
| S1    | Béli Bartóka 8, 02-787 Warszawa                   | (52.162260, 21.028860) | 7,14                                             |
| S2    | Sady Żoliborskie 2, 01-772 Warszawa               | (52.267020, 20.974340) | 7,24                                             |
| S3    | al. Jerozolimskie 184, 02-486 Warszawa            | (52.200650, 20.932470) | 7,14                                             |
| S4    | Sportowa 30, 05-090 Raszyn                        | (52.150160, 20.930130) | 7,22                                             |
| S5    | Jana Pawła Woronicza 17, 00-999 Warszawa          | (52.188710, 21.011170) | 7,27                                             |
| S6    | Aleksandra Gierymskiego 19, 00-772 Warszawa       | (52.200830, 21.034420) | 7,20                                             |
| S7    | Jana Nowaka-Jeziorańskiego 44/U1, 03-982 Warszawa | (52.230050, 21.078680) | 7,21                                             |
| S8    | plac Stanisława Małachowskiego 2, 00-066 Warszawa | (52.238890, 21.012850) | 7,14                                             |
| S9    | Jana Ciszewskiego 15, 02-777 Warszawa             | (52.153782, 21.039921) | 7,20                                             |
| S10   | Górczewska 88, 01-117 Warszawa                    | (52.239310, 20.945250) | 7,26                                             |



### Model optymalizacyjny

`transp.mod`

```
set PRODUCENTS;	# zbiór producentów (P1-P6)
set WAREHOUSES;	# zbiór magazynów (M1-M3)
set VEGETABLES;	# zbiór warzyw
set STORES;	# zbiór sklepów (S1-S10)

# liczba tygodni
param T > 0;

# podaż warzyw u producentów
param supply 			{PRODUCENTS,VEGETABLES} > 0;

# maksymalna pojemność magazynów
param max_warehouse_capacity 	{WAREHOUSES} >= 0; 

# odległość od producenta do magazynu
param distance_to_warehouse 	{PRODUCENTS,WAREHOUSES} > 0; 

# odległość od magazynu do sklepu
param distance_to_store 	{WAREHOUSES,STORES} > 0; 

# prognozowana sprzedaż warzyw, w danym sklepie, w danym tygodniu
param weekly_sales_forecast 	{1..T, STORES, VEGETABLES} >= 0; 

# maksymalna pojemność przysklepowego magazynu
param store_warehouse_capacity 	{STORES} >= 0;

# koszt transportu 1 tony na odległość 1km
param km_cost > 0; 

# tony transportowane od producentów do magazynów rocznie
var yearly_transport_to_warehouses {PRODUCENTS,WAREHOUSES,VEGETABLES} >= 0;

# tony transportowane od magazynów do sklepów tygodniowo
var weekly_transport_to_stores {1..T,WAREHOUSES,STORES,VEGETABLES} >= 0; 

# funkcja celu - całkowity koszt transportu (transport producenci->magazyny->sklepy)
minimize Total_Cost:
	sum {p in PRODUCENTS, w in WAREHOUSES, v in VEGETABLES}
   		distance_to_warehouse[p,w] * km_cost * yearly_transport_to_warehouses[p,w,v]
	+
	sum {w in WAREHOUSES, s in STORES, v in VEGETABLES, n in 1..T}
   		distance_to_store[w,s] * km_cost *  weekly_transport_to_stores[n,w,s,v];
    
# ograniczenie: transport do sklepów + należy zachować minimalne zapasy każdego z warzyw  np. 10% średniej sprzedaży w tygodniu
subject to Store_Weekly_Supply {v in VEGETABLES, s in STORES, n in 1..T}:
	sum {w in WAREHOUSES}
		weekly_transport_to_stores[n, w, s, v] >= 1.1 * weekly_sales_forecast[n, s, v];
	
# ograniczenie: transport od producentów do magazynów >= popyt sklepów
subject to Warehouse_Supply {w in WAREHOUSES, v in VEGETABLES}:
	sum {p in PRODUCENTS} yearly_transport_to_warehouses[p, w, v] >= sum {s in STORES, n in 1..T} weekly_transport_to_stores[n, w, s, v];

# ograniczenie: transport od producentów do magazynów <= podaż producentów
subject to Producent_Supply {p in PRODUCENTS, v in VEGETABLES}:
	sum {w in WAREHOUSES} yearly_transport_to_warehouses[p,w,v] <= supply[p, v];

# ograniczenie: transport od producentów do magazynów <= maksymalna pojemność magazynów
subject to Warehouse_Max_Capacity {w in WAREHOUSES}:
	sum {p in PRODUCENTS, v in VEGETABLES} yearly_transport_to_warehouses[p,w,v] <= max_warehouse_capacity[w];

# ograniczenie: Zapas warzyw nie powinien przekroczyć pojemności przysklepowego magazynu
subject to Store_Warehouse_Max_Capacity {s in STORES, n in 1..T}:
	sum {w in WAREHOUSES, v in VEGETABLES} weekly_transport_to_stores[n, w, s, v] <= store_warehouse_capacity[s];
```



### Dane do optymalizacji

`transp.dat`


### Wyniki optymalizacji

Pełne wyniki w `output.txt`

```
CPLEX 20.1.0.0: optimal solution; objective 280832.1356
2571 dual simplex iterations (0 in phase I)

Total_Cost = 280832
```



Całkowity minimalny koszt transportu wyniósł: **280 832 zł**