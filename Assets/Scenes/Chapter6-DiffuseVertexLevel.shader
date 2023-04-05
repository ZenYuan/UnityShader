// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "Unity shaders Book/Chapter 6/Diffuse Vertex-Level"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
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
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				float3 ambient  = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//法线从模型空间变化到世界空间，为逆转置矩阵
				float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				o.color = ambient + diffuse;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
