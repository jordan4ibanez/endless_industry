module graphics.texture;

public import fast_pack : TexturePoints;
import core.memory;
import fast_pack;
import math.rect;
import math.vec2d;
import raylib;
import std.container;
import std.file;
import std.path;
import std.regex;
import std.stdio;
import std.string;

static final const class TextureHandler {
static:
private:

    TexturePacker!string database = TexturePacker!string(1);
    Texture2D atlas;
    TexturePoints!Vec2d[string] texturePointDatabase;

    //! NEVER USE THESE IN YOUR MODS.
    TexturePoints!Vec2d* ultraFastTexturePointAccess;
    ulong[string] texturePointAccessReverseLookup;

public: //* BEGIN PUBLIC API.

    void initialize() {

        foreach (string thisFilePathString; dirEntries("textures", "*.png", SpanMode.depth)) {
            loadTexture(thisFilePathString);
        }

        database.finalize("atlas.png");

        atlas = LoadTexture(toStringz("atlas.png"));

        database.extractTexturePoints(texturePointDatabase);

        // Begin ultra fast lookup for map mesh generation.

        ultraFastTexturePointAccess = cast(TexturePoints!Vec2d*) GC.malloc(
            TexturePoints!Vec2d.sizeof * texturePointDatabase.length);

        ulong index = 0;
        foreach (key, value; texturePointDatabase) {
            texturePointAccessReverseLookup[key] = index;

            ultraFastTexturePointAccess[index] = value;
            index++;
        }
    }

    void drawTexture(string textureName, Vec2d position, Rect sourceOnTexture, Vec2d size, Vec2d origin = Vec2d(0, 0),
        double rotation = 0) {

        Vec2d flippedPosition = Vec2d(position.x, -position.y);

        struct OutputRect {
            int x = 0;
            int y = 0;
            int w = 0;
            int h = 0;
        }

        OutputRect rawInput;
        database.getRectangleIntegral(textureName, rawInput);

        Rect source = Rect();
        source.x = rawInput.x + cast(int) sourceOnTexture.x;
        source.y = rawInput.y + cast(int) sourceOnTexture.y;
        source.width = sourceOnTexture.width;
        source.height = sourceOnTexture.height;

        Rect dest = Rect(
            flippedPosition.x,
            flippedPosition.y,
            size.x,
            size.y
        );

        drawTextureFromAtlasPro(atlas, source.toRaylib(), dest.toRaylib(), origin.toRaylib(), rotation, Colors
                .WHITE);
    }

    bool hasTexture(string name) {
        return database.contains(name);
    }

    TexturePoints!Vec2d getTexturePoints(string textureName) {
        TexturePoints!Vec2d* theseTexturePoints = textureName in texturePointDatabase;
        if (theseTexturePoints is null) {
            throw new Error("missing texture");
        }
        return *theseTexturePoints;
    }

    void loadTexture(string location) {

        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("[TextureManager]: Texture must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            if (!outputFileName.endsWith(".png")) {
                throw new Error("[TextureManager]: Not a .png");
            }
            return outputFileName;
        }();

        database.pack(fileName, location);
    }

    Texture2D getAtlas() {
        return atlas;
    }

    /// If you use this in your mods, you're going to have an extremely bad time.
    TexturePoints!Vec2d* getTexturePointsPointer(ulong index) {
        return ultraFastTexturePointAccess + index;
    }

    ulong lookupTexturePointsIndex(string name) {
        ulong* thisIndex = name in texturePointAccessReverseLookup;
        if (thisIndex is null) {
            throw new Error("Texture " ~ name ~ " does not exist");
        }
        return *thisIndex;
    }

    void terminate() {
        UnloadTexture(atlas);
    }

private: //* BEGIN INTERNAL API.

    // Draw a part of a texture (defined by a rectangle) with 'pro' parameters
    // NOTE: origin is relative to destination rectangle size
    void drawTextureFromAtlasPro(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation,
        Color tint) {
        // Check if texture is valid
        if (texture.id > 0) {
            float width = cast(float) texture.width;
            float height = cast(float) texture.height;

            bool flipX = false;

            if (source.width < 0) {
                flipX = true;
                source.width *= -1;
            }
            if (source.height < 0)
                source.y -= source.height;

            if (dest.width < 0)
                dest.width *= -1;
            if (dest.height < 0)
                dest.height *= -1;

            Vector2 topLeft = {0};
            Vector2 topRight = {0};
            Vector2 bottomLeft = {0};
            Vector2 bottomRight = {0};

            // Only calculate rotation if needed
            if (rotation == 0.0f) {
                float x = dest.x - origin.x;
                float y = dest.y - origin.y;
                topLeft = Vector2(x, y);
                topRight = Vector2 ( x + dest.width, y );
                bottomLeft = Vector2 ( x, y + dest.height );
                bottomRight = Vector2 ( x + dest.width, y + dest.height );
            } else {
                float sinRotation = sinf(rotation * DEG2RAD);
                float cosRotation = cosf(rotation * DEG2RAD);
                float x = dest.x;
                float y = dest.y;
                float dx = -origin.x;
                float dy = -origin.y;

                topLeft.x = x + dx * cosRotation - dy * sinRotation;
                topLeft.y = y + dx * sinRotation + dy * cosRotation;

                topRight.x = x + (dx + dest.width) * cosRotation - dy * sinRotation;
                topRight.y = y + (dx + dest.width) * sinRotation + dy * cosRotation;

                bottomLeft.x = x + dx * cosRotation - (dy + dest.height) * sinRotation;
                bottomLeft.y = y + dx * sinRotation + (dy + dest.height) * cosRotation;

                bottomRight.x = x + (dx + dest.width) * cosRotation - (dy + dest.height) * sinRotation;
                bottomRight.y = y + (dx + dest.width) * sinRotation + (dy + dest.height) * cosRotation;
            }

            rlSetTexture(texture.id);
            rlBegin(RL_QUADS);

            rlColor4ub(tint.r, tint.g, tint.b, tint.a);
            rlNormal3f(0.0f, 0.0f, 1.0f); // Normal vector pointing towards viewer

            // Top-left corner for texture and quad
            if (flipX)
                rlTexCoord2f((source.x + source.width) / width, source.y / height);
            else
                rlTexCoord2f(source.x / width, source.y / height);
            rlVertex2f(topLeft.x, topLeft.y);

            // Bottom-left corner for texture and quad
            if (flipX)
                rlTexCoord2f((source.x + source.width) / width, (source.y + source.height) / height);
            else
                rlTexCoord2f(source.x / width, (source.y + source.height) / height);
            rlVertex2f(bottomLeft.x, bottomLeft.y);

            // Bottom-right corner for texture and quad
            if (flipX)
                rlTexCoord2f(source.x / width, (source.y + source.height) / height);
            else
                rlTexCoord2f((source.x + source.width) / width, (source.y + source.height) / height);
            rlVertex2f(bottomRight.x, bottomRight.y);

            // Top-right corner for texture and quad
            if (flipX)
                rlTexCoord2f(source.x / width, source.y / height);
            else
                rlTexCoord2f((source.x + source.width) / width, source.y / height);
            rlVertex2f(topRight.x, topRight.y);

            rlEnd();
            rlSetTexture(0);

            // NOTE: Vertex position can be transformed using matrices
            // but the process is way more costly than just calculating
            // the vertex positions manually, like done above
            // I leave here the old implementation for educational purposes,
            // just in case someone wants to do some performance test
            /*
        rlSetTexture(texture.id);
        rlPushMatrix();
            rlTranslatef(dest.x, dest.y, 0.0f);
            if (rotation != 0.0f) rlRotatef(rotation, 0.0f, 0.0f, 1.0f);
            rlTranslatef(-origin.x, -origin.y, 0.0f);

            rlBegin(RL_QUADS);
                rlColor4ub(tint.r, tint.g, tint.b, tint.a);
                rlNormal3f(0.0f, 0.0f, 1.0f);                          // Normal vector pointing towards viewer

                // Bottom-left corner for texture and quad
                if (flipX) rlTexCoord2f((source.x + source.width)/width, source.y/height);
                else rlTexCoord2f(source.x/width, source.y/height);
                rlVertex2f(0.0f, 0.0f);

                // Bottom-right corner for texture and quad
                if (flipX) rlTexCoord2f((source.x + source.width)/width, (source.y + source.height)/height);
                else rlTexCoord2f(source.x/width, (source.y + source.height)/height);
                rlVertex2f(0.0f, dest.height);

                // Top-right corner for texture and quad
                if (flipX) rlTexCoord2f(source.x/width, (source.y + source.height)/height);
                else rlTexCoord2f((source.x + source.width)/width, (source.y + source.height)/height);
                rlVertex2f(dest.width, dest.height);

                // Top-left corner for texture and quad
                if (flipX) rlTexCoord2f(source.x/width, source.y/height);
                else rlTexCoord2f((source.x + source.width)/width, source.y/height);
                rlVertex2f(dest.width, 0.0f);
            rlEnd();
        rlPopMatrix();
        rlSetTexture(0);
        */
        }
    }
}
