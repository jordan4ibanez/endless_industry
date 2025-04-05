module game.map;

public import utility.collision_functions : CollisionAxis;
import fast_noise;
import game.biome_database;
import game.tile_database;
import graphics.camera_handler;
import graphics.render;
import graphics.texture_handler;
import math.rect;
import math.vec2d;
import math.vec2i;
import std.algorithm.comparison;
import std.conv;
import std.math.algebraic;
import std.math.rounding;
import std.random;
import std.stdio;
import utility.window;

//! NEVER CHANGE THIS!
immutable public int CHUNK_WIDTH = 32;

struct ChunkData {
    int tileID = 0;
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

        // foreach (x; topLeftChunkPosition.x .. bottomRightChunkPosition.x + 1) {
        //     foreach (y; topLeftChunkPosition.y .. bottomRightChunkPosition.y + 1) {
        //         Render.rectangleLines(Vec2d(x * CHUNK_WIDTH, (y + 1) * CHUNK_WIDTH), Vec2d(CHUNK_WIDTH, CHUNK_WIDTH),
        //             Colors.WHITE, 0.7);
        //     }
        // }

        //? This needs to be dynamic so it can support 8k+ displays.
        //? I do not have an 8k display to test this though. :(
        Chunk*[][] data = new Chunk*[][](
            abs(bottomRightChunkPosition.x - topLeftChunkPosition.x) + 1,
            abs(bottomRightChunkPosition.y - topLeftChunkPosition.y) + 1);

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

        TileDefinitionResult result = TileDatabase.getTileByName(name);

        if (!result.exists) {
            throw new Error("Cannot set to tile " ~ name ~ ", does not exist.");
        }

        database[chunkID].data[xPosInChunk][yPosInChunk].tileID = result.definition.id;
    }

    void worldLoad(Vec2i currentPlayerChunk) {
        foreach (x; currentPlayerChunk.x - 1 .. currentPlayerChunk.x + 2) {
            foreach (y; currentPlayerChunk.y - 1 .. currentPlayerChunk.y + 2) {
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

    //     // todo: save the chunks to mongoDB.

    //     int[] keys = [] ~ database.keys;

    //     foreach (int key; keys) {
    //         if (abs(key - currentPlayerChunk) > 1) {
    //             database.remove(key);
    //             // todo: save the chunks to mongoDB.
    //             // writeln("deleted: " ~ to!string(key));
    //         }
    //     }
    // }

    void loadChunk(Vec2i chunkPosition) {
        // Already loaded.
        if (chunkPosition in database) {
            return;
        }
        // todo: try to read from mongoDB.
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

        immutable int basePositionX = chunkPosition.x * CHUNK_WIDTH;
        immutable int basePositionY = chunkPosition.y * CHUNK_WIDTH;

        TileDefinitionResult bedrockResult = TileDatabase.getTileByName("bedrock");
        if (!bedrockResult.exists) {
            throw new Error("Please do not remove bedrock from the engine.");
        }

        TileDefinitionResult stoneResult = TileDatabase.getTileByID(
            biomeResult.definition.stoneLayerID);
        if (!stoneResult.exists) {
            throw new Error("Stone does not exist for biome " ~ biomeResult.definition.name);
        }

        TileDefinitionResult dirtResult = TileDatabase.getTileByID(
            biomeResult.definition.dirtLayerID);
        if (!dirtResult.exists) {
            throw new Error("Dirt does not exist for biome " ~ biomeResult.definition.name);
        }

        TileDefinitionResult grassResult = TileDatabase.getTileByID(
            biomeResult.definition.grassLayerID);
        if (!grassResult.exists) {
            throw new Error("Grass does not exist for biome " ~ biomeResult.definition.name);
        }

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_WIDTH) {
                const double selectedNoise = fnlGetNoise2D(&noise, (x + basePositionX) * 10, (
                        y + basePositionY) * 10);

                // writeln(selectedNoise);

                if (selectedNoise < 0) {
                    thisChunk.data[x][y].tileID = grassResult.definition.id;
                } else {
                    thisChunk.data[x][y].tileID = dirtResult.definition.id;
                }

            }
        }
    }

}
