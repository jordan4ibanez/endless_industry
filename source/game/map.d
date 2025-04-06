module game.map;

public import utility.collision_functions : CollisionAxis;
import core.memory;
import fast_noise;
import game.biome_database;
import game.tile_database;
import graphics.camera_handler;
import graphics.model;
import graphics.render;
import graphics.texture_handler;
import graphics.window;
import math.rect;
import math.vec2d;
import math.vec2i;
import std.algorithm.comparison;
import std.conv;
import std.math.algebraic;
import std.math.rounding;
import std.random;
import std.stdio;
import utility.option;

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
        int windowWidth = Window.getWidth();
        int windowHeight = Window.getHeight();

        Vec2d bottomLeft = CameraHandler.screenToWorld(0, 0);
        Vec2d topRight = CameraHandler.screenToWorld(windowWidth, windowHeight);

        int minX = cast(int) floor(bottomLeft.x);
        int minY = cast(int) floor(bottomLeft.y);
        int maxX = cast(int) floor(topRight.x);
        int maxY = cast(int) floor(topRight.y);

        Vec2i topLeftChunkPosition = calculateChunkAtWorldPosition(Vec2d(minX, minY));
        Vec2i bottomRightChunkPosition = calculateChunkAtWorldPosition(Vec2d(maxX, maxY));

        //? This needs to be dynamic so it can support 8k+ displays.
        //? I do not have an 8k display to test this though. :(
        //* TODO: IN THE FUTURE: Preallocate this based on the biggest display. It will save GC resources.

        foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
            foreach (yReal; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
                Vec2i chunkID = Vec2i(xReal, yReal);

                Chunk* thisChunk = chunkID in database;

                // Any chunks that don't exist get drawn as a blank chunk grid.
                if (thisChunk is null) {
                    Render.rectangleLines(Vec2d(xReal * CHUNK_WIDTH, (yReal + 1) * CHUNK_WIDTH),
                        Vec2d(CHUNK_WIDTH, CHUNK_WIDTH), Colors.WHITE, 0.75);
                } else {
                    ModelHandler.draw(Vec2d(xReal * CHUNK_WIDTH, (yReal + 1) * CHUNK_WIDTH), thisChunk
                            .modelID);
                }
            }
        }
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
    }

    void generateChunkData(Vec2i chunkPosition, ref Chunk thisChunk) {

        const int numberOfBiomes = BiomeDatabase.getNumberOfBiomes();
        const BiomeDefinition* thisBiome = BiomeDatabase.unsafeGetByID(0);

        const int* availableGroundTiles = thisBiome.groundLayerIDs.ptr;
        const ulong numberOfGroundTiles = thisBiome.groundLayerIDs.length;

        const int* availableWaterTiles = thisBiome.waterLayerIDs.ptr;
        const ulong numberOfWaterTiles = thisBiome.waterLayerIDs.length;

        const int basePositionX = chunkPosition.x * CHUNK_WIDTH;
        const int basePositionY = chunkPosition.y * CHUNK_WIDTH;

        const double waterFrequency = 1.0;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                const double _waterCoinFlip = clamp((fnlGetNoise2D(&noise, (x + basePositionX) * waterFrequency, (
                        y + basePositionY) * waterFrequency) + 1.0) * 0.5, 0.0, 1.0);

                if (_waterCoinFlip > 0.5) {

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

        const VERTEX_LENGTH = 18 * (CHUNK_WIDTH * CHUNK_WIDTH);

        float* vertices = cast(float*) GC.malloc(float.sizeof * 18 * (CHUNK_WIDTH * CHUNK_WIDTH));
        ulong vertexIndex = 0;
        float* textureCoordinates = cast(float*) GC.malloc(
            float.sizeof * 12 * (CHUNK_WIDTH * CHUNK_WIDTH));
        ulong textureIndex = 0;

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                const int tileID = thisChunk.data[x][(CHUNK_WIDTH - y) - 1].tileID;

                const TileDefinition* thisTilePointer = TileDatabase.unsafeGetByID(tileID);

                TexturePoints!Vec2d* tPoints = TextureHandler.getTexturePointsPointer(
                    thisTilePointer.texturePointsIndex);

                // Tri 1.
                vertices[0 + vertexIndex] = x;
                vertices[1 + vertexIndex] = y;
                vertices[2 + vertexIndex] = 0;

                vertices[3 + vertexIndex] = x;
                vertices[4 + vertexIndex] = y + 1;
                vertices[5 + vertexIndex] = 0;

                vertices[6 + vertexIndex] = x + 1;
                vertices[7 + vertexIndex] = y + 1;
                vertices[8 + vertexIndex] = 0;

                // Tri 2.

                vertices[9 + vertexIndex] = x + 1;
                vertices[10 + vertexIndex] = y + 1;
                vertices[11 + vertexIndex] = 0;

                vertices[12 + vertexIndex] = x + 1;
                vertices[13 + vertexIndex] = y;
                vertices[14 + vertexIndex] = 0;

                vertices[15 + vertexIndex] = x;
                vertices[16 + vertexIndex] = y;
                vertices[17 + vertexIndex] = 0;

                // Tri 1.

                textureCoordinates[0 + textureIndex] = tPoints.topLeft.x;
                textureCoordinates[1 + textureIndex] = tPoints.topLeft.y;

                textureCoordinates[2 + textureIndex] = tPoints.bottomLeft.x;
                textureCoordinates[3 + textureIndex] = tPoints.bottomLeft.y;

                textureCoordinates[4 + textureIndex] = tPoints.bottomRight.x;
                textureCoordinates[5 + textureIndex] = tPoints.bottomRight.y;

                // Tri 2.

                textureCoordinates[6 + textureIndex] = tPoints.bottomRight.x;
                textureCoordinates[7 + textureIndex] = tPoints.bottomRight.y;

                textureCoordinates[8 + textureIndex] = tPoints.topRight.x;
                textureCoordinates[9 + textureIndex] = tPoints.topRight.y;

                textureCoordinates[10 + textureIndex] = tPoints.topLeft.x;
                textureCoordinates[11 + textureIndex] = tPoints.topLeft.y;

                vertexIndex += 18;

                textureIndex += 12;

            }
        }

        thisChunk.modelID = ModelHandler.generate(vertices, VERTEX_LENGTH, textureCoordinates);

        GC.free(vertices);
        GC.free(textureCoordinates);

    }

}
