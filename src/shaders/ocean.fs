
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
uniform vec3 camera;

void main()
{
    float height = sin(pos.y)*0.2f;
    vec4 foam = vec4(height,height,height,0.0);
    vec4 texelColor = texture(texture0,fragTexCoord);

    finalColor = (texelColor+foam)*colDiffuse;
}