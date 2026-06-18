#!/bin/bash

# Author: Sharie Rhea
# Date: 06.17.26
# Course: SNHU CS590

# prompt for overall log level
read -p "Log Level (default INFO): " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-INFO}

# run the python script to clean the raw CSV files provided as the data subset
echo "Preparing to clean and enrich raw CSV files..."
python3 clean_csvs.py $LOG_LEVEL
if [ $? -ne 0 ]; then
    echo "Error! Data preprocessing script failed!"
    exit 1
fi
echo "Data preprocessing complete!"
echo ""

# copy the newly cleaned files over to where the database can see them
# NOTE: this path is highly specific! In a production setting the DMBS would not be
# locally hosted and a connection would be made over a socket.
# Also, data loading would likely be done manually and infrequently, not with a script like this.
echo "Copying newly cleaned CSVs into database import directory..."
cp -r ../data/cleaned/ /home/sharie/.config/neo4j-desktop/Application/Data/dbmss/dbms-364971a4-af44-435e-95af-2922fb56138b/import/
echo ""

echo "Preparing to load data into the stackoverflow database..."
echo "User: cs590 Database: stackoverflow"
cypher-shell -a neo4j://localhost:7687 -u cs590 -d stackoverflow -f load_data.cypher
if [ $? -ne 0 ]; then
    echo "Error! Data loading script failed!"
    exit 1
fi
echo "Data loading complete!"
echo ""

echo "Starting validation queries..."
cypher-shell -a neo4j://localhost:7687 -u cs590 -d stackoverflow -f test_queries.cypher
if [ $? -ne 0 ]; then
    echo "Error! Data test script failed!"
    exit 1
fi
echo "Validation complete!"
