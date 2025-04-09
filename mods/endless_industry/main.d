module mods.endless_industry.main;

import game.biome_database;
import game.player;
import game.tile_database;
import std.stdio;

private immutable string nameOfMod = "CubeThing";

void endlessIndustryMain() {

    //? Tiles.

    TileDefinition grass0;
    grass0.name = "grass_0";
    grass0.texture = "grass_0.png";
    TileDatabase.registerTile(grass0);

    TileDefinition grass1;
    grass1.name = "grass_1";
    grass1.texture = "grass_1.png";
    TileDatabase.registerTile(grass1);

    TileDefinition grass2;
    grass2.name = "grass_2";
    grass2.texture = "grass_2.png";
    TileDatabase.registerTile(grass2);

    //? Biomes.

    BiomeDefinition grassLands;
    grassLands.name = "grass lands";
    grassLands.groundLayerTiles = [
        "endless_industry.grass_0", "endless_industry.grass_1",
        "endless_industry.grass_2"
    ];

    TileDefinition water0;
    water0.name = "water_0";
    water0.texture = "water_0.png";
    TileDatabase.registerTile(water0);

    TileDefinition water1;
    water1.name = "water_1";
    water1.texture = "water_1.png";
    TileDatabase.registerTile(water1);

    TileDefinition water2;
    water2.name = "water_2";
    water2.texture = "water_2.png";
    TileDatabase.registerTile(water2);

    grassLands.waterLayerTiles = [
        "endless_industry.water_0", "endless_industry.water_1",
        "endless_industry.water_2"
    ];

    /*

    ? Water Corner Tiles.

    In a very specific binary order for allowing pointer arithmetic during terrain generation.
    0_0_0_0
    1_0_0_0
    0_1_0_0
    1_1_0_0
    0_0_1_0
    1_0_1_0
    0_1_1_0
    1_1_1_0
    0_0_0_1
    1_0_0_1
    0_1_0_1
    1_1_0_1
    0_0_1_1
    1_0_1_1
    0_1_1_1

    */

    string[] waterCorners = [
        "1_0_0_0",
        "0_1_0_0",
        "1_1_0_0",
        "0_0_1_0",
        "1_0_1_0",
        "0_1_1_0",
        "1_1_1_0",
        "0_0_0_1",
        "1_0_0_1",
        "0_1_0_1",
        "1_1_0_1",
        "0_0_1_1",
        "1_0_1_1",
        "0_1_1_1",
        "1_1_1_1"
    ];

    foreach (identifier; waterCorners) {

        TileDefinition aCornerTile;
        aCornerTile.name = "water_" ~ identifier;
        aCornerTile.texture = "water_" ~ identifier ~ ".png";
        TileDatabase.registerTile(aCornerTile);
    }

    grassLands.waterLayerCornerTiles = [
        "endless_industry.water_1_0_0_0",
        "endless_industry.water_0_1_0_0",
        "endless_industry.water_1_1_0_0",
        "endless_industry.water_0_0_1_0",
        "endless_industry.water_1_0_1_0",
        "endless_industry.water_0_1_1_0",
        "endless_industry.water_1_1_1_0",
        "endless_industry.water_0_0_0_1",
        "endless_industry.water_1_0_0_1",
        "endless_industry.water_0_1_0_1",
        "endless_industry.water_1_1_0_1",
        "endless_industry.water_0_0_1_1",
        "endless_industry.water_1_0_1_1",
        "endless_industry.water_0_1_1_1",
        "endless_industry.water_1_1_1_1",
    ];

    BiomeDatabase.registerBiome(grassLands);

}
