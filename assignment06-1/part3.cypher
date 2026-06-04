MATCH (nv:NutVal), (n:NutDes)
WHERE (nv.NutrientCode = n.NutrientCode)
CREATE (nv)-[:INSTANCE_OF]->(n)
RETURN nv, n
