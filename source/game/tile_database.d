module game.tile_database;

import core.memory;
import graphics.texture_handler;
import optibrev;
import std.conv;
import std.stdio;
import std.string;

struct TileDefinition {
    string name = null;
    string modName = null;
    string texture = null;
    //! NEVER USE THESE.
    int id = -1;
    int textureIndex = -1;
}

static final const class TileDatabase {
static:
private:

    // Faster access based on ID or name.
    TileDefinition[string] nameDatabase;
    TileDefinition[int] idDatabase;

    // Insanely fast unsafe access based on ID alone from pointer arithmetic.
    // Do not use this unless you want to debug some "very cool" errors.
    TileDefinition* ultraFastAccess;

    int currentID = 0;

public: //* BEGIN PUBLIC API.

    void registerTile(TileDefinition newTile) {

        if (newTile.name is null) {
            throw new Error("Name for tile is null.");
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

    Option!TileDefinition getTileByID(int id) {
        Option!TileDefinition result;
        TileDefinition* thisDefinition = id in idDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    Option!TileDefinition getTileByName(string name) {
        Option!TileDefinition result;
        TileDefinition* thisDefinition = name in nameDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    /// Extremely unsafe API access.
    /// Do not use this unless you want to debug some "very cool" errors.
    TileDefinition* unsafeGetByID(int id) {
        return ultraFastAccess + id;
    }

    void finalize() {

        // Regular safe API access.
        foreach (name, ref thisDefinition; nameDatabase) {
            // todo: do the match thing below when sqlite is added in.
            thisDefinition.id = nextID();
            idDatabase[thisDefinition.id] = thisDefinition;
            debugWrite(thisDefinition);
        }

        // Extremely unsafe API access.
        // Do not use this unless you want to debug some "very cool" errors.
        ultraFastAccess = cast(TileDefinition*) GC.malloc(TileDefinition.sizeof * idDatabase.length);
        foreach (i; 0 .. idDatabase.length) {
            ultraFastAccess[i] = idDatabase[cast(int) i];

            assert(ultraFastAccess[i].modName == idDatabase[cast(int) i].modName);
            assert(ultraFastAccess[i].name == idDatabase[cast(int) i].name);
            assert(ultraFastAccess[i].id == idDatabase[cast(int) i].id);
            assert(ultraFastAccess[i].texture == idDatabase[cast(int) i].texture);
        }

    }

private: //* BEGIN INTERNAL API.

    void debugWrite(TileDefinition definition) {
        writeln("Tile " ~ definition.name ~ " at ID " ~ to!string(definition.id));
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
