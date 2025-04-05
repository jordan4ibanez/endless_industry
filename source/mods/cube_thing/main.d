module mods.cube_thing.main;

import game.biome_database;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

class CubeThingBiome : BiomeDefinition {
    this() {
        this.modName = nameOfMod;
    }
}

void cubeThingMain() {

    //? Tiles.

    TileDefinition stone;
    stone.modName = nameOfMod;
    stone.name = "stone";
    stone.texture = "default_stone.png";
    TileDatabase.registerTile(stone);

    TileDefinition dirt;
    dirt.modName = nameOfMod;
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";
    TileDatabase.registerTile(dirt);

    TileDefinition grass;
    grass.modName = nameOfMod;
    grass.name = "grass";
    grass.texture = "default_grass.png";
    TileDatabase.registerTile(grass);

    //? Biomes.

    CubeThingBiome grassLands = new CubeThingBiome();
    grassLands.name = "grass lands";
    grassLands.grassLayer = "grass";
    grassLands.dirtLayer = "dirt";
    grassLands.stoneLayer = "stone";

    BiomeDatabase.registerBiome(grassLands);

}
