module game.map;

public import utility.collision_functions : CollisionAxis;
import core.memory;
import fast_noise;
import game.biome_database;
import game.tile_database;
import graphics.camera_handler;
import graphics.render;
import graphics.texture_handler;
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
import utility.window;

//! NEVER CHANGE THIS!
immutable public int CHUNK_WIDTH = 64;

struct ChunkData {
    int tileID = 0;
    int meshID = 0;
}

final class Chunk {
    ChunkData[CHUNK_WIDTH][CHUNK_WIDTH] data;
}

static final const class Map {
static:
private:

    Chunk[Vec2i] database;
    FNLState noise;
    // Vec2d[] debugDrawPoints = [];
    double gravity = 20.0;

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
        Chunk*[][] data = new Chunk*[][](
            abs(bottomRightChunkPosition.x - topLeftChunkPosition.x) + 1,
            abs(bottomRightChunkPosition.y - topLeftChunkPosition.y) + 1);

        ulong chunkCount = 0;

        // Jam the pointers into the local 2d array for faster access.
        foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
            foreach (yReal; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
                int xInArray = xReal - topLeftChunkPosition.x;
                int yInArray = yReal - topLeftChunkPosition.y;

                Vec2i chunkID = Vec2i(xReal, yReal);

                Chunk* thisChunk = chunkID in database;

                if (thisChunk is null) {
                    continue;
                }

                chunkCount++;

                data[xInArray][yInArray] = thisChunk;
            }
        }

        // Any chunks that don't exist get drawn as a blank chunk grid.
        foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
            foreach (yReal; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
                int xInArray = xReal - topLeftChunkPosition.x;
                int yInArray = yReal - topLeftChunkPosition.y;

                if (data[xInArray][yInArray] is null) {
                    Render.rectangleLines(Vec2d(xReal * CHUNK_WIDTH, (yReal + 1) * CHUNK_WIDTH),
                        Vec2d(CHUNK_WIDTH, CHUNK_WIDTH), Colors.WHITE, 0.75);
                }
            }
        }

        // // Draw the entire map as one HUGE mesh and stream it into the GPU.

        // ulong allocation = chunkCount * (CHUNK_WIDTH * CHUNK_WIDTH);

        // writeln("allocation: ", allocation);
        // void* vertexPos = GC.malloc((float.sizeof * allocation) * 4);
        // ulong vertexIndex = 0;
        // void* textureCoord = GC.malloc((float.sizeof * allocation) * 8);
        // ulong textureIndex = 0;

        // // Draw chunk by chunk instead of tile by tile, it's much faster.

        // ulong drawn = 0;

        // foreach (xReal; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
        //     foreach (yReal; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
        //         int xInArray = xReal - topLeftChunkPosition.x;
        //         int yInArray = yReal - topLeftChunkPosition.y;

        //         const Chunk* thisChunk = data[xInArray][yInArray];

        //         if (thisChunk is null) {
        //             continue;
        //         }

        //         

        //     }
        // }

        // writeln("Drawn: ", drawn);

        //     foreach (x; minX .. maxX + 1) {
        //         foreach (y; minY .. maxY + 1) {

        //             Vec2d position = Vec2d(x, y);

        //             ChunkData thisData = getTileAtWorldPosition(position);

        //             position.y += 1;

        //             if (thisData.tileID == 0) {
        //                 // Render.rectangleLines(position, Vec2d(1, 1), Colors.WHITE);
        //                 continue;
        //             }

        //             // +1 on Y because it's drawn with the origin at the top left.

        //             // Render.rectangle(position, Vec2d(1, 1), Colors.ORANGE);

        //             TileDefinitionResult thisTileResult = TileDatabase.getTileByID(
        //                 thisData.tileID);

        //             if (!thisTileResult.exists) {
        //                 TextureHandler.drawTexture("unknown.png", position, Rect(0, 0, 16, 16), Vec2d(1, 1));
        //             } else {
        //                 TextureHandler.drawTexture(thisTileResult.definition.texture, position,
        //                     Rect(0, 0, 16.00001, 16.00001), Vec2d(1, 1));
        //             }

        //             // Render.rectangleLines(position, Vec2d(1, 1), Colors.WHITE);

        //         }
        //     }
    }

    double getGravity() {
        return gravity;
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
    ChunkData getTileAtWorldPosition(Vec2d position) {
        Vec2i chunkID = calculateChunkAtWorldPosition(position);

        if (chunkID !in database) {
            return ChunkData();
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

        database[chunkID].data[xPosInChunk][yPosInChunk].tileID = id;
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

        database[chunkID].data[xPosInChunk][yPosInChunk].tileID = result.unwrap.id;
    }

    void worldLoad(Vec2i currentPlayerChunk) {

        const int worldLoadDistance = 6;

        foreach (x; currentPlayerChunk.x - worldLoadDistance .. currentPlayerChunk.x + worldLoadDistance + 1) {
            foreach (y; currentPlayerChunk.y - worldLoadDistance .. currentPlayerChunk.y + worldLoadDistance + 1) {
                writeln("loading chunk ", x, " ", y);
                loadChunk(Vec2i(x, y));
            }
        }

        // This can get very laggy if old chunks are not unloaded. :)
        // unloadOldChunks(currentPlayerChunk);
    }

    bool collideEntityToWorld(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity,
        CollisionAxis axis) {

        return collision(entityPosition, entitySize, entityVelocity, axis);
    }

private: //* BEGIN INTERNAL API.

    bool collision(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity, CollisionAxis axis) {
        import utility.collision_functions;

        int oldX = int.min;
        int oldY = int.min;
        int currentX = int.min;
        int currentY = int.min;

        // debugDrawPoints = [];

        bool hitGround = false;

        foreach (double xOnRect; 0 .. ceil(entitySize.x) + 1) {
            double thisXPoint = (xOnRect > entitySize.x) ? entitySize.x : xOnRect;
            thisXPoint += entityPosition.x - (entitySize.x * 0.5);
            oldX = currentX;
            currentX = cast(int) floor(thisXPoint);

            if (oldX == currentX) {
                // writeln("skip X ", currentY);
                continue;
            }

            foreach (double yOnRect; 0 .. ceil(entitySize.y) + 1) {
                double thisYPoint = (yOnRect > entitySize.y) ? entitySize.y : yOnRect;
                thisYPoint += entityPosition.y;

                oldY = currentY;
                currentY = cast(int) floor(thisYPoint);

                if (currentY == oldY) {
                    // writeln("skip Y ", currentY);
                    continue;
                }

                // debugDrawPoints ~= Vec2d(currentX, currentY);

                ChunkData data = getTileAtWorldPosition(Vec2d(currentX, currentY));

                // todo: if solid tile collide.
                // todo: probably custom tile one day.

                if (data.tileID == 0) {
                    continue;
                }

                if (axis == CollisionAxis.X) {
                    CollisionResult result = collideXToTile(entityPosition, entitySize, entityVelocity,
                        Vec2d(currentX, currentY), Vec2d(1, 1));

                    if (result.collides) {
                        entityPosition.x = result.newPosition;
                        entityVelocity.x = 0;
                    }
                } else {

                    CollisionResult result = collideYToTile(entityPosition, entitySize, entityVelocity,
                        Vec2d(currentX, currentY), Vec2d(1, 1));

                    if (result.collides) {
                        entityPosition.y = result.newPosition;
                        entityVelocity.y = 0;
                        if (result.hitGround) {
                            hitGround = true;
                        }
                    }
                }
            }
        }

        return hitGround;
    }

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

        database[chunkPosition] = newChunk;
    }

    void generateChunkData(Vec2i chunkPosition, ref Chunk thisChunk) {

        // todo: the chunk should have a biome.
        BiomeDefinitionResult biomeResult = BiomeDatabase.getBiomeByID(0);
        if (!biomeResult.exists) {
            import std.conv;

            throw new Error("Attempted to get biome " ~ to!string(0) ~ " which does not exist");
        }

        const int basePositionX = chunkPosition.x * CHUNK_WIDTH;
        const int basePositionY = chunkPosition.y * CHUNK_WIDTH;

        Option!TileDefinition stoneResult = TileDatabase.getTileByID(
            biomeResult.definition.stoneLayerID);
        if (stoneResult.isNone) {
            throw new Error("Stone does not exist for biome " ~ biomeResult.definition.name);
        }

        Option!TileDefinition dirtResult = TileDatabase.getTileByID(
            biomeResult.definition.dirtLayerID);
        if (dirtResult.isNone) {
            throw new Error("Dirt does not exist for biome " ~ biomeResult.definition.name);
        }

        Option!TileDefinition grassResult = TileDatabase.getTileByID(
            biomeResult.definition.grassLayerID);
        if (grassResult.isNone) {
            throw new Error("Grass does not exist for biome " ~ biomeResult.definition.name);
        }

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {
                const double selectedNoise = fnlGetNoise2D(&noise, (x + basePositionX) * 10, (
                        y + basePositionY) * 10);

                // writeln(selectedNoise);

                if (selectedNoise < 0) {
                    thisChunk.data[x][y].tileID = grassResult.unwrap.id;
                } else {
                    thisChunk.data[x][y].tileID = dirtResult.unwrap.id;
                }

            }
        }
    }

    void generateChunkMesh(Vec2i chunkPosition, ref Chunk thisChunk) {
        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {

                const int tileID = thisChunk.data[x][y].tileID;

                const TileDefinition* thisTilePointer = TileDatabase.unsafeGetByID(tileID);

                // if (thisTilePointer is null) {
                //     throw new Error("null tile definition pointer!");
                // }

                // +1 because the tile origin is +Y and it needs to be shifted up.
                // Vec2d worldPosition = Vec2d(
                //     (xReal * CHUNK_WIDTH) + xInChunk,
                //     ((yReal * CHUNK_WIDTH) + yInChunk) + 1);

                // TextureHandler.drawTexture(thisTilePointer.texture, worldPosition,
                //     Rect(0, 0, 16.001, 16.001), Vec2d(1, 1));

                // drawn++;

                // if (thisTileResult.isSome) {

                // } else {
                //     throw new Error("missing tile ID!");
                // }
            }
        }

    }

}
