Shader "Custom/NewSurfaceShader"
{
    Properties{
        _Color("Color", Color) = (1.0,1.0,1.0)
        _SpecColor("Specular Color", Color) = (1.0,1.0,1.0)
        _Shininess("Shininess", Range(10, 200)) = 100 // Increased max value for higher shininess
        _SpecularIntensity("Specular Intensity", Float) = 1.5 // New property for controlling specular strength
    }

        SubShader{
            Pass {
                Tags {"LightMode" = "ForwardBase"}
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

        // User-defined variables
        uniform float4 _Color;
        uniform float4 _SpecColor;
        uniform float _Shininess;
        uniform float _SpecularIntensity; // New variable to control specular intensity

        // Unity-defined variables
        uniform float4 _LightColor0;

        // Structs
        struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float4 normalDir : TEXCOORD1;
        };

        // Vertex function
        vertexOutput vert(vertexInput v) {
            vertexOutput o;
            o.posWorld = mul(unity_ObjectToWorld, v.vertex);
            o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));
            o.pos = UnityObjectToClipPos(v.vertex);
            return o;
        }

        // Fragment function
        float4 frag(vertexOutput i) : COLOR {
            // Vectors
            float3 normalDirection = normalize(i.normalDir.xyz);
            float atten = 1.0;

            // Lighting
            float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));

            // Specular direction
            float3 lightReflectDirection = reflect(-lightDirection, normalDirection);
            float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - i.posWorld.xyz));
            float specAngle = max(0.0, dot(lightReflectDirection, viewDirection));

            // Shininess and specular intensity adjustments for more shine
            float specularPower = pow(specAngle, _Shininess);
            float3 specularReflection = atten * _SpecColor.rgb * specularPower * _SpecularIntensity;

            // Final lighting calculation
            float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

            return float4(lightFinal * _Color.rgb, 1.0);
        }
        ENDCG
    }
    }
}
