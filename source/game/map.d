module game.map;

public import utility.collision_functions : CollisionAxis;
import core.memory;
import fast_noise;
import game.biome_database;
import game.tile_database;
import graphics.camera_handler;
import graphics.mesh;
import graphics.render;
import graphics.texture_handler;
import graphics.window;
import math.rect;
import math.vec2d;
import math.vec2i;
import optibrev;
import std.algorithm.comparison;
import std.conv;
import std.math.algebraic;
import std.math.rounding;
import std.random;
import std.stdio;

//! NEVER CHANGE THIS!
immutable public int CHUNK_WIDTH = 64;

struct TileData {
    int tileID = 0;
    int meshID = 0;
}

final class Chunk {
    TileData[CHUNK_WIDTH][CHUNK_WIDTH] data;
    int modelID = 0;
}

static final const class Map {
static:
private:

    Chunk[Vec2i] database;
    FNLState noise;

public: //* BEGIN PUBLIC API.

    void initialize() {
        noise.seed = 1_010_010;
    }

    void draw() {

        //? Screen draws, bottom left to top right.
        const int windowWidth = Window.getWidth();
        const int windowHeight = Window.getHeight();

        const Vec2d bottomLeft = CameraHandler.screenToWorld(0, 0);
        const Vec2d topRight = CameraHandler.screenToWorld(windowWidth, windowHeight);

        const int minX = cast(int) floor(bottomLeft.x);
        const int minY = cast(int) floor(bottomLeft.y);
        const int maxX = cast(int) floor(topRight.x);
        const int maxY = cast(int) floor(topRight.y);

        const Vec2i topLeftChunkPosition = calculateChunkAtWorldPosition(Vec2d(minX, minY));
        const Vec2i bottomRightChunkPosition = calculateChunkAtWorldPosition(Vec2d(maxX, maxY));

        Vec2i chunkID;

        const(Chunk)* thisChunk;

        import std.datetime.stopwatch;

        // auto sw = StopWatch(AutoStart.yes);

        Vec2d position;

        MeshHandler.prepareAtlasDrawing();

        foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
            foreach (yReal; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
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
        thisChunk.data[xPosInChunk][yPosInChunk].tileID = id;
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
        thisChunk.data[xPosInChunk][yPosInChunk].tileID = result.unwrap.id;
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

        const int basePositionX = chunkPosition.x * CHUNK_WIDTH;
        const int basePositionY = chunkPosition.y * CHUNK_WIDTH;

        const double waterFrequency = 0.3;
        const double waterChance = 0.7;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                import std.bitmanip;
                import std.conv;

                struct LandResult {
                    mixin(bitfields!(
                            ubyte, "left", 1,
                            ubyte, "up", 1,
                            ubyte, "right", 1,
                            ubyte, "down", 1,
                            byte, "", 4));
                }

                const double _waterCoinFlip = clamp((fnlGetNoise2D(&noise, (x + basePositionX) * waterFrequency, (
                        y + basePositionY) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0);

                if (_waterCoinFlip > waterChance) {

                    // Move the noise into the range of 0 - 1.
                    const double _selectedWaterNoise = clamp((fnlGetNoise2D(&noise, (
                            x + basePositionX) * 10, (
                            y + basePositionY) * 10) + 1.0) * 0.5, 0.0, 1.0);

                    LandResult localLand;

                    // It is literally faster to cache this calculation in the CPU than it is to check the map.
                    //? Simulate neighbors.
                    {
                        localLand.left = clamp((fnlGetNoise2D(&noise, (x + basePositionX - 1) * waterFrequency, (
                                y + basePositionY) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.up = clamp((fnlGetNoise2D(&noise, (x + basePositionX) * waterFrequency, (
                                y + basePositionY + 1) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.right = clamp((fnlGetNoise2D(&noise, (x + basePositionX + 1) * waterFrequency, (
                                y + basePositionY) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                        localLand.down = clamp((fnlGetNoise2D(&noise, (x + basePositionX) * waterFrequency, (
                                y + basePositionY - 1) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0) <= waterChance;

                    }

                    // 0 means that it's fully surrounded by water.
                    //! This probably does not work on ARM. Endian might be different.
                    if (*cast(ubyte*)&localLand == 0) {
                        const ulong _baseWaterSelection = cast(ulong) floor(
                            numberOfWaterTiles * _selectedWaterNoise);

                        // Make sure no floating point imprecision happened.
                        const ulong selectedTile = (_baseWaterSelection >= numberOfWaterTiles) ? 0
                            : _baseWaterSelection;

                        thisChunk.data[x][y].tileID = availableWaterTiles[selectedTile];
                    } else {
                        // Else, it is the edge of the water.

                        // -1 because 0's bit data is on the previous section of this if statement.
                        // So the selection has to be shifted back into 0 indexed.
                        thisChunk.data[x][y].tileID = availableWaterCornerTiles[(
                                *cast(ubyte*)(&localLand)) - 1];
                    }

                } else {
                    // Move the noise into the range of 0 - 1.
                    const double _selectedGroundNoise = clamp((fnlGetNoise2D(&noise, (
                            x + basePositionX) * 10, (
                            y + basePositionY) * 10) + 1.0) * 0.5, 0.0, 1.0);

                    const ulong _baseGroundSelection = cast(ulong) floor(
                        numberOfGroundTiles * _selectedGroundNoise);

                    // Make sure no floating point imprecision happened.
                    const ulong selectedTile = (_baseGroundSelection >= numberOfGroundTiles) ? 0
                        : _baseGroundSelection;

                    thisChunk.data[x][y].tileID = availableGroundTiles[selectedTile];
                }

            }
        }
    }

    void generateChunkMesh(ref Chunk thisChunk) {

        // Note: This is vertex and texture coordinate data interlaced together.

        const VERTEX_LENGTH = 16 * (CHUNK_WIDTH * CHUNK_WIDTH);
        const INDEX_LENGTH = 6 * (CHUNK_WIDTH * CHUNK_WIDTH);

        float* verticesANDTextureCoord = cast(float*) GC.malloc(float.sizeof * VERTEX_LENGTH);
        ulong vertAndTexIndex = 0;

        ushort* indices = cast(ushort*) GC.malloc(ushort.sizeof * INDEX_LENGTH);
        ulong indicesIndex = 0;
        ushort vertexPosCount = 0;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                const int tileID = thisChunk.data[x][(CHUNK_WIDTH - y) - 1].tileID;

                const TileDefinition* thisTilePointer = TileDatabase.unsafeGetByID(tileID);

                TexturePoints!Vec2d* tPoints = TextureHandler.getTexturePointsPointer(
                    thisTilePointer.texturePointsIndex);

                static immutable triCompletion = 1.00075;

                // Quad.

                verticesANDTextureCoord[0 + vertAndTexIndex] = x;
                verticesANDTextureCoord[1 + vertAndTexIndex] = y;
                verticesANDTextureCoord[2 + vertAndTexIndex] = tPoints.topLeft.x;
                verticesANDTextureCoord[3 + vertAndTexIndex] = tPoints.topLeft.y;

                verticesANDTextureCoord[4 + vertAndTexIndex] = x;
                verticesANDTextureCoord[5 + vertAndTexIndex] = y + triCompletion;
                verticesANDTextureCoord[6 + vertAndTexIndex] = tPoints.bottomLeft.x;
                verticesANDTextureCoord[7 + vertAndTexIndex] = tPoints.bottomLeft.y;

                verticesANDTextureCoord[8 + vertAndTexIndex] = x + triCompletion;
                verticesANDTextureCoord[9 + vertAndTexIndex] = y + triCompletion;
                verticesANDTextureCoord[10 + vertAndTexIndex] = tPoints.bottomRight.x;
                verticesANDTextureCoord[11 + vertAndTexIndex] = tPoints.bottomRight.y;

                verticesANDTextureCoord[12 + vertAndTexIndex] = x + triCompletion;
                verticesANDTextureCoord[13 + vertAndTexIndex] = y;
                verticesANDTextureCoord[14 + vertAndTexIndex] = tPoints.topRight.x;
                verticesANDTextureCoord[15 + vertAndTexIndex] = tPoints.topRight.y;

                vertAndTexIndex += 16;

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

        writeln(vertexPosCount);

        thisChunk.modelID = MeshHandler.generate(verticesANDTextureCoord, VERTEX_LENGTH, indices);

        GC.free(verticesANDTextureCoord);
        GC.free(indices);

    }

}
