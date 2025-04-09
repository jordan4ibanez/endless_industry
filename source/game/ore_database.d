module game.ore_database;

import graphics.texture;

struct OreDefinition {
    string name = null;
    string texture = null;
    string minedItem = null;
    uint minedItemAmount = 0;

    ///! DO NOT USE.
}

static final const class BiomeDatabase {
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
    }

}
