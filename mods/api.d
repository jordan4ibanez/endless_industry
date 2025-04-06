module mods.api;

import game.biome_database;
import game.tile_database;

// Do not modify the autos. :)

//# =-AUTO IMPORT BEGIN-=
import mods.cube_thing.main;
//# =-AUTO IMPORT END-=

static final const class Api {
static:
private:

public: //* BEGIN PUBLIC API.

    void initialize() {
        cubeThingMain();

        finalize();
    }

private: //* BEGIN INTERNAL API.

    void finalize() {
        TileDatabase.finalize();
        BiomeDatabase.finalize();
    }

}
