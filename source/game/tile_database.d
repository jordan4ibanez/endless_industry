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

    void registerTile(TileDefinition newTile) {

        if (newTile.name is null) {
            throw new Error("Name for tile is null.");
        }

        if (newTile.name.toLower() == "air") {
            throw new Error("Tile air is reserved by engine.");
        }

        if (newTile.name in nameDatabase) {
            throw new Error("Trying to overwrite tile " ~ newTile.name);
        }

        if (newTile.modName is null) {
            throw new Error("Mod name is null for tile " ~ newTile.name);
        }

        if (newTile.texture is null) {
            throw new Error("Texture is null for tile " ~ newTile.name);
        }

        if (!TextureHandler.hasTexture(newTile.texture)) {
            throw new Error(
                "Texture " ~ newTile.texture ~ "for tile " ~ newTile.name ~ " does not exist");
        }

        nameDatabase[newTile.name] = newTile;
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

        foreach (name, ref thisDefinition; nameDatabase) {

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
        writeln("Tile " ~ definition.name ~ " at ID " ~ to!string(definition.id));
    }

    // todo: make this pull the standard IDs into an associative array from the mongoDB.
    // todo: mongoDB should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new tile.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
