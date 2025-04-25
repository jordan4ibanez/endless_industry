module game.biome_database;

import core.memory;
import game.tile_database;
import optibrev;
import std.conv;
import std.stdio;
import std.string;

struct BiomeDefinition {
package:
    int id = -1;
    int[] groundLayerIDs = null;
    int[] waterLayerIDs = null;
    int[] waterLayerCornerIDs = null;

public:
    string name = null;
    // These are not really layers, they're different types.
    // But thinking of them as "layers" is slightly more intuitive. 
    string[] groundLayerTiles = null;
    string[] waterLayerTiles = null;
    string[] waterLayerCornerTiles = null;
}

static final const class BiomeDatabase {
static:
private:

    string modName = null;

    // Faster access based on ID or name.
    BiomeDefinition[string] nameDatabase;
    BiomeDefinition[int] idDatabase;

    int currentID = 0;

    // Insanely fast unsafe access based on ID alone from pointer arithmetic.
    // Do not use this unless you want to debug some "very cool" errors.
    BiomeDefinition* ultraFastAccess;

public: //* BEGIN PUBLIC API.

    ///! This is not to be used. Only for the mod API automation.
    void __setModName(string modName) {
        this.modName = modName;
    }

    void registerBiome(BiomeDefinition newBiome) {

        if (newBiome.name.empty()) {
            throw new Error("Biome is missing a name.");
        }

        if (newBiome.name in nameDatabase) {
            throw new Error("Tried to overwrite biome" ~ newBiome.name);
        }

        //? Ground layer.

        if (newBiome.groundLayerTiles.empty()) {
            throw new Error("Ground layer tiles is missing from biome " ~ newBiome.name);
        }

        if (newBiome.groundLayerTiles.length == 0) {
            throw new Error("Ground layer tiles is an empty array in biome " ~ newBiome.name);
        }

        foreach (index, value; newBiome.groundLayerTiles) {
            if (value.empty()) {
                throw new Error("Ground layer tile at index " ~ to!string(
                        index) ~ " in biome " ~ newBiome.name ~ " is null");
            }
        }

        //? Water layer.

        if (newBiome.waterLayerTiles.empty()) {
            throw new Error("Water layer tiles is missing from biome " ~ newBiome.name);
        }

        if (newBiome.waterLayerTiles.length == 0) {
            throw new Error("Water layer tiles is an empty array in biome " ~ newBiome.name);
        }

        foreach (index, value; newBiome.waterLayerTiles) {
            if (value.empty()) {
                throw new Error("Water layer tile at index " ~ to!string(
                        index) ~ " in biome " ~ newBiome.name ~ " is null");
            }
        }

        //? Water corner layer.

        if (newBiome.waterLayerCornerTiles.empty()) {
            throw new Error("Water corner layer tiles is missing from biome " ~ newBiome.name);
        }

        if (newBiome.waterLayerCornerTiles.length == 0) {
            throw new Error("Water corner layer tiles is an empty array in biome " ~ newBiome.name);
        }

        foreach (index, value; newBiome.waterLayerCornerTiles) {
            if (value.empty()) {
                throw new Error("Water corner layer tile at index " ~ to!string(
                        index) ~ " in biome " ~ newBiome.name ~ " is null");
            }
        }

        // Now inject the modname prefix into the biome name.
        newBiome.name = modName ~ "." ~ newBiome.name;

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

            // Make an ultra fast access implementation based on the names.

            //? Ground layer.

            thisBiome.groundLayerIDs = new int[](thisBiome.groundLayerTiles.length);

            foreach (index, tileName; thisBiome.groundLayerTiles) {
                Option!TileDefinition tileDefinitionResult = TileDatabase.getTileByName(tileName);

                if (tileDefinitionResult.isNone) {
                    throw new Error(
                        "Biome " ~ biomeName ~ " ground tile " ~ tileName ~ " in index " ~ to!string(
                            index) ~ " is not a registered tile");
                }

                thisBiome.groundLayerIDs[index] = tileDefinitionResult.unwrap.id;
            }

            //? Water layer.

            thisBiome.waterLayerIDs = new int[](thisBiome.waterLayerTiles.length);

            foreach (index, tileName; thisBiome.waterLayerTiles) {
                Option!TileDefinition tileDefinitionResult = TileDatabase.getTileByName(tileName);

                if (tileDefinitionResult.isNone) {
                    throw new Error(
                        "Biome " ~ biomeName ~ " water tile " ~ tileName ~ " in index " ~ to!string(
                            index) ~ " is not a registered tile");
                }

                thisBiome.waterLayerIDs[index] = tileDefinitionResult.unwrap.id;
            }

            //? Water corner layer.

            thisBiome.waterLayerCornerIDs = new int[](thisBiome.waterLayerCornerTiles.length);

            foreach (index, tileName; thisBiome.waterLayerCornerTiles) {
                Option!TileDefinition tileDefinitionResult = TileDatabase.getTileByName(tileName);

                if (tileDefinitionResult.isNone) {
                    throw new Error(
                        "Biome " ~ biomeName ~ " water corner tile " ~ tileName ~ " in index " ~ to!string(
                            index) ~ " is not a registered tile");
                }

                thisBiome.waterLayerCornerIDs[index] = tileDefinitionResult.unwrap.id;
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
