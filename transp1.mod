set PRODUCENTS;   # producents
set WAREHOUSES;   # warehouses
set VEGETABLES;   # vegetables
set STORES;		  # stores

param supply 		{PRODUCENTS,VEGETABLES} >= 0;  	# amounts available at producents
param max_capacity 	{WAREHOUSES} >= 0;       		# max capacity available at warehouses

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