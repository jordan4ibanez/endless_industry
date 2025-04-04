module game.biome_database;

import game.tile_database;

class BiomeDefinition {
    string name = null;
    string modName = null;

    int id = -1;

    string grassLayer = null;
    int grassLayerID = -1;
    string dirtLayer = null;
    int dirtLayerID = -1;
    string stoneLayer = null;
    int stoneLayerID = -1;

    // todo: noise parameters.

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
            TileDefinitionResult grassResult = TileDatabase.getTileByName(thisBiome.grassLayer);
            if (!grassResult.exists) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " grass layer " ~ thisBiome.grassLayer ~ " is not a registered block");
            }

            TileDefinitionResult dirtResult = TileDatabase.getTileByName(thisBiome.dirtLayer);
            if (!dirtResult.exists) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " dirt layer " ~ thisBiome.dirtLayer ~ " is not a registered block");
            }

            TileDefinitionResult stoneResult = TileDatabase.getTileByName(thisBiome.stoneLayer);
            if (!stoneResult.exists) {
                throw new Error(
                    "Biome " ~ thisBiome.name ~ " stone layer " ~ thisBiome.stoneLayer ~ " is not a registered block");
            }

            thisBiome.grassLayerID = grassResult.definition.id;
            thisBiome.dirtLayerID = dirtResult.definition.id;
            thisBiome.stoneLayerID = stoneResult.definition.id;

            // todo: do the match thing below when mongoDB is added in.
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

    // todo: make this pull the standard IDs into an associative array from the mongoDB.
    // todo: mongoDB should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new block.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
