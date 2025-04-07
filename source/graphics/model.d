module graphics.model;

public import raylib;
import graphics.texture_handler;
import math.vec2d;
import std.conv;
import std.stdio;

static final const class ModelHandler {
static:
private:

    Texture2D textureAtlas;
    Model[int] database;

    int nextModelID = 1;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
    }

    int generate(float* vertices, const ulong verticesLength, float* textureCoordinates) {
        int modelID = nextModelID;
        nextModelID++;

        Mesh thisMesh = Mesh();

        thisMesh.vertexCount = cast(int) verticesLength / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices;
        thisMesh.texcoords = textureCoordinates;

        UploadMesh(&thisMesh, false);

        Model thisModel = Model();
        thisModel = LoadModelFromMesh(thisMesh);
        if (!IsModelValid(thisModel)) {
            throw new Error("[ModelHandler]: Invalid model loaded from mesh. " ~ to!string(modelID));
        }

        thisModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = textureAtlas;

        database[modelID] = thisModel;

        return modelID;
    }

    void draw(Vec2d position, int id) {
        import std.datetime.stopwatch;

        Model* thisModel = id in database;

        if (thisModel is null) {
            throw new Error("This is quite a strange crash. " ~
                    "This means that this thing had a model that didn't exist assigned to it.");
        }

        auto sw = StopWatch(AutoStart.yes);

        Matrix matTransform = MatrixTranslate(position.x, -position.y, 0);

        // rlEnableShader(thisModel.materials.shader.id);

        // Matrix matModel = MatrixIdentity();
        // Matrix matView = rlGetMatrixModelview();
        // Matrix matModelView = MatrixIdentity();
        // Matrix matProjection = rlGetMatrixProjection();

        // matModel = MatrixMultiply(matTransform, rlGetMatrixTransform());

        // DrawMesh(*thisModel.meshes, *thisModel.materials, matTransform);

        // rlDisableShader();

        // model.materials[model.meshMaterial[i]].maps[MATERIAL_MAP_DIFFUSE].color = color;

        // DrawModel(*thisModel, Vector3(position.x, -position.y, 0), 1, Colors.WHITE);

        long blah = sw.peek().total!"nsecs";

        writeln("total: ", blah, "nsecs");
    }

    void destroy(int id) {
        // 0 is reserved for null;
        if (id == 0) {
            return;
        }

        Model* thisModel = id in database;

        if (thisModel is null) {
            throw new Error(
                "[ModelManager]: Tried to destroy non-existent model. " ~ to!string(id));
        }

        UnloadModel(*thisModel);
    }

}
