LOAD CSV WITH HEADERS from "file:///Module_Six_Nut_Descs.csv" AS row
CREATE (n:NutDes)
SET n.NutrientCode = toInteger(row.`Nutrient code`), 
    n.NutrientDescription = row.`Nutrient description`, 
    n.NutrientDescriptionAbbrev = row.`Nutrient description abbrev`, 
    n.NutrientUnit = row.`Nutrient unit`, 
    n.DateAdded = date(row.`Date added`), 
    n.LastModified = date(row.`Last modified`)
