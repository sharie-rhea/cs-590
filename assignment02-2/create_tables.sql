-- public.nutdes definition
CREATE TABLE public.nutdes (
    "Nutrient code" int4 PRIMARY KEY,
    "Nutrient description" varchar(50) NOT NULL,
    "Nutrient description abbrev" varchar(50) NOT NULL,
    "Nutrient unit" varchar(50) NOT NULL,
    "Date added" date,
    "Last modified" date
);

-- public.food definition
CREATE TABLE public.food (
    "Cn Code" int4 PRIMARY KEY
);

-- public.nutval definition
CREATE TABLE public.nutval (
    "Cn Code" int4 NOT NULL,
    "Nutrient code" int4 NOT NULL,
    "Nutrient value" real,
    "Per unit" varchar(50),
    "Value type code" int4,
    "Source code" int4,
    "Date added" date,
    "Last modified" date,

	-- composite primary key
    PRIMARY KEY ("Cn Code", "Nutrient code"),
    FOREIGN KEY("Cn Code") REFERENCES public.food("Cn Code"),
    FOREIGN KEY("Nutrient code") REFERENCES public.nutdes("Nutrient code")
);
