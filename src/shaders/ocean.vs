// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;
// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 pos;


// NOTE: Add here your custom variables
uniform float time;
uniform float amplitude;
uniform float frequency;

#define M_PI 3.1415926535897932384626433832795

void main()
{
    // Send vertex attributes to fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    vec3 newPos = vertexPosition;
    float waveX = sin(vertexPosition.x * M_PI * (floor(frequency*100.0f) * 0.25) + time);
    float waveZ = sin(vertexPosition.z * M_PI * (floor(frequency*100.0f) * 0.25) + time);
    
    newPos.y = amplitude * (waveX + waveZ);

    pos = newPos;
    // Calculate final vertex position
    gl_Position = mvp*vec4(newPos, 1.0);
}
