precision mediump float;
uniform sampler2D north;
uniform sampler2D south;
uniform sampler2D west;
uniform sampler2D east;
varying vec2 v_texCoord;

void main() {
   float tb = smoothstep(0.0,1.0,v_texCoord.y);
   float lr = smoothstep(0.0,1.0,v_texCoord.x);
   vec4 n = texture2D(north, v_texCoord);
   vec4 s = texture2D(south, v_texCoord);
   vec4 w = texture2D(west, v_texCoord);
   vec4 e = texture2D(east, v_texCoord);
   /*if(n == s && w == e) {
      gl_FragColor = vec4(0.0,0.0,0.0,0.0);
      return;
   }*/
   vec4 ns = mix(n,s,tb);
   vec4 we = mix(w,e,lr);
   gl_FragColor = mix(ns,we,0.5);
}