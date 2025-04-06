module game.biome_database;

import core.memory;
import game.tile_database;
import std.conv;
import std.stdio;
import utility.option;

struct BiomeDefinition {
    string name = null;
    string modName = null;
    string[] groundLayerTiles = null;

    ///! DO NOT USE.
    int id = -1;
    int[] groundLayerIDs = null;

    // todo: ores.
}

static final const class BiomeDatabase {
static:
private:

    // Faster access based on ID or name.
    BiomeDefinition[string] nameDatabase;
    BiomeDefinition[int] idDatabase;

    int currentID = 0;

    // Insanely fast unsafe access based on ID alone from pointer arithmetic.
    // Do not use this unless you want to debug some "very cool" errors.
    BiomeDefinition* ultraFastAccess;

public: //* BEGIN PUBLIC API.

    void registerBiome(BiomeDefinition newBiome) {

        if (newBiome.name is null) {
            throw new Error("Biome is missing a name.");
        }

        if (newBiome.name in nameDatabase) {
            throw new Error("Tried to overwrite biome" ~ newBiome.name);
        }

        if (newBiome.modName is null) {
            throw new Error("Mod name is missing from biome " ~ newBiome.name);
        }

        if (newBiome.groundLayerTiles is null) {
            throw new Error("Ground layer tiles is missing from biome " ~ newBiome.name);
        }

        if (newBiome.groundLayerTiles.length == 0) {
            throw new Error("Ground layer tiles is an empty array in biome " ~ newBiome.name);
        }

        foreach (index, value; newBiome.groundLayerTiles) {
            if (value is null) {
                throw new Error("Ground layer tile at index " ~ to!string(
                        index) ~ " in biome " ~ newBiome.name ~ " is null");
            }
        }

        nameDatabase[newBiome.name] = newBiome;
    }

    Option!BiomeDefinition getBiomeByID(int id) {
        Option!BiomeDefinition result;
        BiomeDefinition* thisDefinition = id in idDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    Option!BiomeDefinition getBiomeByName(string name) {
        Option!BiomeDefinition result;
        BiomeDefinition* thisDefinition = name in nameDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    int getNumberOfBiomes() {
        return currentID;
    }

    BiomeDefinition* unsafeGetByID(int id) {
        return ultraFastAccess + id;
    }

    void finalize() {

        ultraFastAccess = cast(BiomeDefinition*) GC.malloc(
            BiomeDefinition.sizeof * nameDatabase.length);

        foreach (biomeName, ref thisBiome; nameDatabase) {

            thisBiome.groundLayerIDs = new int[](thisBiome.groundLayerTiles.length);

            // Make an ultra fast access implementation based on the names.
            foreach (index, tileName; thisBiome.groundLayerTiles) {
                Option!TileDefinition tileDefinitionResult = TileDatabase.getTileByName(tileName);

                if (tileDefinitionResult.isNone) {
                    throw new Error(
                        "Biome " ~ biomeName ~ " tile " ~ tileName ~ " in index " ~ to!string(
                            index) ~ " is not a registered tile");
                }

                thisBiome.groundLayerIDs[index] = tileDefinitionResult.unwrap.id;
            }

            // todo: do the match thing below when sqlite is added in.
            thisBiome.id = nextID();

            idDatabase[thisBiome.id] = thisBiome;

            // Begin ultra fast access.
            ultraFastAccess[thisBiome.id] = thisBiome;
        }
    }

private: //* BEGIN INTERNAL API.

    void debugWrite(BiomeDefinition biome) {
        import std.conv;
        import std.stdio;

        writeln("Biome " ~ biome.name ~ " at ID " ~ to!string(biome.id));
    }

    // todo: make this pull the standard IDs into an associative array from the sqlite.
    // todo: sqlite should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new tile.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
