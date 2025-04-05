module mods.cube_thing.main;

import game.biome_database;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

class CubeThingTile : TileDefinition {
    this() {
        this.modName = nameOfMod;
    }
}

class CubeThingBiome : BiomeDefinition {
    this() {
        this.modName = nameOfMod;
    }
}

void cubeThingMain() {

    //? Tiles.

    CubeThingTile stone = new CubeThingTile();
    stone.name = "stone";
    stone.texture = "default_stone.png";
    TileDatabase.registerTile(stone);

    CubeThingTile dirt = new CubeThingTile();
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";
    TileDatabase.registerTile(dirt);

    CubeThingTile grass = new CubeThingTile();
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
