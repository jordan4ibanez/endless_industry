module game.item_database;

import core.memory;
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

    }

}
