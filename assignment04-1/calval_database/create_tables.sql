-- public.source definition, where the food info comes from, mapping defined in CNDB documentation
CREATE TABLE IF NOT EXISTS public.source (
	"Source id" int4 PRIMARY KEY,
	"Source description" varchar(255) NOT NULL
);

-- public.valuetype definition, how nutrient value was calculated, mapping defined in CNDB documentation
CREATE TABLE IF NOT EXISTS public.valuetype (
	"Value type id" int4 PRIMARY KEY,
	"Value type description" varchar(255) NOT NULL
);

-- public.nutdes definition, nutrient descriptions
CREATE TABLE IF NOT EXISTS public.nutdes (
    "Nutrient code" int4 PRIMARY KEY, -- unique nutrient identifier
    "Nutrient description" varchar(30) NOT NULL,
    "Nutrient description abbrev" varchar(10) NOT NULL,
    "Nutrient unit" varchar(5) NOT NULL,
    "Date added" date,
    "Last modified" date
);
-- public.gpcnme definition, GPC category names
CREATE TABLE IF NOT EXISTS public.gpcnme (
	"Gpc code" int4 PRIMARY KEY,
	"Gpc description" varchar(100) NOT NULL,
	"Date added" date,
	"Last modified" date
);

-- public.ctgnme definition, food category names
CREATE TABLE IF NOT EXISTS public.ctgnme (
	"Food category code" int4 PRIMARY KEY, -- unique category identifier
	"Category description" varchar(100) NOT NULL,
	"Date added" date,
	"Last modified" date
);

-- public.fdes definition, food descriptions
CREATE TABLE IF NOT EXISTS public.fdes (
	"Food category code" int4, -- NULLABLE, food may not fit into one of the predefined categories or may be unknown
	"Descriptor" varchar(255) NOT NULL,
	"Abbreviated descriptor" varchar(60) NOT NULL,
	"Cn code" int4 PRIMARY KEY, -- unique code for this food item
	"Gtin" varchar(255), -- NULLABLE, always numeric, but can be too big for a standard integer, follow CNDB documentation of alphanumeric 255
	"Product code" varchar(15), -- NULLABLE, alphanumeric, can contain letters
	"Brand owner name" varchar(80), -- NULLABLE
	"Brand name" varchar(80), -- NULLABLE
	"FNS Material Number" int4, -- switched to int from varchar(6)
	"Source code" int4, -- NULLABLE
	"Date added" date,
	"Last modified" date,
	"Discontinued date" date, -- only applies to source code 3 items
	"Form of food" varchar(100), -- NULLABLE
	"Fdc id" int4, -- NULLABLE
	"Gpc product code" int4, -- NULLABLE

    FOREIGN KEY("Food category code") REFERENCES public.ctgnme("Food category code"),
    FOREIGN KEY("Gpc product code") REFERENCES public.gpcnme("Gpc code"),
	FOREIGN KEY("Source code") REFERENCES public.source("Source id")
);

-- public.wght definition, serving size information
CREATE TABLE IF NOT EXISTS public.wght (
	"Cn code" int4 NOT NULL,
	"Sequence num" int4 NOT NULL,
	"Amount" real NOT NULL,
	"Measure description" varchar(100) NOT NULL,
	"Unit amount" real NOT NULL,
	"Type of unit" varchar(2) NOT NULL,
	"Source code" int4, -- NULLABLE
	"Date added" date,
	"Last modified" date,

	-- composite primary key, some foods have more than one unit of measure
	-- sequence number indicates the order of the different types of measures for a given cn code
	PRIMARY KEY("Cn code", "Sequence num"),
	FOREIGN KEY("Cn code") REFERENCES public.fdes("Cn code"),
	FOREIGN KEY("Source code") REFERENCES public.source("Source id")
);

-- public.nutval definition, nutrient values
CREATE TABLE IF NOT EXISTS public.nutval (
    "Cn Code" int4 NOT NULL,
    "Nutrient code" int4 NOT NULL,
    "Nutrient value" real, -- in practice should be NOT NULL, but our dataset contains 19805 null values...
	"Per unit" varchar(5) NOT NULL,
    "Value type code" int4, -- NULLABLE
    "Source code" int4, -- NULLABLE
    "Date added" date,
    "Last modified" date,

	-- composite primary key, unique combination of food (cn code) and nutrient (nutrient code)
    PRIMARY KEY("Cn Code", "Nutrient code"),
    FOREIGN KEY("Cn Code") REFERENCES public.fdes("Cn code"),
    FOREIGN KEY("Nutrient code") REFERENCES public.nutdes("Nutrient code"),
	FOREIGN KEY("Value type code") REFERENCES public.valuetype("Value type id"),
	FOREIGN KEY("Source code") REFERENCES public.source("Source id")
);
