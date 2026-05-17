-- populate the source table based on info from the Child Nutrition Database Documentation
INSERT INTO public.source ("Source id", "Source description") VALUES
	(1, 'USDA FoodData Central - Standard Reference Legacy (SR Legacy)'),
	(2, 'FNS analysis of USDA standarized recipes for K-12'),
	(3, 'Food manufacturer data from GS1 GDSN through the USDA FoodData Central - Global Branded Food Products Database (Branded Foods)'),
	(4, 'FNS added sugars supplement'); 

-- populate the valuetype table based on info from the Child Nutrition Database Documentation
INSERT INTO public.valuetype ("Value type id", "Value type description") VALUES
	(1, 'Analytical or derived from analytical'),
	(2, 'Calculated'),
	(3, 'Imputed'),
	(4, 'Assumed Zero'),
	(5, 'Assumed added sugars equal total sugars'),
	(6, 'Provided by manufacturer'),
	(7, 'Aggregation of data');

-- load the 6 csv files
\copy public.nutdes FROM 'Module_Three_Nut_Descs.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
\copy public.gpcnme FROM 'Module_Three_GPCNME.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
\copy public.ctgnme FROM 'Module_Three_CTGNME.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
\copy public.fdes FROM 'Module_Three_FDES.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
\copy public.wght FROM 'Module_Three_WGHT.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
\copy public.nutval FROM 'Module_Three_Nut_Vals.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');
