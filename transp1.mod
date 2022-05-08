set PRODUCENTS;   # producents
set WAREHOUSES;   # warehouses
set VEGETABLES;   # vegetables
set STORES;		  # stores

param supply 		{PRODUCENTS,VEGETABLES} >= 0;  						# amounts available at producents
param max_capacity 	{WAREHOUSES} >= 0;       							# max capacity available at warehouses

param distance_to_warehouse {PRODUCENTS,WAREHOUSES} >= 0;  				# distance from producent to warehouse
param distance_to_store 	{WAREHOUSES,STORES} >= 0;  					# distance from warehouse to store

param weekly_sales_forecast {VEGETABLES,STORES} >= 0;  					# weekly sales forecast for vegetable and store

param store_warehouse_capacity 	{STORES} >= 0;       					# max store warehouse capacity available at the store

param km_cost >= 0;														# cost to move 1 ton by 1km

var yearly_transport_to_warehouses {PRODUCENTS,WAREHOUSES,VEGETABLES}; 	# tons transported from producents to warehouses yearly
var weekly_transport_to_stores {WAREHOUSES,STORES,VEGETABLES};			# tons transported from warehouses to stores weekly

/*minimize Total_Cost:
   sum {p in PRODUCENTS, w in WAREHOUSES, v in VEGETABLES}
      km_cost * yearly_transport_to_warehouses[p,w,v];*/
      
minimize Total_Cost:
   sum {w in WAREHOUSES, s in STORES, v in VEGETABLES}
      km_cost * weekly_transport_to_stores[w,s,v];
    
subject to Store_Weekly_Supply {v in VEGETABLES, s in STORES}:
	sum {w in WAREHOUSES}
		weekly_transport_to_stores[w, s, v] = weekly_sales_forecast[v, s];
	
# TODO obslugiwac transport co tydzien, a nie co rok * 52 :p
subject to Warehouse_Supply {w in WAREHOUSES, v in VEGETABLES}:
	sum {p in PRODUCENTS} yearly_transport_to_warehouses[p, w, v] = sum {s in STORES} 52 * weekly_transport_to_stores[w, s, v];


# TODO jakie jest demand dla magazynu?
# TODO ustalic koszty transportu producent->magazyn
# TODO jakie jest demand dla sklepow?
# TODO ustalic koszty transportu magazyn->sklep

# TODO ograniczenie: yearly_transport_to_warehouses <= max_capacity dla magazynu
# TODO ograniczenie: yearly_transport_to_warehouses <= supply
# TODO ograniczenie: Zapas warzyw nie powinien przekroczyć pojemności przysklepowego magazynu
# TODO ograniczenie: należy zachować minimalne zapasy każdego z warzyw (na wypadek błędów prognozy, należy przyjąć sensowne wartości, np. 10% średniej sprzedaży w tygodniu)


/*
param supply {PRODUCENTS,VEGETABLES} >= 0;  # amounts available at origins
param demand {WAREHOUSES,VEGETABLES} >= 0;  # amounts required at destinations

   check {p in VEGETABLES}:
      sum {i in PRODUCENTS} supply[i,p] = sum {j in DEST} demand[j,p];

param limit {PRODUCENTS,WAREHOUSES} >= 0;

param cost {PRODUCENTS,WAREHOUSES,VEGETABLES} >= 0;  # shipment costs per unit
var Trans {PRODUCENTS,WAREHOUSES,VEGETABLES} >= 0;   # units to be shipped

minimize Total_Cost:
   sum {i in PRODUCENTS, j in WAREHOUSES, p in VEGETABLES}
      cost[i,j,p] * Trans[i,j,p];

subject to Supply {i in PRODUCENTS, p in VEGETABLES}:
   sum {j in WAREHOUSES} Trans[i,j,p] = supply[i,p];

subject to Demand {j in WAREHOUSES, p in VEGETABLES}:
   sum {i in PRODUCENTS} Trans[i,j,p] = demand[j,p];

subject to Multi {i in PRODUCENTS, j in WAREHOUSES}:
   sum {p in VEGETABLES} Trans[i,j,p] <= limit[i,j];
*/