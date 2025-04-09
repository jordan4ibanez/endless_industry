module game.ore_database;

import graphics.texture;
import optibrev;

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

    Option!OreDefinition getTileByID(int id) {
        Option!OreDefinition result;
        OreDefinition* thisDefinition = id in idDatabase;
        if (thisDefinition !is null) {
            result = result.Some(*thisDefinition);
        }
        return result;
    }

    Option!OreDefinition getTileByName(string name) {
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

}
