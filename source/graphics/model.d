module graphics.model;

public import raylib;
import graphics.texture_handler;
import math.vec2d;
import std.conv;
import std.stdio;
import std.string;

static final const class ModelHandler {
static:
private:

    Texture2D textureAtlas;
    Model[int] database;

    int nextModelID = 1;

    int defaultShaderID = 0;
    int shaderColorDiffuseUniformLocation = 0;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
        defaultShaderID = rlGetShaderIdDefault();

        immutable(char)* blah = toStringz("colDiffuse");
        shaderColorDiffuseUniformLocation = rlGetLocationUniform(defaultShaderID, blah);

        if (shaderColorDiffuseUniformLocation <= 0) {
            throw new Error("Something has gone wrong with uniform color diffuse");
        }
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

        //! This part is absolutely depraved and you should look away.

        auto sw = StopWatch(AutoStart.yes);

        // Manually inline the identity and translation and hope SIMD takes over.
        Matrix matTransform;
        matTransform.m0 = 1;
        matTransform.m3 = position.x;
        matTransform.m5 = 1;
        matTransform.m7 = -position.y;
        matTransform.m10 = 1;
        matTransform.m15 = 1;

        rlEnableShader(defaultShaderID);

        // Matrix matModel = MatrixIdentity();
        // Matrix matView = rlGetMatrixModelview();
        // Matrix matModelView = MatrixIdentity();
        // Matrix matProjection = rlGetMatrixProjection();

        // matModel = MatrixMultiply(matTransform, rlGetMatrixTransform());

        // DrawMesh(*thisModel.meshes, *thisModel.materials, matTransform);

        rlDisableShader();

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
