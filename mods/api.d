module mods.api;

import game.biome_database;
import game.ore_database;
import game.player;
import game.tile_database;

//? Do not modify the autos. :)
//? These are part of a preprocessor I made to auto bake your mod into the game itself.
//? I also probably wouldn't duplicate these comments unless you like seeing the file disappear lol.

//# =-AUTO IMPORT BEGIN-=
import mods.endless_industry.main;
import mods.test_mod.main;

//# =-AUTO IMPORT END-=

//# =-AUTO FUNCTION BEGIN-=
private void deployMainFunctions() {
    setModName("endless_industry");
    endlessIndustryMain();
    setModName("test_mod");
    testModMain();
}
//# =-AUTO FUNCTION END-=

//? End the note about modifying the autos.

// This is so you don't have to prefix your mods. :D
private void setModName(string modName) {
    TileDatabase.setModName(modName);
    OreDatabase.setModName(modName);
    BiomeDatabase.setModName(modName);
}

static final const class Api {
static:
private:

    bool finalized = false;

public: //* BEGIN PUBLIC API.

    /// This is automation, do not use this in your mods. You will cause an error.
    void initialize() {
        deployMainFunctions();

        finalize();
    }

private: //* BEGIN INTERNAL API.

    void finalize() {
        if (finalized) {
            throw new Error("Do not run finalize in your mods.");
        }
        TileDatabase.finalize();
        OreDatabase.finalize();
        BiomeDatabase.finalize();
        Player.finalize();
        finalized = true;
    }

}
