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
    Mesh[int] database;

    int nextMeshID = 1;

    int defaultShaderID = 0;
    int shaderColorDiffuseUniformLocation = 0;
    int mvpUniformLocation = 0;

    Matrix matView;
    Matrix matProjection;
    Matrix matrixTransform;

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
        int meshID = nextMeshID;
        nextMeshID++;

        Mesh thisMesh = Mesh();

        thisMesh.vertexCount = cast(int) verticesLength / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices;
        thisMesh.texcoords = textureCoordinates;

        UploadMesh(&thisMesh, false);

        if (!thisMesh.vaoId < 0) {
            throw new Error("Invalid mesh. " ~ to!string(meshID));
        }

        database[meshID] = thisMesh;

        return meshID;
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

        matView = rlGetMatrixModelview();
        matProjection = rlGetMatrixProjection();
        matrixTransform = rlGetMatrixTransform();
    }

    pragma(inline, true);
    void draw(Vec2d position, int id) {
        import std.datetime.stopwatch;

        Mesh* thisMesh = id in database;

        if (thisMesh is null) {
            throw new Error("This is quite a strange crash. " ~
                    "This means that this thing had a mesh that didn't exist assigned to it.");
        }

        //! This part is absolutely depraved and you should look away.

        // auto sw = StopWatch(AutoStart.yes);

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

        rlEnableVertexArray(thisMesh.vaoId);
        rlDrawVertexArray(0, thisMesh.vertexCount);

        // rlDisableVertexArray();

        // long timeResult = sw.peek().total!"hnsecs";

        // writeln("total: ", timeResult / 10.0, " usecs");

    }

    void destroy(int id) {
        // 0 is reserved for null;
        if (id == 0) {
            return;
        }

        Mesh* thisMesh = id in database;

        if (thisMesh is null) {
            throw new Error(
                "Tried to destroy non-existent mesh. " ~ to!string(id));
        }

        UnloadMesh(*thisMesh);
    }

}
