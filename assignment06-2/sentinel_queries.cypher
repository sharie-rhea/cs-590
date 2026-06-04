match (g:GPCNME) return count(g)
match (f:FDes) return count(f)
match (c:CTGNME) return count(c)
match (w:WGHT) return count(w)

// find number of foods from Kellogg's containing protein
MATCH (kellogg:FDes)-[:CONTAINS]->(protein:NutDes)
WHERE kellogg.Brand = "Kellogg's" AND protein.NutrientDescription = "Protein"
RETURN COUNT(kellogg)

// find all food->contains->nutrient that contain more than 1000 (unit) out of 100g of a given food
MATCH (food:FDes)-[contains:CONTAINS]->(nutrient:NutDes)
WHERE contains.NutrientValue > 1000 AND contains.PerUnit = "100g"
RETURN food, contains, nutrient
