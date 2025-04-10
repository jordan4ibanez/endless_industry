module game.ore_database;

import core.memory;
import graphics.texture;
import optibrev;
import std.conv;
import std.stdio;

struct OreDefinition {
    string name = null;
    string texture = null;
    string minedItem = null;
    // uint minedItemAmount = 0;

    ///! DO NOT USE.
    int id = -1;
    ulong texturePointsIndex = 0;
}

static final const class OreDatabase {
static:
private:

    string modName = null;

    // Faster access based on ID or name.
    OreDefinition[string] nameDatabase;
    OreDefinition[int] idDatabase;

    // Insanely fast unsafe access based on ID alone from pointer arithmetic.
    // Do not use this unless you want to debug some "very cool" errors.
    OreDefinition* ultraFastAccess;

    int currentID = 0;

public: //* BEGIN PUBLIC API.

    ///! This is not to be used. Only for the mod API automation.
    void setModName(string modName) {
        this.modName = modName;
    }

    void registerOre(OreDefinition newOre) {
        if (newOre.name is null) {
            throw new Error("Name for ore is null.");
        }

        if (newOre.name in nameDatabase) {
            throw new Error("Trying to overwrite ore " ~ newOre.name);
        }

        if (newOre.texture is null) {
            throw new Error("Texture is null for ore " ~ newOre.name);
        }

        if (!TextureHandler.hasTexture(newOre.texture)) {
            throw new Error(
                "Texture " ~ newOre.texture ~ " for ore " ~ newOre.name ~ " does not exist");
        }

        // Now inject the modname prefix into the biome name.
        newOre.name = modName ~ "." ~ newOre.name;

        nameDatabase[newOre.name] = newOre;

    }

    bool hasOreID(int id) {
        if (id in idDatabase) {
            return true;
        }
        return false;
    }

    bool hasOreName(string name) {
        if (name in nameDatabase) {
            return true;
        }
        return false;
    }

    Option!OreDefinition getOreByID(int id) {
        Option!OreDefinition result;
        OreDefinition* thisDefinition = id in idDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    Option!OreDefinition getOreByName(string name) {
        Option!OreDefinition result;
        OreDefinition* thisDefinition = name in nameDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    /// Extremely unsafe API access.
    /// Do not use this unless you want to debug some "very cool" errors.
    OreDefinition* unsafeGetByID(int id) {
        return ultraFastAccess + id;
    }

    /// Never use this unless you like pain.
    OreDefinition* getRawPointer() {
        return ultraFastAccess;
    }

    ulong getOreCount() {
        return currentID;
    }

    void finalize() {

        // Regular safe API access.
        foreach (name, ref thisDefinition; nameDatabase) {
            // todo: do the match thing below when sqlite is added in.
            thisDefinition.id = nextID();
            thisDefinition.texturePointsIndex = TextureHandler.lookupTexturePointsIndex(
                thisDefinition.texture);
            idDatabase[thisDefinition.id] = thisDefinition;
            debugWrite(thisDefinition);
        }

        // Extremely unsafe API access.
        // Do not use this unless you want to debug some "very cool" errors.
        ultraFastAccess = cast(OreDefinition*) GC.malloc(OreDefinition.sizeof * idDatabase.length);
        foreach (i; 0 .. idDatabase.length) {
            ultraFastAccess[i] = idDatabase[cast(int) i];

            assert(ultraFastAccess[i].name == idDatabase[cast(int) i].name);
            assert(ultraFastAccess[i].id == idDatabase[cast(int) i].id);
            assert(ultraFastAccess[i].texture == idDatabase[cast(int) i].texture);
        }

    }

private: //* BEGIN INTERNAL API.

    void debugWrite(OreDefinition definition) {
        writeln("Ore " ~ definition.name ~ " at ID " ~ to!string(definition.id));
    }

    // todo: make this pull the standard IDs into an associative array from the sqlite.
    // todo: sqlite should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new ore.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
