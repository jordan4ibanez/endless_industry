module mods.the_mill.main;

import game.biome_database;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

void theMillMain() {

    //? Tiles.

    TileDefinition stone;
    stone.name = "stone";
    stone.texture = "default_stone.png";
    TileDatabase.registerTile(stone);

    TileDefinition dirt;
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";
    TileDatabase.registerTile(dirt);

    TileDefinition grass;
    grass.name = "grass";
    grass.texture = "default_grass.png";
    TileDatabase.registerTile(grass);

    //? Biomes.

    BiomeDefinition grassLands;
    grassLands.modName = "the_mill";
    grassLands.name = "grass lands";
    grassLands.groundLayerTiles = ["grass", "dirt", "stone"];

    BiomeDatabase.registerBiome(grassLands);

}
