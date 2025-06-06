#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec2 fragTexCoord2;
// in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add your custom variables here

void main()
{
    // Texel color fetching from texture sampler
    vec4 texelColor = texture(texture0, fragTexCoord);
    vec4 texelColor2 = texture(texture0, fragTexCoord2);

    vec4 finalTexelColor;

    finalTexelColor.rgb = mix(texelColor.rgb, texelColor2.rgb, texelColor2.a);
    finalTexelColor.a = 1.0;

    // NOTE: Implement here your fragment shader code

    // final color is the color from the texture 
    //    times the tint color (colDiffuse)
    //    times the fragment color (interpolated vertex color)
    finalColor = finalTexelColor * colDiffuse;//*fragColor;
}