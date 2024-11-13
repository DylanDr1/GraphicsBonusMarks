Shader "Custom/Audience"
{
    Properties{
        _MainTex("Diffuse", 2D) = "white" {}
        _OverlayTex("Overlay Texture", 2D) = "white" {}
        _Tint("Colour Tint", Color) = (1,1,1,1)
        _Freq("Frequency", Range(0,5)) = 3
        _Speed("Wave Speed", Range(0,100)) = 10
        _Amp("Amplitude", Range(0,1)) = 0.5
        _ScrollSpeed("Base Texture Scroll Speed", Range(0,1)) = 0.1
        _OverlayScrollSpeed("Overlay Texture Scroll Speed", Range(0,1)) = 0.1
        _BlendFactor("Overlay Blend Factor", Range(0,1)) = 0.5
    }

        SubShader{
            CGPROGRAM
            #pragma surface surf Lambert vertex:vert

            struct Input {
                float2 uv_MainTex;
                float2 uv_OverlayTex; // Add UV for overlay texture
                float3 vertColor;
            };

            float4 _Tint;
            float _Freq;
            float _Speed;
            float _Amp;
            float _ScrollSpeed;
            float _OverlayScrollSpeed;
            float _BlendFactor;

            struct appdata {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            void vert(inout appdata v, out Input o) {
                UNITY_INITIALIZE_OUTPUT(Input, o);

                float t = _Time.y * _Speed;
                float waveHeight = sin(t + v.vertex.x * _Freq) * _Amp +
                                   sin(t * 2 + v.vertex.x * _Freq * 2) * _Amp;

                // Move vertex up and down with wave
                v.vertex.z += waveHeight;

                // Set initial UVs for both textures in the vertex shader
                o.uv_MainTex = v.texcoord.xy;
                o.uv_OverlayTex = v.texcoord.xy;

                v.normal = normalize(float3(v.normal.x + waveHeight, v.normal.y, v.normal.z));
                o.vertColor = waveHeight + 2;
            }

            sampler2D _MainTex;
            sampler2D _OverlayTex;

            void surf(Input IN, inout SurfaceOutput o) {
                // Apply scrolling to the base texture
                float2 baseScrollOffset = float2(_Time.y * _ScrollSpeed, 0);
                float4 baseColor = tex2D(_MainTex, IN.uv_MainTex + baseScrollOffset);

                // Apply scrolling to the overlay texture
                float2 overlayScrollOffset = float2(_Time.y * _OverlayScrollSpeed, 0);
                float4 overlayColor = tex2D(_OverlayTex, IN.uv_OverlayTex + overlayScrollOffset);

                // Blend the overlay with the base texture based on _BlendFactor
                float4 finalColor = lerp(baseColor, overlayColor, _BlendFactor);

                // Apply tint and set final color
                o.Albedo = finalColor.rgb * _Tint.rgb;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
