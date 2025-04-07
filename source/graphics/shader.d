module graphics.shader;

import raylib;
import std.string;

static final const class ShaderHandler {
static:
private:

    Shader[string] database;

    //* BEGIN PUBLIC API.

    public void newShader(string shaderName, string vertCodeLocation, string fragCodeLocation) {
        if (shaderName in database) {
            throw new Error("[ShaderHandler]: Tried to overwrite shader " ~ shaderName);
        }

        Shader thisShader = Shader();
        thisShader = LoadShader(toStringz(vertCodeLocation), toStringz(fragCodeLocation));

        if (!IsShaderValid(thisShader)) {
            throw new Error("[ShaderHandler]: Invalid shader. " ~ shaderName);
        }

        database[shaderName] = thisShader;
    }

    public int getUniformLocation(string shaderName, string uniformName) {
        if (shaderName !in database) {
            throw new Error(
                "[ShaderHandler]: Tried to get non-existent shader. " ~ shaderName);
        }

        int val = GetShaderLocation(database[shaderName], toStringz(uniformName));

        if (val == -1) {
            throw new Error(
                "[ShaderHandler]: Uniform " ~ uniformName ~ " does not exist for shader. " ~ shaderName);
        }

        return val;
    }

    public Shader* getShaderPointer(string shaderName) {
        Shader* thisShader = shaderName in database;
        if (thisShader is null) {
            throw new Error(
                "[ShaderHandler]: Tried to get non-existent shader pointer. " ~ shaderName);
        }
        return thisShader;
    }

    public void setUniformFloat(string shaderName, int location, float value) {
        Shader* thisShader = shaderName in database;
        if (thisShader is null) {
            throw new Error(
                "[ShaderHandler]: Tried to set uniform in non-existent shader. " ~ shaderName);
        }

        SetShaderValue(*thisShader, location, &value,
            ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    }

    public void setUniformInt(string shaderName, int location, int value) {
        Shader* thisShader = shaderName in database;
        if (thisShader is null) {
            throw new Error(
                "[ShaderHandler]: Tried to set uniform in non-existent shader. " ~ shaderName);
        }

        SetShaderValue(*thisShader, location, &value,
            ShaderUniformDataType.SHADER_UNIFORM_INT);
    }

    public void terminate() {
        foreach (shaderName, thisShader; database) {
            UnloadShader(thisShader);
        }

        database.clear();
    }

    //* BEGIN INTERNAL API.
}
