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
    int mvpUniformLocation = 0;

public: //* BEGIN PUBLIC API.

    void initialize() {
        textureAtlas = TextureHandler.getAtlas();
        defaultShaderID = rlGetShaderIdDefault();

        // Color uniform.
        immutable(char)* colDiffuse = toStringz("colDiffuse");
        shaderColorDiffuseUniformLocation = rlGetLocationUniform(defaultShaderID, colDiffuse);
        if (shaderColorDiffuseUniformLocation < 0) {
            throw new Error("Something has gone wrong with uniform colDiffuse");
        }

        // mvp uniform.
        immutable(char)* mvp = toStringz("mvp");
        mvpUniformLocation = rlGetLocationUniform(defaultShaderID, mvp);
        if (mvpUniformLocation < 0) {
            throw new Error("Something has gone wrong with uniform mvp");
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

    pragma(inline, true);
    void draw(Vec2d position, int id) {
        // import std.datetime.stopwatch;

        Model* thisModel = id in database;

        if (thisModel is null) {
            throw new Error("This is quite a strange crash. " ~
                    "This means that this thing had a model that didn't exist assigned to it.");
        }

        //! This part is absolutely depraved and you should look away.

        // auto sw = StopWatch(AutoStart.yes);

        // Manually inline the identity and translation and hope SIMD takes over.
        Matrix matScale = MatrixScale(1, 1, 1);
        Matrix matTranslation = MatrixTranslate(position.x, -position.y, 0);
        Matrix matTransform = MatrixMultiply(matScale, matTranslation);

        Matrix transform = matTransform;

        rlEnableShader(defaultShaderID);

        static immutable float[4] COLOR_DATA = [1.0, 1.0, 1.0, 1.0];
        static immutable int UNIFORM_DATA_TYPE = ShaderUniformDataType.SHADER_UNIFORM_VEC4;

        rlSetUniform(shaderColorDiffuseUniformLocation, &COLOR_DATA, UNIFORM_DATA_TYPE, 1);

        rlActiveTextureSlot(0);
        rlSetUniform(shaderColorDiffuseUniformLocation, null, ShaderUniformDataType.SHADER_UNIFORM_INT, 1);
        rlEnableTexture(textureAtlas.id);

        rlEnableVertexArray(thisModel.meshes.vaoId);

        Matrix matModel = MatrixIdentity();
        Matrix matView = rlGetMatrixModelview();
        Matrix matModelView = MatrixIdentity();
        Matrix matProjection = rlGetMatrixProjection();

        matModel = MatrixMultiply(transform, rlGetMatrixTransform());

        // Get model-view matrix
        matModelView = MatrixMultiply(matModel, matView);

        // Calculate model-view-projection matrix (MVP)
        Matrix matModelViewProjection = MatrixIdentity();
        matModelViewProjection = MatrixMultiply(matModelView, matProjection);

        // Send combined model-view-projection matrix to shader
        rlSetUniformMatrix(mvpUniformLocation, matModelViewProjection);

        // Draw mesh

        rlDrawVertexArray(0, thisModel.meshes.vertexCount);

        rlDisableVertexArray();

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
