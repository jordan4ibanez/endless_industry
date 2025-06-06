module game.map;

public import utility.collision_functions : CollisionAxis;
import core.memory;
import fast_noise;
import game.biome_database;
import game.ore_database;
import game.player;
import game.tile_database;
import graphics.camera;
import graphics.mesh;
import graphics.render;
import graphics.texture;
import graphics.window;
import math.rect;
import math.vec2d;
import math.vec2i;
import utility.option;
import std.algorithm.comparison;
import std.bitmanip;
import std.conv;
import std.math.algebraic;
import std.math.rounding;
import std.random;
import std.stdio;
import utility.save;

//! NEVER CHANGE THIS!
immutable public int CHUNK_WIDTH = 64;

struct TileData {

    int groundTileID = 0;

    int oreID = -1;
    int oreAmount = 0;

    int entityID = 0;
    Vec2i entityOrigin;
}

final class Chunk {
    TileData[CHUNK_WIDTH][CHUNK_WIDTH] data;
    int modelID = 0;
    // void* entitiesInChunk = null;
}

static final const class Map {
static:
private:

    Chunk[Vec2i] database;
    FNLState noise;
    double saveTimer = 0;
    double saveInterval = 30.0;

public: //* BEGIN PUBLIC API.

    void initialize() {
        noise.seed = 958_737;
        Save.open("world");

        writeln("Loading map " ~ "world");

        Save.initialLoadAllChunksInDatabase();

        Option!Vec2d playerPosition = Save.readPlayerPosition();
        if (playerPosition.isSome) {
            writeln("Loaded player position ", playerPosition.unwrap);
            Player.setPosition(playerPosition.unwrap());
        }
    }

    void terminate() {
        Save.writePlayerPosition(Player.getPosition());

        writeln("Saving map " ~ "world" ~ ".");

        mapSave();

        Save.close();
    }

    void onTick(double delta) {
        saveTimer += delta;
        if (saveTimer >= saveInterval) {
            saveTimer -= saveInterval;
            writeln("Autosaving map.");
            mapSave();
        }
    }

    void mapSave() {
        Save.prepareWriteMapChunk();
        foreach (key, value; database) {
            Save.writeMapChunk(key, value);
        }
        Save.completeWriteMapChunk();
    }

    /// This is a specialty function which works with Save to reload the map.
    void receiveMapChunkFromDatabase(Vec2i chunkID, Chunk thisChunk) {
        thisChunk.modelID = 0;
        generateChunkMesh(thisChunk);
        database[chunkID] = thisChunk;
        // writeln("loaded ", chunkID);
    }

    void draw() {

        //? Screen draws, bottom left to top right.
        const int windowWidth = Window.getWidth();
        const int windowHeight = Window.getHeight();

        const Vec2d topLeft = CameraHandler.screenToWorld(0, 0);
        const Vec2d bottomRight = CameraHandler.screenToWorld(windowWidth, windowHeight);

        const int minX = cast(int) floor(topLeft.x);
        const int minY = cast(int) floor(topLeft.y);
        const int maxX = cast(int) floor(bottomRight.x);
        const int maxY = cast(int) floor(bottomRight.y);

        const Vec2i topLeftChunkPosition = calculateChunkAtWorldPosition(Vec2d(minX, minY));
        const Vec2i bottomRightChunkPosition = calculateChunkAtWorldPosition(Vec2d(maxX, maxY));

        Vec2i chunkID;

        const(Chunk)* thisChunk;

        import std.datetime.stopwatch;

        // auto sw = StopWatch(AutoStart.yes);

        Vec2d position;

        MeshHandler.prepareAtlasDrawing();

        foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
            for (int yReal = topLeftChunkPosition.y; yReal >= bottomRightChunkPosition.y;
                yReal--) {
                chunkID.x = xReal;
                chunkID.y = yReal;

                thisChunk = chunkID in database;

                // Any chunks that don't exist get drawn as a blank chunk grid.
                // if (thisChunk is null) {
                //     Render.rectangleLines(Vec2d(xReal * CHUNK_WIDTH, (yReal + 1) * CHUNK_WIDTH),
                //         Vec2d(CHUNK_WIDTH, CHUNK_WIDTH), Colors.WHITE, 0.75);
                // } 

                if (thisChunk is null) {
                    continue;
                }

                position.x = xReal * CHUNK_WIDTH;
                position.y = (yReal + 1) * CHUNK_WIDTH;

                MeshHandler.draw(position, thisChunk
                        .modelID);

            }
        }

        // long blah = sw.peek().total!"hnsecs";

        // writeln("total: ", blah / 10.0, " usecs");
    }

    Vec2i calculateChunkAtWorldPosition(Vec2d position) {
        return Vec2i(cast(int) floor(position.x / CHUNK_WIDTH), cast(int) floor(
                position.y / CHUNK_WIDTH));
    }

    int getXInChunk(double x) {
        int result = cast(int) floor(x % CHUNK_WIDTH);
        // Account for negatives.
        if (result < 0) {
            result += CHUNK_WIDTH;
        }
        return result;
    }

    int getYInChunk(double y) {
        int result = cast(int) floor(y % CHUNK_WIDTH);
        // Account for negatives.
        if (result < 0) {
            result += CHUNK_WIDTH;
        }
        return result;
    }

    ///! This can be extremely expensive!
    /// todo: This needs a bulk counterpart!
    TileData getTileAtWorldPosition(Vec2d position) {
        Vec2i chunkID = calculateChunkAtWorldPosition(position);

        if (chunkID !in database) {
            return TileData();
        }

        int xPosInChunk = getXInChunk(position.x);
        int yPosInChunk = getYInChunk(position.y);

        return database[chunkID].data[xPosInChunk][yPosInChunk];
    }

    void setTileAtWorldPositionByID(Vec2d position, int id) {
        if (!TileDatabase.hasTileID(id)) {
            throw new Error("Cannot set to tile ID " ~ to!string(id) ~ ", ID does not exist.");
        }
        Vec2i chunkID = calculateChunkAtWorldPosition(position);
        if (chunkID !in database) {
            // todo: maybe unload the chunk after?
            loadChunk(chunkID);
        }
        int xPosInChunk = getXInChunk(position.x);
        int yPosInChunk = getYInChunk(position.y);
        Chunk* thisChunk = chunkID in database;
        if (thisChunk is null) {
            throw new Error("Null chunk! How is this even possible? It was loaded!");
        }
        thisChunk.data[xPosInChunk][yPosInChunk].groundTileID = id;
        generateChunkMesh(*thisChunk);
    }

    void setTileAtWorldPositionByName(Vec2d position, string name) {

        Vec2i chunkID = calculateChunkAtWorldPosition(position);

        if (chunkID !in database) {
            // todo: maybe unload the chunk after?
            loadChunk(chunkID);
        }
        int xPosInChunk = getXInChunk(position.x);
        int yPosInChunk = getYInChunk(position.y);
        Option!TileDefinition result = TileDatabase.getTileByName(name);
        if (result.isNone) {
            throw new Error("Cannot set to tile " ~ name ~ ", does not exist.");
        }
        Chunk* thisChunk = chunkID in database;
        if (thisChunk is null) {
            throw new Error("Null chunk! How is this even possible? It was loaded!");
        }
        thisChunk.data[xPosInChunk][yPosInChunk].groundTileID = result.unwrap.id;
        generateChunkMesh(*thisChunk);
    }

    void worldLoad(Vec2i currentPlayerChunk) {

        const int worldLoadDistance = 7;

        foreach (x; currentPlayerChunk.x - worldLoadDistance .. currentPlayerChunk.x + worldLoadDistance + 1) {
            foreach (y; currentPlayerChunk.y - worldLoadDistance .. currentPlayerChunk.y + worldLoadDistance + 1) {
                // writeln("loading chunk ", x, " ", y);
                loadChunk(Vec2i(x, y));
            }
        }

        // This can get very laggy if old chunks are not unloaded. :)
        // unloadOldChunks(currentPlayerChunk);
    }

private: //* BEGIN INTERNAL API.

    // void unloadOldChunks(int currentPlayerChunk) {

    //     // todo: save the chunks to sqlite.

    //     int[] keys = [] ~ database.keys;

    //     foreach (int key; keys) {
    //         if (abs(key - currentPlayerChunk) > 1) {
    //             database.remove(key);
    //             // todo: save the chunks to sqlite.
    //             // writeln("deleted: " ~ to!string(key));
    //         }
    //     }
    // }

    void loadChunk(Vec2i chunkPosition) {
        // Already loaded.
        if (chunkPosition in database) {
            return;
        }
        // todo: try to read from sqlite.
        Chunk newChunk = new Chunk();
        generateChunkData(chunkPosition, newChunk);
        generateChunkMesh(newChunk);

        database[chunkPosition] = newChunk;

        database = database.rehash();
    }

    void generateChunkData(Vec2i chunkPosition, ref Chunk thisChunk) {

        const int numberOfBiomes = BiomeDatabase.getNumberOfBiomes();
        const BiomeDefinition* thisBiome = BiomeDatabase.unsafeGetByID(0);

        const int* availableGroundTiles = thisBiome.groundLayerIDs.ptr;
        const ulong numberOfGroundTiles = thisBiome.groundLayerIDs.length;

        const int* availableWaterTiles = thisBiome.waterLayerIDs.ptr;
        const ulong numberOfWaterTiles = thisBiome.waterLayerIDs.length;

        const int* availableWaterCornerTiles = thisBiome.waterLayerCornerIDs.ptr;
        const ulong numberOfWaterCornerTiles = thisBiome.waterLayerCornerIDs.length;

        const OreDefinition* availableOres = OreDatabase.getRawPointer();
        const ulong oreCount = OreDatabase.getOreCount();

        const int basePositionX = chunkPosition.x * CHUNK_WIDTH;
        const int basePositionY = chunkPosition.y * CHUNK_WIDTH;

        // Water parameters.
        const double waterScale = 0.3;
        const double waterChance = 0.7;

        // Land parameters.
        const double landScale = 20.0;

        // Ore scale is the size of the ore patches in general.
        // The higher this is
        const double oreScale = 1.0;
        const double oreChance = 0.05;
        // Ore patch scale is the size of the individual ores in the patch.
        // The smaller this number, the patchier the patches will be.
        const double orePatchScale = 0.5;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                const int realWorldX = x + basePositionX;
                const int realWorldY = y + basePositionY;

                struct LandResult {
                    mixin(bitfields!(
                            ubyte, "left", 1,
                            ubyte, "up", 1,
                            ubyte, "right", 1,
                            ubyte, "down", 1,
                            byte, "", 4));
                }

                const double _waterCoinFlip = clamp((fnlGetNoise2D(&noise, realWorldX * waterScale,
                        realWorldY * waterScale) + 1.0) * 0.5, 0.0, 1.0);

                //? This is water.
                if (_waterCoinFlip > waterChance) {

                    // Move the noise into the range of 0 - 1.
                    const double _selectedWaterNoise = clamp((fnlGetNoise2D(&noise, realWorldX * 10,
                            realWorldY * 10) + 1.0) * 0.5, 0.0, 1.0);

                    LandResult localLand;

                    // It is literally faster to cache this calculation in the CPU than it is to check the map.
                    //? Simulate neighbors.
                    {
                        localLand.left = clamp((fnlGetNoise2D(&noise, (realWorldX - 1) * waterScale,
                                realWorldY * waterScale) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.up = clamp((fnlGetNoise2D(&noise, realWorldX * waterScale, (
                                realWorldY + 1) * waterScale) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.right = clamp((fnlGetNoise2D(&noise, (realWorldX + 1) * waterScale,
                                realWorldY * waterScale) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.down = clamp((fnlGetNoise2D(&noise, realWorldX * waterScale, (
                                realWorldY - 1) * waterScale) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                    }

                    // 0 means that it's fully surrounded by water.
                    //! This probably does not work on ARM. Endian might be different.
                    if (*cast(ubyte*)&localLand == 0) {
                        const ulong _baseWaterSelection = cast(ulong) floor(
                            numberOfWaterTiles * _selectedWaterNoise);

                        // Make sure no floating point imprecision happened.
                        const ulong selectedTile = (_baseWaterSelection >= numberOfWaterTiles) ? 0
                            : _baseWaterSelection;

                        thisChunk.data[x][y].groundTileID = availableWaterTiles[selectedTile];
                    } else {
                        // Else, it is the edge of the water.

                        // -1 because 0's bit data is on the previous section of this if statement.
                        // So the selection has to be shifted back into 0 indexed.
                        thisChunk.data[x][y].groundTileID = availableWaterCornerTiles[(
                                *cast(ubyte*)(&localLand)) - 1];
                    }

                } else {
                    //? This is land.

                    // So first the ground tile.
                    {
                        // Move the noise into the range of 0 - 1.
                        const double _selectedGroundNoise = clamp((fnlGetNoise2D(&noise, realWorldX * landScale,
                                realWorldY * landScale) + 1.0) * 0.5, 0.0, 1.0);

                        const ulong _baseGroundSelection = cast(ulong) floor(
                            numberOfGroundTiles * _selectedGroundNoise);

                        // Make sure no floating point imprecision happened.
                        const ulong selectedTile = (_baseGroundSelection >= numberOfGroundTiles) ? 0
                            : _baseGroundSelection;

                        thisChunk.data[x][y].groundTileID = availableGroundTiles[selectedTile];
                    }
                    // Next, let's calculate if this is an ore.
                    {

                        const double _oreCoinFlip = clamp((fnlGetNoise2D(&noise, realWorldX * oreScale,
                                realWorldY * oreScale) + 1.0) * 0.5, 0.0, 1.0);

                        if (_oreCoinFlip < oreChance) {
                            // So this tile is an ore. Which one is it?

                            const double _oreSelectionNoise = clamp((fnlGetNoise2D(&noise, realWorldX *
                                    orePatchScale, realWorldY * orePatchScale) + 1.0) * 0.5, 0.0, 1.0);

                            const ulong _baseOreSelection = cast(ulong) floor(
                                oreCount * _oreSelectionNoise);

                            // Make sure no floating point imprecision happened.
                            const ulong selectedOre = (_baseOreSelection >= oreCount) ? 0
                                : _baseOreSelection;

                            thisChunk.data[x][y].oreID = availableOres[selectedOre].id;

                        }
                    }
                }

            }
        }
    }

    void generateChunkMesh(ref Chunk thisChunk) {

        // Note: This is vertex and texture coordinate data interlaced together.

        const VERTEX_LENGTH = 8 * (CHUNK_WIDTH * CHUNK_WIDTH);
        const INDEX_LENGTH = 6 * (CHUNK_WIDTH * CHUNK_WIDTH);

        float* vertices = cast(float*) GC.malloc(float.sizeof * VERTEX_LENGTH);
        float* textureCoords = cast(float*) GC.malloc(float.sizeof * VERTEX_LENGTH);
        float* texCoords2 = cast(float*) GC.malloc(float.sizeof * VERTEX_LENGTH);

        ulong index = 0;

        ushort* indices = cast(ushort*) GC.malloc(ushort.sizeof * INDEX_LENGTH);
        ulong indicesIndex = 0;
        ushort vertexPosCount = 0;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                TileData thisData = thisChunk.data[x][(CHUNK_WIDTH - y) - 1];

                const int tileID = thisData.groundTileID;
                const TileDefinition* thisTilePointer = TileDatabase.unsafeGetByID(tileID);
                TexturePoints!Vec2d* tPoints = TextureHandler.getTexturePointsPointer(
                    thisTilePointer.texturePointsIndex);

                // Ore is a bit special. Handled delicately.
                const int oreID = thisData.oreID;
                TexturePoints!Vec2d* oreTPoints;
                if (oreID < 0) {
                    oreTPoints = TextureHandler.getNothing();
                } else {
                    const OreDefinition* thisOreDefinitionPointer = OreDatabase.unsafeGetByID(
                        oreID);
                    oreTPoints = TextureHandler.getTexturePointsPointer(
                        thisOreDefinitionPointer.texturePointsIndex);
                }

                static immutable double precisionAdjustment = 0.00001;

                // Quad.

                vertices[0 + index] = x;
                vertices[1 + index] = y;
                vertices[2 + index] = x;
                vertices[3 + index] = y + 1.0 + precisionAdjustment;
                vertices[4 + index] = x + 1.0 + precisionAdjustment;
                vertices[5 + index] = y + 1.0 + precisionAdjustment;
                vertices[6 + index] = x + 1.0 + precisionAdjustment;
                vertices[7 + index] = y;

                // Texturing (ground layer).
                textureCoords[0 + index] = tPoints.topLeft.x + precisionAdjustment;
                textureCoords[1 + index] = tPoints.topLeft.y + precisionAdjustment;
                textureCoords[2 + index] = tPoints.bottomLeft.x + precisionAdjustment;
                textureCoords[3 + index] = tPoints.bottomLeft.y - precisionAdjustment;
                textureCoords[4 + index] = tPoints.bottomRight.x - precisionAdjustment;
                textureCoords[5 + index] = tPoints.bottomRight.y - precisionAdjustment;
                textureCoords[6 + index] = tPoints.topRight.x - precisionAdjustment;
                textureCoords[7 + index] = tPoints.topRight.y + precisionAdjustment;

                // Texturing (ore layer).
                texCoords2[0 + index] = oreTPoints.topLeft.x + precisionAdjustment;
                texCoords2[1 + index] = oreTPoints.topLeft.y + precisionAdjustment;
                texCoords2[2 + index] = oreTPoints.bottomLeft.x + precisionAdjustment;
                texCoords2[3 + index] = oreTPoints.bottomLeft.y - precisionAdjustment;
                texCoords2[4 + index] = oreTPoints.bottomRight.x - precisionAdjustment;
                texCoords2[5 + index] = oreTPoints.bottomRight.y - precisionAdjustment;
                texCoords2[6 + index] = oreTPoints.topRight.x - precisionAdjustment;
                texCoords2[7 + index] = oreTPoints.topRight.y + precisionAdjustment;

                index += 8;

                // Indices.

                indices[0 + indicesIndex] = cast(ushort)(0 + vertexPosCount);
                indices[1 + indicesIndex] = cast(ushort)(1 + vertexPosCount);
                indices[2 + indicesIndex] = cast(ushort)(2 + vertexPosCount);
                indices[3 + indicesIndex] = cast(ushort)(2 + vertexPosCount);
                indices[4 + indicesIndex] = cast(ushort)(3 + vertexPosCount);
                indices[5 + indicesIndex] = cast(ushort)(0 + vertexPosCount);

                vertexPosCount += 4;

                indicesIndex += 6;

            }
        }

        thisChunk.modelID = MeshHandler.generate(vertices, VERTEX_LENGTH, textureCoords, texCoords2, indices);

        GC.free(vertices);
        GC.free(textureCoords);
        GC.free(texCoords2);
        GC.free(indices);

    }

}
