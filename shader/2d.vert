#version 330

// Input vertex attributes
in vec2 vertexPosition;
in vec2 vertexTexCoord;
in vec2 vertexTexCoord2;
// in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec2 fragTexCoord2;
// out vec4 fragColor;

// NOTE: Add your custom variables here

void main()
{
    // Send vertex attributes to fragment shader
    fragTexCoord = vertexTexCoord;
    fragTexCoord2 = vertexTexCoord2;
    // fragColor = vertexColor;

    // Calculate final vertex position
    gl_Position = mvp*vec4(vertexPosition, 0, 1.0);
}