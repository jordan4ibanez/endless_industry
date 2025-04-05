module graphics.mesh;

public import raylib;
import graphics.texture_handler;

static final const class MeshHandler {
static:
private:

    Texture2D textureAtlas;
    Mesh[int] database;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
    }

    int generate(float* vertices, const ulong verticesLength, float* textureCoordinates) {
        int meshID = 0;

        

        return meshID;
    }

}
