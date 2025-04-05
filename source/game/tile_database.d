module game.tile_database;

import graphics.texture_handler;
import std.conv;
import std.stdio;
import std.string;

class TileDefinition {
    string name = null;
    string modName = null;
    string texture = null;
    int id = -1;
}

struct TileDefinitionResult {
    TileDefinition definition = null;
    bool exists = false;
}

static final const class TileDatabase {
static:
private:

    // Faster access based on ID or name.
    TileDefinition[string] nameDatabase;
    TileDefinition[int] idDatabase;

    int currentID = 2;

public: //* BEGIN PUBLIC API.

    void registerBlock(TileDefinition newBlock) {

        if (newBlock.name is null) {
            throw new Error("Name for block is null.");
        }

        if (newBlock.name.toLower() == "air") {
            throw new Error("Block air is reserved by engine.");
        }

        if (newBlock.name in nameDatabase) {
            throw new Error("Trying to overwrite block " ~ newBlock.name);
        }

        if (newBlock.modName is null) {
            throw new Error("Mod name is null for block " ~ newBlock.name);
        }

        if (newBlock.texture is null) {
            throw new Error("Texture is null for block " ~ newBlock.name);
        }

        if (!TextureHandler.hasTexture(newBlock.texture)) {
            throw new Error(
                "Texture " ~ newBlock.texture ~ "for block " ~ newBlock.name ~ " does not exist");
        }

        nameDatabase[newBlock.name] = newBlock;
    }

    bool hasTileID(int id) {
        if (id in idDatabase) {
            return true;
        }
        return false;
    }

    bool hasTileName(string name) {
        if (name in nameDatabase) {
            return true;
        }
        return false;
    }

    TileDefinitionResult getTileByID(int id) {
        if (id !in idDatabase) {
            return TileDefinitionResult();
        }

        return TileDefinitionResult(idDatabase[id], true);
    }

    TileDefinitionResult getTileByName(string name) {
        if (name !in nameDatabase) {
            return TileDefinitionResult();
        }
        return TileDefinitionResult(nameDatabase[name], true);
    }

    void finalize() {

        makeAir();
        makeBedrock();

        foreach (name, ref thisDefinition; nameDatabase) {

            if (name == "air" || name == "bedrock") {
                continue;
            }

            // todo: do the match thing below when mongoDB is added in.
            thisDefinition.id = nextID();
            idDatabase[thisDefinition.id] = thisDefinition;

            debugWrite(thisDefinition);
        }

    }

private: //* BEGIN INTERNAL API.

    void makeAir() {
        TileDefinition air = new TileDefinition();
        air.name = "air";
        air.modName = "engine";
        air.texture = "air.png";
        // todo: do the match thing below when mongoDB is added in.
        air.id = 0;

        debugWrite(air);

        nameDatabase[air.name] = air;
        idDatabase[air.id] = air;
    }

    void makeBedrock() {
        TileDefinition bedrock = new TileDefinition();
        bedrock.name = "bedrock";
        bedrock.modName = "engine";
        bedrock.texture = "default_bedrock.png";
        // todo: do the match thing below when mongoDB is added in.
        bedrock.id = 1;

        debugWrite(bedrock);

        nameDatabase[bedrock.name] = bedrock;
        idDatabase[bedrock.id] = bedrock;
    }

    void debugWrite(TileDefinition definition) {
        writeln("Block " ~ definition.name ~ " at ID " ~ to!string(definition.id));
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
