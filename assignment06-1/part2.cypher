LOAD CSV WITH HEADERS from "file:///Module_Six_Nut_Vals.csv" AS rec
CREATE (nv:NutVal)
SET nv.CnCode = toInteger(rec.`Cn Code`),
    nv.NutrientCode = toInteger(rec.`Nutrient code`),
    nv.NutrientValue = toFloat(rec.`Nutrient value`),
    nv.PerUnit = rec.`Per unit`,
    nv.ValueTypeCode = toInteger(rec.`Value type code`),
    nv.SourceCode = toInteger(rec.`Source code`),
    nv.DateAdded = date(rec.`Date added`),
    nv.LastModified = date(rec.`Last modified`)
