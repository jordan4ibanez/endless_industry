module mods.api;

import game.biome_database;
import game.tile_database;

// Do not modify the autos. :)
// These are part of a preprocessor I made to auto bake your mod into the game itself.
// I also probably wouldn't duplicate these comments unless you like seeing the file disappear lol.

//# =-AUTO IMPORT BEGIN-=
import mods.cube_thing.main;

//# =-AUTO IMPORT END-=

//# =-AUTO FUNCTION BEGIN-=
void deployMainFunctions() {
    cubeThingMain();
}
//# =-AUTO FUNCTION END-=

static final const class Api {
static:
private:

public: //* BEGIN PUBLIC API.

    void initialize() {
        deployMainFunctions();

        finalize();
    }

private: //* BEGIN INTERNAL API.

    void finalize() {
        TileDatabase.finalize();
        BiomeDatabase.finalize();
    }

}
