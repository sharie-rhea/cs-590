-- 2172

select count("Cn Code") from nutval 
	join nutdes on (nutval."Nutrient code" = nutDes."Nutrient code") 
	where nutdes."Nutrient description" = 'Protein' 
		and nutval."Nutrient value" > 20
