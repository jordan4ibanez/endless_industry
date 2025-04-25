module game.item_database;

import core.memory;

struct ItemDefinition {
    string name = null;
    string texture = null;

    //! DO NOT USE.
    int id = -1;
    ulong texturePointsIndex = 0;
}

struct Item {
    int id = 0;
    int count = 0;
}

static final const class ItemHandler {
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

    void registerItem(const string name, Item item) {

    }

}
