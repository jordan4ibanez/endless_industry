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
        "endless:grass", "endless:dirt", "endless:stone"
    ];

    BiomeDatabase.registerBiome(grassLands);

}
