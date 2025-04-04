module mods.api;

import game.biome_database;
import game.tile_database;
import mods.cube_thing.main;

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
