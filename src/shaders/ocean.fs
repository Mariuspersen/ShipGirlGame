
// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables
uniform float time;

void main()
{
    // Texel color fetching from texture sampler
    
    vec4 texelColor = texture(texture0, fragTexCoord);
    texelColor -= vec4(0.0,sin(time*2),0.0,0.0);
    // NOTE: Implement here your fragment shader code

    finalColor = texelColor;//*colDiffuse;
}