module game.item_database;

import core.memory;
import graphics.texture;
import optibrev;
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

}
