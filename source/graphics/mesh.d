module graphics.mesh;

public import raylib;
import graphics.texture_handler;

static final const class MeshHandler {
static:
private:

    Texture2D textureAtlas;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
    }

    void superUpload() {
        
    }

}
