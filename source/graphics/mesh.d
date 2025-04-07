module graphics.mesh;

public import raylib;
import graphics.texture_handler;
import math.vec2d;
import std.conv;
import std.stdio;
import std.string;

// In debug mode, this is slower.
// In release mode, it consistently makes render time immeasurable.
void fastMatrixMultiply(const Matrix* left, const Matrix* right, Matrix* result) {
    result.m0 = left.m0 * right.m0 + left.m1 * right.m4 + left.m2 * right.m8 + left.m3 * right.m12;
    result.m1 = left.m0 * right.m1 + left.m1 * right.m5 + left.m2 * right.m9 + left.m3 * right.m13;
    result.m2 = left.m0 * right.m2 + left.m1 * right.m6 + left.m2 * right.m10 + left.m3 * right.m14;
    result.m3 = left.m0 * right.m3 + left.m1 * right.m7 + left.m2 * right.m11 + left.m3 * right.m15;
    result.m4 = left.m4 * right.m0 + left.m5 * right.m4 + left.m6 * right.m8 + left.m7 * right.m12;
    result.m5 = left.m4 * right.m1 + left.m5 * right.m5 + left.m6 * right.m9 + left.m7 * right.m13;
    result.m6 = left.m4 * right.m2 + left.m5 * right.m6 + left.m6 * right.m10 + left.m7 * right.m14;
    result.m7 = left.m4 * right.m3 + left.m5 * right.m7 + left.m6 * right.m11 + left.m7 * right.m15;
    result.m8 = left.m8 * right.m0 + left.m9 * right.m4 + left.m10 * right.m8 + left.m11 * right
        .m12;
    result.m9 = left.m8 * right.m1 + left.m9 * right.m5 + left.m10 * right.m9 + left.m11 * right
        .m13;
    result.m10 = left.m8 * right.m2 + left.m9 * right.m6 + left.m10 * right.m10 + left.m11 * right
        .m14;
    result.m11 = left.m8 * right.m3 + left.m9 * right.m7 + left.m10 * right.m11 + left.m11 * right
        .m15;
    result.m12 = left.m12 * right.m0 + left.m13 * right.m4 + left.m14 * right.m8 + left.m15 * right
        .m12;
    result.m13 = left.m12 * right.m1 + left.m13 * right.m5 + left.m14 * right.m9 + left.m15 * right
        .m13;
    result.m14 = left.m12 * right.m2 + left.m13 * right.m6 + left.m14 * right.m10 + left.m15 * right
        .m14;
    result.m15 = left.m12 * right.m3 + left.m13 * right.m7 + left.m14 * right.m11 + left.m15 * right
        .m15;
}

static final const class MeshHandler {
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

    pragma(inline, true)
    void prepareAtlasDrawing() {
        rlEnableShader(defaultShaderID);

        static immutable float[4] COLOR_DATA = [1.0, 1.0, 1.0, 1.0];
        static immutable int UNIFORM_DATA_TYPE = ShaderUniformDataType.SHADER_UNIFORM_VEC4;

        rlSetUniform(shaderColorDiffuseUniformLocation, &COLOR_DATA, UNIFORM_DATA_TYPE, 1);

        rlActiveTextureSlot(0);
        rlSetUniform(shaderColorDiffuseUniformLocation, null, ShaderUniformDataType.SHADER_UNIFORM_INT, 1);
        rlEnableTexture(textureAtlas.id);
    }

    pragma(inline, true);
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
        Matrix transform;
        transform.m0 = 1;
        transform.m5 = 1;
        transform.m10 = 1;
        transform.m12 = position.x;
        transform.m13 = -position.y;
        transform.m14 = 0;
        transform.m15 = 1;

        Matrix matModel;
        matModel.m0 = 1;
        matModel.m5 = 1;
        matModel.m10 = 1;
        matModel.m15 = 1;

        Matrix matModelView;
        matModelView.m0 = 1;
        matModelView.m5 = 1;
        matModelView.m10 = 1;
        matModelView.m15 = 1;

        Matrix matView = rlGetMatrixModelview();
        Matrix matProjection = rlGetMatrixProjection();
        Matrix matrixTransform = rlGetMatrixTransform();

        fastMatrixMultiply(&transform, &matrixTransform, &matModel);

        // Get model-view matrix
        fastMatrixMultiply(&matModel, &matView, &matModelView);

        // Calculate model-view-projection matrix (MVP)
        Matrix matModelViewProjection;
        matModelViewProjection.m0 = 1;
        matModelViewProjection.m5 = 1;
        matModelViewProjection.m10 = 1;
        matModelViewProjection.m15 = 1;
        fastMatrixMultiply(&matModelView, &matProjection, &matModelViewProjection);

        // Send combined model-view-projection matrix to shader
        rlSetUniformMatrix(mvpUniformLocation, matModelViewProjection);

        rlEnableVertexArray(thisModel.meshes.vaoId);
        rlDrawVertexArray(0, thisModel.meshes.vertexCount);

        // rlDisableVertexArray();

        long timeResult = sw.peek().total!"hnsecs";

        writeln("total: ", timeResult / 10.0, " usecs");

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
