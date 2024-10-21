
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
uniform float amplitude;
uniform float frequency;

void main()
{
    //1vec2 size = vec2(100.0f,100.0f);
    //float freqX = 0.5;
    //float freqY = 0.3;
    //float ampX = 0.2;
    //float ampY = 0.3;
    //float speedX = 0.5;
    //float speedY = 0.1;
    
    //float pixelWidth = 1.0 / size.x;
    //float pixelHeight = 1.0 / size.y;
    //float aspect = pixelHeight / pixelWidth;
    //float boxLeft = 0.0;
    //float boxTop = 0.0;
    //float seconds = time;

    //vec2 p = fragTexCoord;
    //p.x += cos((fragTexCoord.y - boxTop) * freqX / ( pixelWidth * 750.0) + (seconds * speedX)) * ampX * pixelWidth;
    //p.y += sin((fragTexCoord.x - boxLeft) * freqY * aspect / ( pixelHeight * 750.0) + (seconds * speedY)) * ampY * pixelHeight;'
    
    finalColor = texture(texture0, fragTexCoord)*colDiffuse*fragColor;
}