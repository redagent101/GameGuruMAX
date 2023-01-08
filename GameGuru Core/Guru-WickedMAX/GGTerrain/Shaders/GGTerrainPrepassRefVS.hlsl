#include "GGTerrainConstants.hlsli"

cbuffer CameraCB : register( b1 )
{
	float4x4	g_xCamera_VP;			// View*Projection
	float4		g_xCamera_ClipPlane;
};

struct VertexIn
{
	float3 position : POSITION;
	float4 inormal : INORMAL; // normalized float from 8 bit integers, like vertex colors
	uint id : ID; 
};

struct VertexOut
{
	float4 position : SV_POSITION;
	float  clip : SV_ClipDistance0;
};

VertexOut main( VertexIn IN )
{
    VertexOut OUT;
 
	float4 pos = float4( IN.position.xyz, 1.0 );
	OUT.position = mul( g_xCamera_VP, pos );
	OUT.clip = dot( pos, g_xCamera_ClipPlane );
	
	return OUT;
}
