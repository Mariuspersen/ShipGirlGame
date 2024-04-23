precision mediump float;
uniform sampler2D north;
uniform sampler2D south;
uniform sampler2D west;
uniform sampler2D east;
uniform sampler2D northwest;
uniform sampler2D southwest;
uniform sampler2D northeast;
uniform sampler2D southeast;
varying vec2 v_texCoord;

void main() {
   vec4 n = texture2D(north, v_texCoord);
   vec4 s = texture2D(south, v_texCoord);
   vec4 w = texture2D(west, v_texCoord);
   vec4 e = texture2D(east, v_texCoord);
   vec4 nw = texture2D(northwest, v_texCoord);
   vec4 sw = texture2D(southwest, v_texCoord);
   vec4 ne = texture2D(northeast, v_texCoord);
   vec4 se = texture2D(southeast, v_texCoord);
    
   vec4 we = mix(w, e, v_texCoord.x);
   vec4 ns = mix(n, s, v_texCoord.y);

   vec4 nwse = mix(nw,se,v_texCoord.x * v_texCoord.y);
   vec4 nesw = mix(sw,ne,v_texCoord.x * v_texCoord.y);


   vec4 wens = mix(we,ns,ns.a);
   vec4 snew = mix(we,ns,we.a);
   vec4 nwsenesw = mix(nwse,nesw,nwse.a);

   vec4 final = mix(wens,nwsenesw,nwsenesw.a);

   gl_FragColor = wens;
}