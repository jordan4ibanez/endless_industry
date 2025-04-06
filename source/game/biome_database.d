module game.biome_database;

import game.tile_database;
import optibrev;

class BiomeDefinition {
    string name = null;
    string modName = null;
    string[] groundLayerTiles = null;

    ///! DO NOT USE.
    int id = -1;
    int[] groundLayerIDs = null;

    // todo: ores.
}

struct BiomeDefinitionResult {
    BiomeDefinition definition = null;
    bool exists = false;
}

static final const class BiomeDatabase {
static:
private:

    // Faster access based on ID or name.
    BiomeDefinition[string] nameDatabase;
    BiomeDefinition[int] idDatabase;

    int currentID = 0;

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

        if (newBiome.grassLayer is null) {
            throw new Error("Grass layer missing from biome " ~ newBiome.name);
        }

        if (newBiome.dirtLayer is null) {
            throw new Error("Dirt layer missing from biome " ~ newBiome.name);
        }

        if (newBiome.stoneLayer is null) {
            throw new Error("Stone layer missing from biome " ~ newBiome.name);
        }

        nameDatabase[newBiome.name] = newBiome;
    }

    BiomeDefinitionResult getBiomeByID(int id) {
        if (id !in idDatabase) {
            return BiomeDefinitionResult();
        }

        return BiomeDefinitionResult(idDatabase[id], true);
    }

    BiomeDefinitionResult getBiomeByName(string name) {
        if (name !in nameDatabase) {
            return BiomeDefinitionResult();
        }
        return BiomeDefinitionResult(nameDatabase[name], true);
    }

    void finalize() {

        foreach (name, ref thisBiome; nameDatabase) {
            Option!TileDefinition grassResult = TileDatabase.getTileByName(thisBiome.grassLayer);
            if (grassResult.isNone) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " grass layer " ~ thisBiome.grassLayer ~ " is not a registered tile");
            }

            Option!TileDefinition dirtResult = TileDatabase.getTileByName(thisBiome.dirtLayer);
            if (dirtResult.isNone) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " dirt layer " ~ thisBiome.dirtLayer ~ " is not a registered tile");
            }

            Option!TileDefinition stoneResult = TileDatabase.getTileByName(thisBiome.stoneLayer);
            if (stoneResult.isNone) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " stone layer " ~ thisBiome.stoneLayer ~ " is not a registered tile");
            }

            thisBiome.grassLayerID = grassResult.unwrap.id;
            thisBiome.dirtLayerID = dirtResult.unwrap.id;
            thisBiome.stoneLayerID = stoneResult.unwrap.id;

            // todo: do the match thing below when sqlite is added in.
            thisBiome.id = nextID();

            idDatabase[thisBiome.id] = thisBiome;

            debugWrite(thisBiome);
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
