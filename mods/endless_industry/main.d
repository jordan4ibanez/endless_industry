module mods.endless_industry.main;

import game.biome_database;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

void endlessIndustryMain() {

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
    grassLands.name = "grass lands";
    grassLands.groundLayerTiles = [
        "endless_industry.grass", "endless_industry.dirt",
        "endless_industry.stone"
    ];

    BiomeDatabase.registerBiome(grassLands);

}
