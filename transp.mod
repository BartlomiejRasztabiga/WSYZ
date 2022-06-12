set PRODUCENTS;   													# zbior producentow (P1-P6)
set WAREHOUSES;   													# zbior magazynow (M1-M3)
set VEGETABLES;   													# zbior warzyw
set STORES;	  														# zbior sklepow (S1-S10)

param T > 0;														# liczba tygodni
param supply 					{PRODUCENTS,VEGETABLES} > 0;  		# podaz warzyw u producentow
param max_warehouse_capacity 	{WAREHOUSES} >= 0;       			# maksymalna pojemnosc magazynow
param distance_to_warehouse 	{PRODUCENTS,WAREHOUSES} > 0;  		# odleglosc od producenta do magazynu
param distance_to_store 		{WAREHOUSES,STORES} > 0;  			# odleglosc od magazynu do sklepu
param weekly_sales_forecast 	{1..T, STORES, VEGETABLES} >= 0;  	# prognozowana sprzedaz warzyw, w danym sklepie, w danym tygodniu
param store_warehouse_capacity 	{STORES} >= 0;       				# maksymalna pojemnosc przysklepowego magazynu
param km_cost > 0;													# koszt transportu 1 tony na odleglosc 1km

var yearly_transport_to_warehouses {PRODUCENTS,WAREHOUSES,VEGETABLES} >= 0; 	# tony transportowane od producentow do magazynow rocznie
var weekly_transport_to_stores {1..T,WAREHOUSES,STORES,VEGETABLES} >= 0;		# tony transportowane od magazynow do sklepow tygodniowo
var weekly_stores_warehouse_stock {1..T,STORES,VEGETABLES} >= 0;				# tony warzyw trzymane w magazynie przysklepowym tygodniowo

# funkcja celu - calkowity koszt transportu (transport producenci->magazyny->sklepy)
minimize Total_Cost:
	sum {p in PRODUCENTS, w in WAREHOUSES, v in VEGETABLES}
   		distance_to_warehouse[p,w] * km_cost * yearly_transport_to_warehouses[p,w,v]
	+
	sum {w in WAREHOUSES, s in STORES, v in VEGETABLES, n in 1..T}
   		distance_to_store[w,s] * km_cost *  weekly_transport_to_stores[n,w,s,v];
    
# ograniczenie: Wymagana ilosc warzyw w przysklepowych magazynach
subject to Store_Warehouse_Demand {s in STORES, n in 2..T, v in VEGETABLES}:
	weekly_stores_warehouse_stock[n, s, v] = weekly_stores_warehouse_stock[n-1, s, v] - weekly_sales_forecast[n, s, v] + sum {w in WAREHOUSES} weekly_transport_to_stores[n, w, s, v];
	
# ograniczenie: Wymagana ilosc warzyw w przysklepowych magazynach w 1 tygodniu
subject to Store_Warehouse_Demand_1_week {s in STORES, v in VEGETABLES}:
	weekly_stores_warehouse_stock[1, s, v] = -weekly_sales_forecast[1, s, v] + sum {w in WAREHOUSES} weekly_transport_to_stores[1, w, s, v];

# ograniczenie: Zapas warzyw nie powinien przekroczyc pojemnosci przysklepowego magazynu
subject to Store_Warehouse_Max_Capacity {s in STORES, n in 1..T}:
	sum {v in VEGETABLES} weekly_stores_warehouse_stock[n, s, v] <= store_warehouse_capacity[s];
	
# ograniczenie: Minimalny zapas warzyw (10% prognozy)
subject to Store_Warehouse_Min_Capacity {s in STORES, n in 1..T, v in VEGETABLES}:
	weekly_stores_warehouse_stock[n, s, v] >= 0.1 * weekly_sales_forecast[n, s, v];
	
# ograniczenie: Transport warzyw nie powinien przekroczyc pojemnosci przysklepowego magazynu
subject to Store_Warehouse_Max_Capacity_Transport {s in STORES, n in 1..T}:
	sum {w in WAREHOUSES, v in VEGETABLES} weekly_transport_to_stores[n, w, s, v] <= store_warehouse_capacity[s];
	
# ograniczenie: transport od producentow do magazynow >= popyt sklepow
subject to Warehouse_Supply {w in WAREHOUSES, v in VEGETABLES}:
	sum {p in PRODUCENTS} yearly_transport_to_warehouses[p, w, v] >= sum {s in STORES, n in 1..T} weekly_transport_to_stores[n, w, s, v];

# ograniczenie: transport od producentow do magazynow <= podaz producentow
subject to Producent_Supply {p in PRODUCENTS, v in VEGETABLES}:
	sum {w in WAREHOUSES} yearly_transport_to_warehouses[p,w,v] <= supply[p, v];

# ograniczenie: transport od producentow do magazynow <= maksymalna pojemnosc magazynow
subject to Warehouse_Max_Capacity {w in WAREHOUSES}:
	sum {p in PRODUCENTS, v in VEGETABLES} yearly_transport_to_warehouses[p,w,v] <= max_warehouse_capacity[w];




	
