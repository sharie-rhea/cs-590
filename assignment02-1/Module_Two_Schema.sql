-- public.nutdes definition

-- Drop table

-- DROP TABLE public.nutdes;

CREATE TABLE public.nutdes (
	"Nutrient code" int4 NOT NULL,
	"Nutrient description" varchar(50) NOT NULL,
	"Nutrient description abbrev" varchar(50) NOT NULL,
	"Nutrient unit" varchar(50) NOT NULL,
	"Date added" date NULL,
	"Last modified" date NULL
);
