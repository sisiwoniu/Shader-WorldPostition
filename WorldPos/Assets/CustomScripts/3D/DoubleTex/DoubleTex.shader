Shader "Unlit/DoubleTex"
{
	//TODO:拡散の周りにラインを追加する、どうやって範囲を指定するのか
    Properties
    {	
		[NoScaleOffset]
        _MainTex ("Tex", 2D) = "white" {}

		[NoScaleOffset]
		_SubTex ("Sub Tex", 2D) = "white" {}

		_DebugMainCol ("Main Col", Color) = (1, 1, 1, 1)

		_DebugSubCol ("Sub Col", Color) = (1, 1, 1, 1)

		//サブテクスチャ表示の半径値
		_Radius ("Radius", Range(0.1, 10)) = 1.0

		_DistOffset ("Distance Offset", Range(0, 1)) = 0

		_DisLineWidth("Line Width", Range(0.001, 0.1)) = 0

        _DisLineColor("Line Tint", Color) = (1,1,1,1)  
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			//#pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 w_Pos : TEXCOORD1;
            };

			//メインテクスチャ
            sampler2D _MainTex;

			//サブテクスチャ
			sampler2D _SubTex;

			//ターゲットオブジェクトのワールド座標
			float3 _TargetPos;

			//半径
			float _Radius;

			float _DistOffset;

			float _DisLineWidth;

			fixed4 _DisLineColor;

			fixed4 _DebugMainCol;

			fixed4 _DebugSubCol;

			float _refRadius;

            v2f vert (appdata v)
            {
                v2f o;
                
				o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.uv;
                
				//UNITY_TRANSFER_FOG(o,o.vertex);
                
				o.w_Pos = mul(unity_ObjectToWorld, v.vertex);

				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _DebugMainCol * tex2D(_MainTex, i.uv);

				fixed4 subCol = _DebugSubCol * tex2D(_SubTex, i.uv);

				//ターゲットのオブジェクトとワールド空間上どれぐらい離れるかを計算する
				half dist = distance(i.w_Pos, _TargetPos) - _DistOffset;

				//乗算から加算に行くと一回の命令で済む
				//1 - saturate(dist * _refRadius)と同じだが、軽くなるかな
				fixed t = saturate(dist * _refRadius) * -1 + 1;

				//境界線の閾値を計算
				//やっているのは「変化の一番先頭を一部切り取って、境界線にする」
				fixed line_t = step(_DisLineWidth * 0.5, t) * step(t, _DisLineWidth);

				col.rgb = lerp(col.rgb, subCol.rgb, t);

				//境界線表示でなければ、テクスチャ色を表示、じゃなければ境界線を表示する
				col = col * (1 - line_t) + _DisLineColor * line_t;

                return col;
            }
            ENDCG
        }
    }
}
