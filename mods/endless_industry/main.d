module mods.endless_industry.main;

import game.biome_database;
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

    TileDefinition water0001;
    water0001.name = "water_0_0_0_1";
    water0001.texture = "water_0_0_0_1.png";
    TileDatabase.registerTile(water0001);

    TileDefinition water0010;
    water0010.name = "water_0_0_1_0";
    water0010.texture = "water_0_0_1_0.png";
    TileDatabase.registerTile(water0010);

    TileDefinition water0011;
    water0011.name = "water_0_0_1_1";
    water0011.texture = "water_0_0_1_1.png";
    TileDatabase.registerTile(water0011);

    TileDefinition water0100;
    water0100.name = "water_0_1_0_0";
    water0100.texture = "water_0_1_0_0.png";
    TileDatabase.registerTile(water0100);

    TileDefinition water0110;
    water0110.name = "water_0_1_1_0";
    water0110.texture = "water_0_1_1_0.png";
    TileDatabase.registerTile(water0110);

    TileDefinition water1000;
    water1000.name = "water_1_0_0_0";
    water1000.texture = "water_1_0_0_0.png";
    TileDatabase.registerTile(water1000);

    TileDefinition water1001;
    water1001.name = "water_1_0_0_1";
    water1001.texture = "water_1_0_0_1.png";
    TileDatabase.registerTile(water1001);

    TileDefinition water1100;
    water1100.name = "water_1_1_0_0";
    water1100.texture = "water_1_1_0_0.png";
    TileDatabase.registerTile(water1100);

    grassLands.waterLayerTilesCorners = [
        "endless_industry.water_0_0_0_1",
        "endless_industry.water_0_0_1_0",
        "endless_industry.water_0_0_1_1",
        "endless_industry.water_0_1_0_0",
        "endless_industry.water_0_1_1_0",
        "endless_industry.water_1_0_0_0",
        "endless_industry.water_1_0_0_1",
        "endless_industry.water_1_1_0_0"
    ];

    /*
    In a very specific binary order for allowing bitshifting into an index during terrain generation.
    ! WIP

    0_0_0_1

    */

    BiomeDatabase.registerBiome(grassLands);

}
