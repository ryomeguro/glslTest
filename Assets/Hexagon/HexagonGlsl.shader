Shader "Unlit/glsl" { // defines the name of the shader 
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _DotNumInY("DotNumInY", Float) = 10
        [MaterialToggle] _UseTestLum("UseTestLum", Float) = 0
        _TestLum("TestLum", Range(0.0, 1.0)) = 0.5
    }
        SubShader{ // Unity chooses the subshader that fits the GPU best
            Pass { // some shaders require multiple passes
                GLSLPROGRAM // here begins the part in Unity's GLSL

                #ifdef VERTEX // here begins the vertex shader

                out vec2 vUV;

                void main() // all vertex shaders define a main() function
                {
                    vUV = gl_MultiTexCoord0.xy;

                    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                    // this line transforms the predefined attribute 
                    // gl_Vertex of type vec4 with the predefined
                    // uniform gl_ModelViewProjectionMatrix of type mat4
                    // and stores the result in the predefined output 
                    // variable gl_Position of type vec4.
                }

                #endif // here ends the definition of the vertex shader


            #ifdef FRAGMENT // here begins the fragment shader

            #define ROUTE3 1.7320508

            uniform sampler2D _MainTex;
            uniform int _DotNumInY;
            uniform int _UseTestLum;
            uniform float _TestLum;

            in vec2 vUV;

            vec3 calcHex(vec2 uv, float lum) {

                vec2 pos = uv * vec2(_DotNumInY);

                pos.x /= ROUTE3 / 2.0f;

                vec2 ipos = floor(pos);

                pos.y += mod(ipos.x, 2) < 0.1 ? 0.5 : 0.0;

                pos = fract(pos);

                pos = (pos - vec2(0.5)) * 2.0f;

                pos.x *= ROUTE3 / 2.0f;

                vec2 offsetPos = vec2(ROUTE3, 1.0f);
                offsetPos *= sign(pos);

                float dist = min(length(pos), length(pos - offsetPos));

                float result = dist * (ROUTE3 / 2.0) < pow(lum, 0.6) ? 0.0 : 1.0;
                return vec3(result);
            }

            void main() // all fragment shaders define a main() function
            {
                vec3 col = texture2D(_MainTex, vUV).rgb;

                float lum = dot(vec3(0.299, 0.587, 0.114), col);

                vec3 result = vec3( 0.0 );
                if (_UseTestLum > 0.5) {
                    result = calcHex(vUV, _TestLum);
                }
                else {
                    result = calcHex(vUV, 1 - lum);
                }

                gl_FragColor = vec4(result, 1.0);
            }

            #endif // here ends the definition of the fragment shader

            ENDGLSL // here ends the part in GLSL 
        }
    }
}