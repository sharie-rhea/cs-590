#!/bin/bash

echo "Importing raw JSON data..."
mongoimport --db nutrition --collection nutrient_descs --file Module_Five_Nut_Descs.json --jsonArray --drop
mongoimport --db nutrition --collection nutrient_vals --file Module_Five_Nut_Vals.json --jsonArray --drop
mongoimport --db nutrition --collection nutrient_ctgnme --file Module_Five_CTGNME.json --jsonArray --drop
mongoimport --db nutrition --collection nutrient_fdes --file Module_Five_FDES.json --jsonArray --drop
mongoimport --db nutrition --collection nutrient_gpcnme --file Module_Five_GPCNME.json --jsonArray --drop
mongoimport --db nutrition --collection nutrient_wght --file Module_Five_WGHT.json --jsonArray --drop
echo "Raw JSON data imported!"

echo "Running transformations..."
mongosh transform.js

echo "ETL pipeline complete!"

echo "Running sentinel queries..."
mongosh nutrition module_Five.mql

echo "Script complete!"
