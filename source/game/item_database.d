module game.item_database;

import core.memory;
import graphics.texture;
import optibrev;
import std.conv;
import std.stdio;
import std.string;

struct ItemDefinition {
package:
    int id = -1;
    ulong texturePointsIndex = 0;

public:
    string name = null;
    string texture = null;
}

struct Item {
    int id = 0;
    int count = 0;
}

static final const class ItemDatabase {
static:
private:

    string modName = null;

    // Faster access based on ID or name.
    ItemDefinition[string] nameDatabase;
    ItemDefinition[int] idDatabase;

    // Insanely fast unsafe access based on ID alone from pointer arithmetic.
    // Do not use this unless you want to debug some "very cool" errors.
    ItemDefinition* ultraFastAccess;

    int currentID = 0;

public:

    ///! This is not to be used. Only for the mod API automation.
    void __setModName(string modName) {
        this.modName = modName;
    }

    void registerItem(ItemDefinition newItem) {
        if (newItem.name.empty()) {
            throw new Error("Name for item is null.");
        }

        if (newItem.name in nameDatabase) {
            throw new Error("Trying to overwrite item " ~ newItem.name);
        }

        if (newItem.texture.empty()) {
            throw new Error("Texture is null for item " ~ newItem.name);
        }

        if (!TextureHandler.hasTexture(newItem.texture)) {
            throw new Error(
                "Texture " ~ newItem.texture ~ " for item " ~ newItem.name ~ " does not exist");
        }

        // Now inject the modname prefix into the item name.
        newItem.name = modName ~ "." ~ newItem.name;

        nameDatabase[newItem.name] = newItem;
    }

    bool hasItemID(int id) {
        if (id in idDatabase) {
            return true;
        }
        return false;
    }

    bool hasItemName(string name) {
        if (name in nameDatabase) {
            return true;
        }
        return false;
    }

    Option!ItemDefinition getItemByID(int id) {
        Option!ItemDefinition result;
        ItemDefinition* thisDefinition = id in idDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    Option!ItemDefinition getItemByName(string name) {
        Option!ItemDefinition result;
        ItemDefinition* thisDefinition = name in nameDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    /// Extremely unsafe API access.
    /// Do not use this unless you want to debug some "very cool" errors.
    ItemDefinition* unsafeGetByID(int id) {
        return ultraFastAccess + id;
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
        ultraFastAccess = cast(ItemDefinition*) GC.malloc(ItemDefinition.sizeof * idDatabase.length);
        foreach (i; 0 .. idDatabase.length) {
            ultraFastAccess[i] = idDatabase[cast(int) i];

            assert(ultraFastAccess[i].name == idDatabase[cast(int) i].name);
            assert(ultraFastAccess[i].id == idDatabase[cast(int) i].id);
            assert(ultraFastAccess[i].texture == idDatabase[cast(int) i].texture);
        }

    }

private: //* BEGIN INTERNAL API.

    void debugWrite(ItemDefinition definition) {
        writeln("Item " ~ definition.name ~ " at ID " ~ to!string(definition.id));
    }

    // todo: make this pull the standard IDs into an associative array from the sqlite.
    // todo: sqlite should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new item.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
