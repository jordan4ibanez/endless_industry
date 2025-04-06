module mods.api;

import game.biome_database;
import game.tile_database;

// Do not modify the autos. :)

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
