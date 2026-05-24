// setup database context
const db = db.getSiblingDB('nutrition');
print("--- Starting Full ETL Process ---");

// transform helper function
function runTransformation(collectionName, pipeline) {
    try {
        print(`Transforming ${collectionName}...`);
        db[collectionName].aggregate(pipeline);
        print(`Successfully updated ${collectionName}.`);
    } catch (e) {
        print(`Error transforming ${collectionName}: ${e.message}`);
    }
}

// transformation pipeline for NUTVAL
const valPipeline = [
    {
        $project: {
            "row.Cn code": { $convert: { input: "$row.Cn code", to: "int", onError: null, onNull: null } },
            "row.Nutrient code": { $convert: { input: "$row.Nutrient code", to: "int", onError: null, onNull: null } },
            "row.Nutrient value": { $convert: { input: "$row.Nutrient value", to: "double", onError: 0.0, onNull: 0.0 } },
            "row.Per unit": "$row.Per unit",
            "row.Value type code": { $convert: { input: "$row.Value type code", to: "int", onError: null, onNull: null } },
            "row.Source code": { $convert: { input: "$row.Source code", to: "int", onError: null, onNull: null } },
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_vals" }
];

// transformation pipeline for NUTDES
const descPipeline = [
    {
        $project: {
            "row.Nutrient code": { $convert: { input: "$row.Nutrient code", to: "int", onError: null, onNull: null } },
            "row.Nutrient description": "$row.Nutrient description",
			"row.Nutrient description abbrev": "$row.Nutrient description abbrev",
            "row.Nutrient unit": "$row.Nutrient unit",
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_descs" }
];

// transformation pipeline for CTGNME
const ctgnmePipeline = [
    {
        $project: {
            "row.Food category code": { $convert: { input: "$row.Food category code", to: "int", onError: null, onNull: null } },
            "row.Category description": "$row.Category description",
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_ctgnme" }
];

// transformation pipeline for FDES
const fdesPipeline = [
    {
        $project: {
            "row.Food category code": { $convert: { input: "$row.Food category code", to: "int", onError: null, onNull: null } },
            "row.Descriptor": "$row.Descriptor",
            "row.Abbreviated descriptor": "$row.Abbreviated descriptor",
            "row.Cn code": { $convert: { input: "$row.Cn code", to: "int", onError: null, onNull: null } },
            "row.Gtin": "$row.Gtin",
            "row.Product code": "$row.Product code",
			"row.Brand owner name": "$row.Brand owner name",
			"row.Brand name": "$row.Brand name",
			"row.FNS Material Number": { $convert: { input: "$row.FNS Material Number", to: "int", onError: null, onNull: null } },
            "row.Source code": { $convert: { input: "$row.Source code", to: "int", onError: null, onNull: null } },
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } },
            "row.Discontinued date": { $convert: { input: "$row.Discontinued date", to: "date", onError: null, onNull: null } },
			"row.Form of food": "$row.Form of food",
			"row.Fdc id": { $convert: { input: "$row.Fdc id", to: "int", onError: null, onNull: null } },
			"row.Gpc product code": { $convert: { input: "$row.Gpc product code", to: "int", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_fdes" }
];

// transformation pipeline for GPCNME
const gpcnmePipeline = [
    {
        $project: {
			"row.Gpc code": { $convert: { input: "$row.Gpc code", to: "int", onError: null, onNull: null } },
			"row.Gpc description": "$row.Gpc description",
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_gpcnme" }
];

// transformation pipeline for WGHT
const wghtPipeline = [
    {
        $project: {
			"row.Sequence num": { $convert: { input: "$row.Sequence num", to: "int", onError: null, onNull: null } },
			"row.Cn code": { $convert: { input: "$row.Cn code", to: "int", onError: null, onNull: null } },
			"row.Measure description": "$row.Measure description",
            "row.Unit amount": { $convert: { input: "$row.Unit amount", to: "double", onError: 0.0, onNull: 0.0 } },
			"row.Type of unit": "$row.Type of unit",
			"row.Source code": { $convert: { input: "$row.Source code", to: "int", onError: null, onNull: null } },
            "row.Date added": { $convert: { input: "$row.Date added", to: "date", onError: null, onNull: null } },
            "row.Last modified": { $convert: { input: "$row.Last modified", to: "date", onError: null, onNull: null } }
        }
    },
    { $out: "nutrient_wght" }
];

// execute transformations
runTransformation("nutrient_descs", descPipeline);
runTransformation("nutrient_vals", valPipeline);

runTransformation("nutrient_ctgnme", ctgnmePipeline);
runTransformation("nutrient_fdes", fdesPipeline);
runTransformation("nutrient_gpcnme", gpcnmePipeline);
runTransformation("nutrient_wght", wghtPipeline);

print("\nETL process finished!");
