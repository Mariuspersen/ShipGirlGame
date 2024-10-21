// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

// NOTE: Add here your custom variables
uniform float time;
uniform float amplitude;
uniform float frequency;

void main()
{
    // Send vertex attributes to fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    vec3 newPos = vertexPosition;
    newPos.y = amplitude * sin(time * vertexTexCoord.x);

    // Calculate final vertex position
    gl_Position = mvp*vec4(newPos, 1.0);
}