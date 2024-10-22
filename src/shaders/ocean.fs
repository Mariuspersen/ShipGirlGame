
// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 pos;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables
uniform float time;
uniform float amplitude;
uniform float frequency;

void main()
{
    float height = sin(pos.y)*0.2f;
    // Texel color fetching from texture sampler
    vec4 foam = vec4(height,height,height,0.0);
    vec4 texelColor = texture(texture0,fragTexCoord);
    //texelColor.x += sin(pos.x + time)*0.5;
    //texelColor.y += cos(pos.y + time)*0.5;
    //texelColor.z += sin(pos.z)*0.5;
    // NOTE: Implement here your fragment shader code

    finalColor = (texelColor+foam)*colDiffuse;
}