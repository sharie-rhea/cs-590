// create unique constraints so future MATCHes are faster
CREATE CONSTRAINT FOR (n:NutDes) REQUIRE n.NutrientCode IS UNIQUE;
CREATE CONSTRAINT FOR (c:CTGNME) REQUIRE c.CategoryCode IS UNIQUE;
CREATE CONSTRAINT FOR (g:GPCNME) REQUIRE g.GPCCode IS UNIQUE;
CREATE CONSTRAINT FOR (f:FDes) REQUIRE f.CnCode IS UNIQUE;

// --- create nutrient descriptions
LOAD CSV WITH HEADERS from "file:///Module_Six_Nut_Descs_cleaned.csv" AS nutrient_row
CREATE (n:NutDes)
SET n.NutrientCode = toInteger(nutrient_row.`Nutrient code`),
	n.NutrientDescription = nutrient_row.`Nutrient description`,
	n.NutrientDescriptionAbbrev = nutrient_row.`Nutrient description abbrev`,
	n.NutrientUnit = nutrient_row.`Nutrient unit`,
	n.DateAdded = date(nutrient_row.`Date added`),
	n.LastModified = date(nutrient_row.`Last modified`);

// --- create categories
LOAD CSV WITH HEADERS from "file:///Module_Six_CTGNME_cleaned.csv" AS category_row
CREATE (c:CTGNME)
SET c.CategoryCode = toInteger(category_row.`Food category code`),
	c.CategoryDescription = category_row.`Category description`,
	c.DateAdded = date(category_row.`Date added`),
	c.LastModified = date(category_row.`Last modified`);

// --- create GPC codes
LOAD CSV WITH HEADERS from "file:///Module_Six_GPCNME_cleaned.csv" AS gpc_row
CREATE (g:GPCNME)
SET g.GPCCode = toInteger(gpc_row.`Gpc code`),
	g.GPCDescription = gpc_row.`Gpc description`,
	g.DateAdded = date(gpc_row.`Date added`),
	g.LastModified = date(gpc_row.`Last modified`);

// --- create foods
// NOTE: do not store GPCCode or CategoryCode (handled by relationships)
LOAD CSV WITH HEADERS from "file:///Module_Six_FDES_cleaned.csv" AS food_row
CREATE (f:FDes)
SET f.Description = food_row.`Descriptor`,
	f.AbbreviatedDescription = food_row.`Abbreviated descriptor`,
	f.CnCode = toInteger(food_row.`Cn code`),
	f.GTIN = food_row.`Gtin`,
	f.ProductCode = food_row.`Product code`,
	f.BrandOwner = food_row.`Brand owner name`,
	f.Brand = food_row.`Brand name`,
	f.FNSMaterialNumber = toInteger(food_row.`FNS Material Number`),
	f.SourceCode = toInteger(food_row.`Source code`),
	f.DateAdded = date(food_row.`Date added`),
	f.LastModified = date(food_row.`Last modified`),
	f.Discontinued = date(food_row.`Discontinued date`),
	f.Form = food_row.`Form of food`,
	f.FDCID = toInteger(food_row.`Fdc id`);

// link foods with their category
LOAD CSV WITH HEADERS from "file:///Module_Six_FDES_cleaned.csv" AS food_row
MATCH (f:FDes {CnCode: toInteger(food_row.`Cn code`)})
MATCH (category:CTGNME {CategoryCode: toInteger(food_row.`Food category code`)})
CREATE (f)-[:BELONGS_TO]->(category);

// link foods with their GPC code
LOAD CSV WITH HEADERS from "file:///Module_Six_FDES_cleaned.csv" AS food_row
MATCH (f:FDes {CnCode: toInteger(food_row.`Cn code`)})
MATCH (gpc:GPCNME {GPCCode: toInteger(food_row.`Gpc product code`)})
CREATE (f)-[:IDENTIFIED_BY]->(gpc);

// create weight nodes and link to appropriate food
LOAD CSV WITH HEADERS from "file:///Module_Six_WGHT_cleaned.csv" AS weight_row
MATCH (food:FDes {CnCode: toInteger(weight_row.`Cn Code`)})
CREATE (w:WGHT)
SET w.SequenceNumber = toInteger(weight_row.`Sequence num`),
    w.Amount = toFloat(weight_row.`Amount`),
    w.MeasureDescription = weight_row.`Measure description`,
    w.UnitAmount = toFloat(weight_row.`Unit amount`),
    w.TypeOfUnit = weight_row.`Type of unit`,
    w.SourceCode = toInteger(weight_row.`Source code`),
    w.DateAdded = date(weight_row.`Date added`),
    w.LastModified = date(weight_row.`Last modified`)
CREATE (food)-[:MEASURED_BY]->(w);

// link foods to their nutrient values (replaces NutVal)
LOAD CSV WITH HEADERS from "file:///Module_Six_Nut_Vals_cleaned.csv" AS value_row
MATCH (food:FDes {CnCode: toInteger(value_row.`Cn code`)})
MATCH (nutrient:NutDes {NutrientCode: toInteger(value_row.`Nutrient code`)})
CREATE (food)-[:CONTAINS {
    NutrientValue: toFloat(value_row.`Nutrient value`),
    PerUnit: value_row.`Per unit`,
    ValueTypeCode: toInteger(value_row.`Value type code`),
    SourceCode: toInteger(value_row.`Source code`),
    DateAdded: date(value_row.`Date added`),
    LastModified: date(value_row.`Last modified`)
}]->(nutrient);
