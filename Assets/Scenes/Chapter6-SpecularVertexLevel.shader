// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'



Shader "UUnity shaders Book/Chapter 6/Specular Vertex-Level"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(8.0, 256.0)) = 10
    }

    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //half lambert diffuse
                float3 diffuse = _LightColor0.rbg * _Diffuse.rgb * 
                (0.5 * dot(normalize(i.worldNormal), lightDir) + 0.5);//插值后的法线需要归一化

                //specular
                float3 reflectVector = normalize(reflect(-lightDir, i.worldNormal));
                float3 viewVector = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                #if 0
                float3 specular = _LightColor0.rgb * _Specular.rgb *
                pow(saturate(dot(reflectVector, viewVector)), _Gloss);
                #else
                //bilnn-Phone specular
                float3 halfVector = normalize(viewVector + lightDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb *
                pow(saturate(dot(halfVector, normalize(i.worldNormal))), _Gloss);
                #endif

                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Specular"
}