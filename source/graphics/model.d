module graphics.model;

public import raylib;
import graphics.texture_handler;
import std.stdio;

static final const class ModelHandler {
static:
private:

    Texture2D textureAtlas;
    Mesh[int] database;

    int currentID = 1;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
        Material blah;
    }

    int generate(float* vertices, const ulong verticesLength, float* textureCoordinates) {
        int meshID = currentID;
        currentID++;

        Mesh thisMesh = Mesh();

        thisMesh.vertexCount = cast(int) verticesLength / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices;
        thisMesh.texcoords = textureCoordinates;

        UploadMesh(&thisMesh, false);

        return meshID;
    }

    void draw() {
        // DrawMesh(database[1], )
    }

}
