module mods.cube_thing.main;

import game.biome_database;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

class CubeThingBlock : TileDefinition {
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

    //? Blocks.

    CubeThingBlock stone = new CubeThingBlock();
    stone.name = "stone";
    stone.texture = "default_stone.png";
    TileDatabase.registerBlock(stone);

    CubeThingBlock dirt = new CubeThingBlock();
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";
    TileDatabase.registerBlock(dirt);

    CubeThingBlock grass = new CubeThingBlock();
    grass.name = "grass";
    grass.texture = "default_grass.png";
    TileDatabase.registerBlock(grass);

    //? Biomes.

    CubeThingBiome grassLands = new CubeThingBiome();
    grassLands.name = "grass lands";
    grassLands.grassLayer = "grass";
    grassLands.dirtLayer = "dirt";
    grassLands.stoneLayer = "stone";

    BiomeDatabase.registerBiome(grassLands);

}
