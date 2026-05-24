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

// execute transformations
runTransformation("nutrient_descs", descPipeline);
runTransformation("nutrient_vals", valPipeline);

print("\nETL process finished!");
