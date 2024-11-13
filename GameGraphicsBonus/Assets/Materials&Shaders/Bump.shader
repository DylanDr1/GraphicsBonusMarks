Shader"Bump"
{
Properties
{
    _myDiffuse ("Diffuse Texture", 2D) = "white" {}
    _myBump ("Bump Texture", 2D) = "bump" {}
    _mySlider ("Bump Amount", Range(0,10)) = 1
    _myColor("Color",Color) = (1.0,1.0,1.0)
}

SubShader
{
Tags{"RenderType"="Opaque"}
    CGPROGRAM
    #pragma surface surf Lambert
    sampler2D  _myDiffuse;
    sampler2D _myBump;
    half _mySlider;
float4 _myColor;
    struct Input
    {
        float2 uv_myDiffuse;
        float2 uv_myBump;
    };

    void surf(Input IN, inout SurfaceOutput o)
    {
        o.Albedo = tex2D(_myDiffuse, IN.uv_myDiffuse).rgb * _myColor;
        o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump));
        o.Normal *= float3(_mySlider,_mySlider,1);
    }
    ENDCG
}
Fallback "Diffuse"
}