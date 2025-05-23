#define BRIGHTNESS 0.05 //-0.03
#define CONTRAST 1.0
#define DESATURATION 0.3

#define X_OFFSET 0.5
#define Z_OFFSET 0.5

#define LIGHTNESS 1.0

#define LAND_ALT 0.35
#define SEA_FLOOR_ALT 0.0

#define X_MAGIC 1.0f
#define Y_MAGIC 0.0f

texture tex0 < string ResourceName = "Base.tga"; >;		// Base texture
texture tex1 < string ResourceName = "Terrain.tga"; >;	// Terrain texture
texture tex2 < string ResourceName = "Color.dds"; >;		// Color texture
texture tex3 < string ResourceName = "Alpha.dds"; >;		// Terrain Alpha Mask
texture tex4 < string ResourceName = "BorderDirection.dds"; >;	// Borders texture
texture tex5 < string ResourceName = "ProvinceBorders.dds"; >;
texture tex6 < string ResourceName = "CountryBorders.dds"; >;
texture tex7 < string ResourceName = "TerraIncog.dds"; >;


float4x4 WorldMatrix		: World; 
float4x4 ViewMatrix		: View; 
float4x4 ProjectionMatrix	: Projection; 
float4x4 AbsoluteWorldMatrix;
float3	 LightDirection;
float	 vAlpha;

float	ColorMapHeight;
float	ColorMapWidth;

float	ColorMapTextureHeight;
float	ColorMapTextureWidth;

float	MapWidth;
float	MapHeight;

float	BorderWidth;
float	BorderHeight;

const float3 GREYIFY = float3( 0.212671, 0.715160, 0.072169 );

float3 ApplyFOWColor( float3 c, float FOW ) 
{
	float Grey = dot( c.rgb, GREYIFY );
	// return lerp( Grey.rrr * 0.4, c.rgb, FOW > 0.8 ? 1.0 : 0.3 );
	return c;
}

sampler BaseTexture  =
sampler_state
{
    Texture = <tex0>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = Linear; //None;
    AddressU = Wrap;
    AddressV = Wrap;
};

sampler TreeTexture  =
sampler_state
{
    Texture = <tex0>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = None;
    AddressU = Wrap;
    AddressV = Wrap;
};


sampler MapTexture  =
sampler_state
{
    Texture = <tex1>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = Linear; //None;
    AddressU = Wrap;
    AddressV = Wrap;
};

sampler NoiseTexture  =
sampler_state
{
    Texture = <tex5>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = Linear; //None;
    AddressU = Wrap;
    AddressV = Wrap;
};

sampler OverlayTexture  =
sampler_state
{
    Texture = <tex5>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = Linear; //None;
    AddressU = Wrap;
    AddressV = Wrap;
};

sampler StripesTexture  =
sampler_state
{
    Texture = <tex7>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = None;
    AddressU = Wrap;
    AddressV = Wrap;
};


sampler ColorTexture  =
sampler_state
{
    Texture = <tex4>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Wrap;
    AddressV = Wrap;
};

// used for political, religious etc etc..
sampler GeneralTexture  =
sampler_state
{
    Texture = <tex2>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler GeneralTexture2  =
sampler_state
{
    Texture = <tex3>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};


sampler TerrainAlphaTexture  =
sampler_state
{
    Texture = <tex2>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler TextureSheet  =
sampler_state
{
    Texture = <tex6>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None; //None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler BorderDirectionTexture  =
sampler_state
{
    Texture = <tex4>;
    MinFilter = Linear;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler WinterTexture  =
sampler_state
{
    Texture = <tex2>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler BorderTexture  =
sampler_state
{
    Texture = <tex2>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler QuadIndexTexture  =
sampler_state
{
    Texture = <tex1>;
    MinFilter = Point; //Linear;
    MagFilter = Point; //Linear;
    MipFilter = None;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler TerraIncognitaTextureTerrain =
sampler_state
{
    Texture = <tex2>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler TerraIncognitaTextureTree =
sampler_state
{
    Texture = <tex1>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};


struct VS_INPUT
{
    float2 vPosition  : POSITION;
    int2 vProvinceId : TEXCOORD0;
};

struct VS_BORDER_INPUT
{
	int4 vPositionBorderLookup : POSITION;
	float4 vBorderOffsetColor : COLOR0;
};

struct VS_INPUT_BEACH
{
    float2 vPosition  : POSITION;
    float4 vTerrainIndexColor : COLOR0;
  //  float2 vPixelCoord : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4  vPosition : POSITION;
    float3  vTexCoord0 : TEXCOORD0;	// third beein' lightIntensity
    float2  vTexCoord1 : TEXCOORD1;
    float2  vColorTexCoord : TEXCOORD2;

    float2  vBorderTexCoord0 : TEXCOORD3;
    float2  vBorderTexCoord1 : TEXCOORD4;

    float2  vTerrainTexCoord : TEXCOORD5;

    float2 vProvinceIndexCoord  : TEXCOORD6;
    float4 vBorderOffsetColor : COLOR0;
    
    
};

struct VS_MAP_OUTPUT
{
    float4  vPosition : POSITION;
    float3  vTexCoord0 : TEXCOORD0;	// third beein' lightIntensity
    float2  vTexCoord1 : TEXCOORD1;
    float2  vColorTexCoord : TEXCOORD2;
	float2	vProvinceId : TEXCOORD3;
    float2  vTerrainTexCoord : TEXCOORD4; 
    float4	vTerrainIndexColor : TEXCOORD5;
};

struct VS_OUTPUT_BEACH
{
    float4  vPosition : POSITION;
    float2  vTexCoordBase : TEXCOORD0;
    float2  vColorTexCoord : TEXCOORD1;
	// Later put this into ONE texcoord, this is easier for debugging etc..
    float3  vLightIntensity : TEXCOORD2;
    float2 vProvinceIndexCoord  : TEXCOORD3;
    float2 vBorderTexCoord0		: TEXCOORD4;
    
    float4 vTerrainIndexColor : TEXCOORD5;
    float2  vTexCoord1 : TEXCOORD6;
    float4 vBorderOffsetColor : COLOR0;
};

struct VS_INPUT_PTI
{
    float2 vPosition  : POSITION;
};

struct VS_OUTPUT_PTI
{
    float4  vPosition : POSITION;
};


struct VS_INPUT_TREE
{
    float3 vPosition : POSITION;
    float2 vTexCoord : TEXCOORD0;
};

struct VS_OUTPUT_TREE
{
    float4 vPosition   : POSITION;
    float2 vTexCoord   : TEXCOORD0;
    float2 vTexCoordTI : TEXCOORD1;
};

///////	//////////////////////////////////////////////////////////////////////////


float TerrainIndexOffsetX;
float TerrainIndexOffsetY;

float TerrainIndexSizeX;
float TerrainIndexSizeY;

#define TILE_STRETCH_FACTOR 8.0
#define TILE_STRETCH_DIVIDE 0.125 //1.0 / TILE_STRETCH_FACTOR


//Change these when changing num tiles....
const float NUM_TILES_X = 1.0/8.0;
const float NUM_TILES_Y = 1.0/8.0;


//32.0 = 64 textures    16.0 = 256 textures
#define NUM_TERRAINS_FACTOR 32.0 //NUM_TILES_X * 256.0 / Num Terrains?
#define X_CLAMP 0.125
#define Y_CLAMP 0.125
//...

struct TILE_STRUCT
{
    float2  vTexCoord0 : TEXCOORD0;
    float2  vTexCoord1 : TEXCOORD1;
    float2  vColorTexCoord : TEXCOORD2;
    float4 vTerrainIndexColor : COLOR0;
};

float4 GenerateTiles( TILE_STRUCT v )
{
	float4 IndexColor = tex2D( QuadIndexTexture, v.vTerrainIndexColor.xy ); //Coordinates for for quad texture of index colors
	float4 ColorColor = tex2D( ColorTexture, v.vTexCoord1 ); //Coordinates for colormap

	float2 noisecoord = v.vTexCoord0+0.5;
	float3 noisy = tex2D(NoiseTexture, noisecoord ).rgb;

	IndexColor *= 256.0; //size of colorbyte

	float4 IndexCoordX = fmod(IndexColor, NUM_TERRAINS_FACTOR); //x coord in tiles sheet
	IndexCoordX = trunc(IndexCoordX);
	float4 vIndexCoordX = IndexCoordX / NUM_TERRAINS_FACTOR;
	
	float4 IndexCoordY = IndexColor / NUM_TERRAINS_FACTOR; //y coord in tiles sheet
	IndexCoordY = trunc(IndexCoordY);
	float4 vIndexCoordY = IndexCoordY * NUM_TILES_Y;
	
	float2 TexCoord = v.vColorTexCoord + 0.5;
	TexCoord = frac( TexCoord ); // 0 => 1 range.. only thing we need is the decimal part.
	TexCoord.x = 1.0 - TexCoord.x;
	
	float2 PixelTexCoord = v.vTexCoord0;
	PixelTexCoord = frac( PixelTexCoord ); // 0 => 1 range.. only thing we need is the decimal part.
	
	TexCoord.x *= NUM_TILES_X;
	TexCoord.y *= (NUM_TILES_Y - 0.001);
	
	TexCoord.x = clamp( TexCoord.x, 0.001, X_CLAMP );
	TexCoord.y = clamp( TexCoord.y, 0.001, Y_CLAMP );
	
	float2 uvThis;
	uvThis.x = vIndexCoordX.x;
	uvThis.y = vIndexCoordY.x;

	float4 LeftTerrain = tex2D( TextureSheet, TexCoord + uvThis );
	
	uvThis.x = vIndexCoordX.y;
	uvThis.y = vIndexCoordY.y;
	
	float4 UpLeftTerrain = tex2D( TextureSheet, TexCoord + uvThis );
	
	uvThis.x = vIndexCoordX.z;
	uvThis.y = vIndexCoordY.z;

	float4 Terrain = tex2D( TextureSheet, TexCoord + uvThis ); //->left
	
	//return Terrain;	
	uvThis.x = vIndexCoordX.w;
	uvThis.y = vIndexCoordY.w;
	
	float4 UpTerrain = tex2D( TextureSheet, TexCoord + uvThis ); //->upleft
	
	
	
//	noisy.x = tex2D(NoiseTexture, noisecoord / 12 ).r;
//	noisy.y = tex2D(NoiseTexture, noisecoord / 2 + 1.5 ).r;
//	noisy.z = tex2D(NoiseTexture, noisecoord / 6 + 2.0 ).r;
			  		
	//noisy -= 0.5;
	//noisy *= 0.8;
	
	float4 x1 = lerp( LeftTerrain, Terrain, saturate( PixelTexCoord.x + noisy.x)  );
	float4 x2 = lerp( UpLeftTerrain, UpTerrain, saturate( PixelTexCoord.x + noisy.y) );
	float4 y1 = lerp( x1,x2, saturate( PixelTexCoord.y + noisy.z)  );


	// Comment out this line for no colormap
	y1 = ((y1*2.0f + ColorColor))/3.0f;
				
	return y1;	
}

const float vXStretch = 32; //higher gives textures more stretch change both values Note Performance
const float vYStretch = 32;

///////////////////////////////////////////////////////////////////////////////////////
// Map vertex shaders
///////////////////////////////////////////////////////////////////////////////////////
#define PROVINCE_LOOKUP_SIZE 256.0f
VS_MAP_OUTPUT VertexShader_Map_General(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;

	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);


	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );

	///////New Stufff

	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/vXStretch, WorldY/vYStretch );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	//Out.vColorTexCoord.xy = float2( WorldX, WorldY );
	
	WorldX = (ColorMapWidth * WorldPosition.x) / MapWidth;
	WorldY = (ColorMapHeight * WorldPosition.z) / MapHeight;
	Out.vTexCoord1.xy = float2( ( WorldX + X_OFFSET)/ColorMapTextureWidth, (WorldY + Z_OFFSET)/ColorMapTextureHeight );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	
	//// End new stuff


	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;
	
	return Out;
}

VS_MAP_OUTPUT VertexShader_Map_General_Low(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;

	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);


	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );

	///////New Stuff

	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/vXStretch, WorldY/vYStretch );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	//Out.vColorTexCoord.xy = float2( WorldX, WorldY );
	
	WorldX = (ColorMapWidth * WorldPosition.x) / MapWidth;
	WorldY = (ColorMapHeight * WorldPosition.z) / MapHeight;
	Out.vTexCoord1.xy = float2( ( WorldX + X_OFFSET)/ColorMapTextureWidth, (WorldY + Z_OFFSET)/ColorMapTextureHeight );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	
	//// End new stuff


	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;
	
	return Out;
}

VS_MAP_OUTPUT VertexShader_Map(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;

	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);


	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );

	///////New Stuff

	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/vXStretch, WorldY/vYStretch );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	//Out.vColorTexCoord.xy = float2( WorldX, WorldY );
	
	WorldX = (ColorMapWidth * WorldPosition.x) / MapWidth;
	WorldY = (ColorMapHeight * WorldPosition.z) / MapHeight;
	Out.vTexCoord1.xy = float2( ( WorldX + X_OFFSET)/ColorMapTextureWidth, (WorldY + Z_OFFSET)/ColorMapTextureHeight );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	
	//// End new stuff


	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;
	
	return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
// Map fragment shaders
///////////////////////////////////////////////////////////////////////////////////////

#define COLOR_VALUE 0.9
#define COLOR_LIGHTNESS 1.5

float4 White = float4( 1, 1, 1, 1 );

float4 PixelShader_Map2_0_General( VS_MAP_OUTPUT v ) : COLOR
{
	
	TILE_STRUCT s;
    s.vTexCoord1 = v.vTexCoord1;
    s.vColorTexCoord = v.vColorTexCoord;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
    s.vTexCoord0 = v.vTexCoord0.xy;
	
	float3 ParchmentColor = float3(0.95, 0.93, 0.85);
	float3 FOWColor = float3(0.25, 0.25, 0.25);
    
    float4 TerrainColor = GenerateTiles( s );
	float Grey = dot(TerrainColor.rgb, GREYIFY);  // Universal Grey
	
	float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
	
  
	// Country Effects
	float4 ReducedBaseColor = tex2D(GeneralTexture, vProvinceUV) - 0.7;
    float4 ReducedOccupierColor = tex2D(GeneralTexture2, vProvinceUV) - 0.7;
    float vColor = tex2D(StripesTexture, v.vTerrainTexCoord).a;
    float4 ProvinceColor = lerp(ReducedBaseColor, ReducedOccupierColor, vColor);
	
	float4 GreyTerrain = float4(Grey, Grey, Grey, 1.0);
	GreyTerrain.rgb = lerp(GreyTerrain.rgb, float3( 1.0, 1.0, 1.0 ), 0.6);
	float4 MetaColor = lerp(GreyTerrain, ProvinceColor, 0.4);
	MetaColor.rgb *= 1.45;
	
	
	// Uncolonised Non FOW Effects
  	float4 BaseColor = tex2D( GeneralTexture, vProvinceUV );
	float4 OccupierColor = tex2D( GeneralTexture2, vProvinceUV );
	float tvColor = tex2D( StripesTexture, v.vTerrainTexCoord ).a;
    float4 tProvinceColor = lerp(BaseColor, OccupierColor, tvColor);
	
	float3 UncolonisedRGB = float3(1.0, 1.0, 1.0); // Uncolonised
	float UncolonisedColorTolerance = 0.02; // Adjust this value to control the strictness of the color match
	float3 UncolonisedColorDifference = abs(tProvinceColor.rgb - UncolonisedRGB);
	float UncolonisedColorMatch = step(max(UncolonisedColorDifference.r, max(UncolonisedColorDifference.g, UncolonisedColorDifference.b)), UncolonisedColorTolerance);
	
	float4 UncolonisedTerrainColor = TerrainColor;
	UncolonisedTerrainColor.rgb = lerp(TerrainColor.rgb, ParchmentColor, 0.6);
	
	
	//Uncolonised FOW Effects
	float3 UncolonisedFOWRGB1 = float3(76.0 / 255.0, 76.0 / 255.0, 76.0 / 255.0); // Uncolonised with FOW
	float3 UncolonisedFOWRGB2 = float3(254.0 / 255.0, 245.0 / 255.0, 245.0 / 255.0); // Uncolonised with FOW when clicked
	
	float UncolonisedFOWColorTolerance = 0.01; // Adjust this value to control the strictness of the color match
	
	float3 UncolonisedFOWColorDifference1 = abs(tProvinceColor.rgb - UncolonisedFOWRGB1);
	float3 UncolonisedFOWColorDifference2 = abs(tProvinceColor.rgb - UncolonisedFOWRGB2);
	
	float UncolonisedFOWColorMatch1 = step(max(UncolonisedFOWColorDifference1.r, max(UncolonisedFOWColorDifference1.g, UncolonisedFOWColorDifference1.b)), UncolonisedFOWColorTolerance);
	float UncolonisedFOWColorMatch2 = step(max(UncolonisedFOWColorDifference2.r, max(UncolonisedFOWColorDifference2.g, UncolonisedFOWColorDifference2.b)), UncolonisedFOWColorTolerance);
	
	float UncolonisedFOWColorMatch = max(UncolonisedFOWColorMatch1, UncolonisedFOWColorMatch2);
	
	float4 UncolonisedFOWTerrainColor = TerrainColor;
	UncolonisedFOWTerrainColor.rgb = lerp(TerrainColor.rgb, ParchmentColor, 0.6);
	UncolonisedFOWTerrainColor.rgb = lerp(TerrainColor.rgb, FOWColor, 0.6);
   
	
	// Tie it together
	float4 FinalColor = lerp(MetaColor, UncolonisedTerrainColor, UncolonisedColorMatch);
	FinalColor = lerp(FinalColor, UncolonisedFOWTerrainColor, UncolonisedFOWColorMatch);
    //float4 FinalColor = lerp(MetaColor, TerrainColor, ColorMatch);
	
	//FinalColor.rgb *= COLOR_LIGHTNESS;
    
    return FinalColor;
}

float4 PixelShader_Map2_0_General_Low(VS_MAP_OUTPUT v) : COLOR
{
    TILE_STRUCT s;
    s.vTexCoord1 = v.vTexCoord1;
    s.vColorTexCoord = v.vColorTexCoord;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
    s.vTexCoord0 = v.vTexCoord0.xy;
    
    float4 TerrainColor = GenerateTiles(s);
    
    float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
	
	//float3 spaceColor = float3(Grey, Grey, Grey); // 0.95, 0.93, 0.85
  
    float4 Color1 = tex2D(GeneralTexture, vProvinceUV) - 0.7;
    float4 Color2 = tex2D(GeneralTexture2, vProvinceUV) - 0.7;
    float vColor = tex2D(StripesTexture, v.vTerrainTexCoord).a;
    float4 ProvinceColor = lerp(Color1, Color2, vColor);

    // Define the target RGB color
    float3 TargetRGB = float3(254.0 / 255.0, 254.0 / 255.0, 254.0 / 255.0); // Example: medium grey. Adjust as needed.
    
    // Define the tolerance for color matching
    float ColorTolerance = 0.75; // Adjust this value to control the strictness of the color match
    
    // Calculate the difference between the province color and the target RGB
    float3 ColorDifference = abs(ProvinceColor.rgb - TargetRGB);
    
    // Check if the color difference is within the tolerance for all channels
    float ColorMatch = step(max(ColorDifference.r, max(ColorDifference.g, ColorDifference.b)), ColorTolerance);
	
	float3 parchmentColor = float3(0.95, 0.93, 0.85);
	
    // Province Effects
	float Grey = dot(TerrainColor.rgb, GREYIFY);
	float4 GreyTerrain = lerp(float4(Grey, Grey, Grey, 1.0), TerrainColor, ColorMatch);
	GreyTerrain.rgb = lerp(GreyTerrain.rgb, float3( 1.0, 1.0, 1.0 ), 0.85);
	float4 MetaColor = lerp(GreyTerrain, ProvinceColor, 0.4);
	MetaColor.rgb *= 1.4;	// Color Lightness
	TerrainColor.rgb = lerp(TerrainColor.rgb, parchmentColor, 0.3);
    float4 FinalColor = lerp(MetaColor, TerrainColor, ColorMatch);
	
    return FinalColor;
    
}

float4 PixelShader_Map2_0( VS_MAP_OUTPUT v ) : COLOR
{
	
    TILE_STRUCT s;
    s.vTexCoord1 = v.vTexCoord1;
    s.vColorTexCoord = v.vColorTexCoord;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
    s.vTexCoord0 = v.vTexCoord0.xy;
	
	float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;

    float4 TestOutColor = GenerateTiles( s);
	TestOutColor.rgb *= LIGHTNESS;
	float4 OutColor = GenerateTiles( s);
	OutColor.rgb *= LIGHTNESS;
	
  
	float4 FogColor = tex2D( GeneralTexture, vProvinceUV );

	//Winter
	float Grey = dot( OutColor.rgb, float3( 1.0, 1.0, 1.0 ) );
	OutColor.rgb = lerp( OutColor.rgb, Grey.rrr, FogColor.b );
	OutColor.rgb += float3(FogColor.b,FogColor.b,FogColor.b)*0.3;
	
	// FOW /////////////////
	OutColor.rgb *= lerp(0.75, 1.0, FogColor.r);
	OutColor.rgb += FogColor.g;
	///////////////////
	
	return OutColor;
}

///////////////////////////////////////////////////////////////////////////////////////
// Beach shader
///////////////////////////////////////////////////////////////////////////////////////


VS_OUTPUT_BEACH VertexShader_Beach_General(const VS_INPUT_BEACH v )
{
	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	VS_OUTPUT_BEACH Out = (VS_OUTPUT_BEACH)0;
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);

	//float3 VertexNormal = mul( v.vNormal, WorldMatrix );

	//float3 direction = normalize( LightDirection );
	//Out.vLightIntensity.xy = max( dot( VertexNormal, -direction ), 0.5f );
	Out.vLightIntensity.z = vPosition.y;

	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );
	Out.vColorTexCoord.xy = float2( WorldPosition.x/BorderWidth, WorldPosition.z/BorderHeight );

	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTexCoordBase  = TerrainCoord;

	Out.vBorderTexCoord0 = float2( vPosition.x/BorderWidth, vPosition.z/BorderHeight );
	
	Out.vProvinceIndexCoord = v.vTerrainIndexColor;
	
	Out.vBorderTexCoord0.xy = float2( WorldPosition.x/8.0, WorldPosition.z/8.0 );
	Out.vTexCoordBase.xy = float2( WorldPosition.x, WorldPosition.z );
	
	float WorldX = (ColorMapWidth * WorldPosition.x) / MapWidth;
	float WorldY = (ColorMapHeight * WorldPosition.z) / MapHeight;
	
	Out.vColorTexCoord.xy = float2( ( WorldX + X_OFFSET)/ColorMapTextureWidth, (WorldY + Z_OFFSET)/ColorMapTextureHeight );
	
	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
		
	Out.vBorderOffsetColor = v.vTerrainIndexColor;
	
	float2 StripeTerrainCoord = WorldPosition.xz;
	StripeTerrainCoord += 0.5;
	StripeTerrainCoord /= 8.0;
	Out.vTerrainIndexColor.zw  = StripeTerrainCoord;
	
	return Out;
}

float4 PixelShader_Beach_General( VS_OUTPUT_BEACH v ) : COLOR
{
	
	TILE_STRUCT s;
	s.vTexCoord1 = v.vColorTexCoord;
	s.vColorTexCoord = v.vBorderTexCoord0;
	s.vTerrainIndexColor = v.vTerrainIndexColor;
	s.vTexCoord0 = v.vTexCoordBase;
	
	float2 borderoffset = v.vBorderOffsetColor.rg + float2(-0.001/256,0);
	
	float3 ParchmentColor = float3(0.95, 0.93, 0.85);
	float3 FOWColor = float3(0.25, 0.25, 0.25);

	float4 TerrainColor = GenerateTiles( s );
	float Grey = dot(TerrainColor.rgb, GREYIFY);  // Universal Grey

	// Country Effects
	float4 ReducedBaseColor = tex2D(GeneralTexture, borderoffset);
    float4 ReducedOccupierColor = tex2D(GeneralTexture2, borderoffset);
    float vColor = tex2D(StripesTexture, v.vTerrainIndexColor).a;
    float4 ProvinceColor = lerp(ReducedBaseColor, ReducedOccupierColor, vColor) - 0.7;
	
		// Uncolonised Non FOW Effects
  	float4 BaseColor = tex2D( GeneralTexture, borderoffset );
	float4 OccupierColor = tex2D( GeneralTexture2, borderoffset );
	float tvColor = tex2D( StripesTexture, v.vTerrainIndexColor ).a;
    float4 tProvinceColor = lerp(BaseColor, OccupierColor, tvColor);
	
	float4 GreyTerrain = float4(Grey, Grey, Grey, 1.0);
	GreyTerrain.rgb = lerp(GreyTerrain.rgb, float3( 1.0, 1.0, 1.0 ), 0.6);
	float4 MetaColor = lerp(GreyTerrain, ProvinceColor, 0.4);
	MetaColor.rgb *= 1.45;
	
	
	float3 UncolonisedRGB = float3(1.0, 1.0, 1.0); // Uncolonised
	float UncolonisedColorTolerance = 0.02; // Adjust this value to control the strictness of the color match
	float3 UncolonisedColorDifference = abs(tProvinceColor.rgb - UncolonisedRGB);
	float UncolonisedColorMatch = step(max(UncolonisedColorDifference.r, max(UncolonisedColorDifference.g, UncolonisedColorDifference.b)), UncolonisedColorTolerance);
	
	//Uncolonised Effects
	float4 UncolonisedTerrainColor = TerrainColor;
	UncolonisedTerrainColor.rgb = lerp(TerrainColor.rgb, ParchmentColor, 0.6);
	
	
	//Uncolonised FOW Effects
	float3 UncolonisedFOWRGB1 = float3(76.0 / 255.0, 76.0 / 255.0, 76.0 / 255.0); // Uncolonised with FOW
	float3 UncolonisedFOWRGB2 = float3(254.0 / 255.0, 245.0 / 255.0, 245.0 / 255.0); // Uncolonised with FOW when clicked
	
	float UncolonisedFOWColorTolerance = 0.01; // Adjust this value to control the strictness of the color match
	
	float3 UncolonisedFOWColorDifference1 = abs(tProvinceColor.rgb - UncolonisedFOWRGB1);
	float3 UncolonisedFOWColorDifference2 = abs(tProvinceColor.rgb - UncolonisedFOWRGB2);
	
	float UncolonisedFOWColorMatch1 = step(max(UncolonisedFOWColorDifference1.r, max(UncolonisedFOWColorDifference1.g, UncolonisedFOWColorDifference1.b)), UncolonisedFOWColorTolerance);
	float UncolonisedFOWColorMatch2 = step(max(UncolonisedFOWColorDifference2.r, max(UncolonisedFOWColorDifference2.g, UncolonisedFOWColorDifference2.b)), UncolonisedFOWColorTolerance);
	float UncolonisedFOWColorMatch = max(UncolonisedFOWColorMatch1, UncolonisedFOWColorMatch2);
	
	float4 UncolonisedFOWTerrainColor = TerrainColor;
	UncolonisedFOWTerrainColor.rgb = lerp(TerrainColor.rgb, ParchmentColor, 0.6);
	UncolonisedFOWTerrainColor.rgb = lerp(TerrainColor.rgb, FOWColor, 0.6);
   
	
	// Tie it together
	float4 FinalColor = lerp(MetaColor, UncolonisedTerrainColor, UncolonisedColorMatch);
	FinalColor = lerp(FinalColor, UncolonisedFOWTerrainColor, UncolonisedFOWColorMatch);
	FinalColor.a = 1;
	
	return FinalColor;
}

float4 PixelShader_Beach_General_Low( VS_OUTPUT_BEACH v ) : COLOR
{
	float4 Color = tex2D( GeneralTexture, v.vProvinceIndexCoord ); //  - 0.7
	
	float4 OutColor;
	OutColor.rgb = Color.rgb;
	OutColor.a = 1;
	
	float4 ColorColor = tex2D( ColorTexture, v.vColorTexCoord ); //Coordinates for colormap
    	
	//float4 OutColor = float4( COLOR_VALUE,COLOR_VALUE,COLOR_VALUE,1);
	OutColor.rgb = lerp(ColorColor.rgb, float3(OutColor.r,OutColor.g,OutColor.b), 0.3);
	
	// OutColor.rgb *= COLOR_LIGHTNESS;

	//float vAlpha = 1;
	//if ( v.vLightIntensity.z < 0.3f )
	//{
	//	vAlpha = 1.2;
	//	vAlpha += ( v.vLightIntensity.z - 0.3f)*0.7f;
	//	vAlpha = saturate( vAlpha );	
	//	vAlpha *= vAlpha;
	//}

	//OutColor.a = vAlpha;
	return OutColor;
}

///////////////////////////////////////////////////////////////////////////////////////
// Border shader
/////////////////////////////////////////////////////////////////////////////////
struct VS_BORDER_OUTPUT
{
    float4  vPosition : POSITION;
    float4  vUV_ProvUV : TEXCOORD0;
    float4 vBorderOffsetColor : TEXCOORD1; 
};

#define MAX_HALF_SIZE 1000.0f
#define HALF_PIXEL 0.5f
#define BORDER_PADDING_OFFSET 0.02f;

VS_BORDER_OUTPUT VertexShader_Map_Border(const VS_BORDER_INPUT v )
{
	VS_BORDER_OUTPUT Out;
	
	float2 vSign = sign( v.vPositionBorderLookup.xy );
	Out.vUV_ProvUV.xy = saturate( vSign );
	Out.vUV_ProvUV.x *= 1.0f - 2 * BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.x += BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.x *= 0.8 / 32;
	Out.vUV_ProvUV.y *= 0.25f - 2 * BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.y += BORDER_PADDING_OFFSET;
	
	vSign *= -MAX_HALF_SIZE;
	vSign += HALF_PIXEL + v.vPositionBorderLookup.xy;
	float4 vPosition = float4( vSign.x , LAND_ALT + 0.02, vSign.y, 1 ); // Increase z slightly to remove z-fighting
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);

	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);
	
	Out.vUV_ProvUV.zw = v.vPositionBorderLookup.zw;
	Out.vBorderOffsetColor = v.vBorderOffsetColor;
	
	return Out;
}

#define BORDERLOOKUP_SIZE 512.0f

float4 PixelShader_Map2_0_Border( VS_BORDER_OUTPUT v ) : COLOR
{
	// Do some magic to transform the position to usable uv-coordinates
	float2 TexCoord = v.vUV_ProvUV.xy;
	TexCoord.y /= 2;
	
	float2 BorderUV = v.vUV_ProvUV.zw + 0.5f;
	BorderUV /= BORDERLOOKUP_SIZE;
	
	float4 BorderTypeColor = tex2D( BorderDirectionTexture, BorderUV );
	
	float CornerOffset = 0;
	float SettingsBitMask = ( BorderTypeColor.b * 255 );
	if ( abs(SettingsBitMask - 1) < 0.01 )
	{
		CornerOffset = 1;
	}

	if ( abs(SettingsBitMask - 2) < 0.01  )
	{
	  TexCoord.y += 0.5;
	}

	if ( abs(SettingsBitMask - 3) < 0.01  )
	{
		CornerOffset = 1;
		TexCoord.y += 0.5;
	}
	
	float2 TexCoord2 = TexCoord;
	float2 TexCoord3 = TexCoord;
	
	TexCoord.x += (v.vBorderOffsetColor.b * CornerOffset) + (BorderTypeColor.a * (1.0 - CornerOffset));
	TexCoord.y += ( BorderTypeColor.a * CornerOffset );
	const float BIAS = -0.8;
	float4 ProvinceBorder = tex2Dbias( BorderTexture, float4(TexCoord, 0, BIAS) );
	//float4 ProvinceBorder = tex2D( BorderTexture, TexCoord );
	
	TexCoord2.x += BorderTypeColor.r;
	TexCoord2.y += 0.125; // 0.25
	float4 CountryBorder = tex2Dbias( BorderTexture, float4(TexCoord2, 0, BIAS) );
	//float4 CountryBorder = tex2D( BorderTexture, TexCoord2 );
		
	TexCoord3.x += v.vBorderOffsetColor.a * CornerOffset + BorderTypeColor.g;
	TexCoord3.y += 0.25; // 0.5
	TexCoord3.y += (BorderTypeColor.a * CornerOffset);
	
	float4 DiagBorder = tex2D( BorderTexture, TexCoord3 );

	ProvinceBorder.rgb *= ProvinceBorder.a;
	CountryBorder.rgb *= CountryBorder.a;
	DiagBorder.rgb *= DiagBorder.a;

	float4 OutColor = 0;
	
	OutColor.rgb = ProvinceBorder.rgb*ProvinceBorder.a;
	OutColor.a = max( ProvinceBorder.a, CountryBorder.a );
	OutColor.a = max( OutColor.a, DiagBorder.a );
	
	OutColor.rgb = CountryBorder.rgb * CountryBorder.a + OutColor.rgb*( 1.0f - CountryBorder.a );
	OutColor.rgb = max( OutColor.rgb, DiagBorder.rgb );

	return OutColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////


VS_OUTPUT_BEACH VertexShader_Beach(const VS_INPUT_BEACH v )
{
	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	VS_OUTPUT_BEACH Out = (VS_OUTPUT_BEACH)0;
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);

	//float3 VertexNormal = mul( v.vNormal, WorldMatrix );

	//float3 direction = normalize( LightDirection );
	//Out.vLightIntensity.xy = max( dot( VertexNormal, -direction ), 0.5f );
	Out.vLightIntensity.z = vPosition.y;

	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );
		
	Out.vBorderTexCoord0.xy = float2( WorldPosition.x/8.0, WorldPosition.z/8.0 );
	Out.vTexCoordBase.xy = float2( WorldPosition.x, WorldPosition.z );
	
	float WorldX = (ColorMapWidth * WorldPosition.x) / MapWidth;
	float WorldY = (ColorMapHeight * WorldPosition.z) / MapHeight;
	
	Out.vColorTexCoord.xy = float2( ( WorldX + X_OFFSET)/ColorMapTextureWidth, (WorldY + Z_OFFSET)/ColorMapTextureHeight );
	
	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	Out.vBorderOffsetColor = v.vTerrainIndexColor;
	
	return Out;
}

float4 PixelShader_Beach( VS_OUTPUT_BEACH v ) : COLOR
{
	TILE_STRUCT s;
    s.vTexCoord1 = v.vColorTexCoord;
    s.vColorTexCoord = v.vBorderTexCoord0;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
    s.vTexCoord0 = v.vTexCoordBase;

    float4 OutColor = GenerateTiles( s );
	
	OutColor.rgb *= LIGHTNESS;
    //return OutColor;
	// FOW /////////////////
	
	float3 FogColor = tex2D( GeneralTexture, v.vBorderOffsetColor.rg + float2(-0.001/256,0)).rgb;
	
	OutColor.rgb = ApplyFOWColor( OutColor.rgb, FogColor.r);
	OutColor.rgb += FogColor.g*1.1;
	
	//Winter
	float Grey = dot( OutColor.rgb, GREYIFY );
	OutColor.rgb = lerp( OutColor.rgb, Grey.rrr, FogColor.b );
	OutColor.rgb += float3(FogColor.b,FogColor.b,FogColor.b)*0.3;
	
	OutColor.rgb *= LIGHTNESS;
    
	return OutColor;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////


VS_OUTPUT_PTI VertexShader_PTI(const VS_INPUT_PTI v )
{
	VS_OUTPUT_PTI Out = (VS_OUTPUT_PTI)0;
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(v.vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);
	
	return Out;
}

float4 PixelShader_PTI( VS_OUTPUT_PTI v ) : COLOR
{
	return float4( 0.1, 0.5, 1, 1 );
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

VS_OUTPUT_TREE VertexShader_TREE(const VS_INPUT_TREE v )
{
	float4 vPosition = float4( v.vPosition, 1.0 );
	vPosition.y += LAND_ALT;
	VS_OUTPUT_TREE Out = (VS_OUTPUT_TREE)0;
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);
	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );
	Out.vTexCoordTI = float2( WorldPosition.x/BorderWidth, WorldPosition.z/BorderHeight );

	Out.vTexCoord = v.vTexCoord;

	return Out;
}

float4 PixelShader_TREE( VS_OUTPUT_TREE v ) : COLOR
{
	float4 OutColor = tex2D( TreeTexture, v.vTexCoord );
//	float vFOW = ( tex2D( TerraIncognitaTextureTree, v.vTexCoordTI ).g - 0.25 )*1.33;
//	if ( vFOW < 0 )
	//	OutColor.rgb += vFOW;
	//OutColor.a *= vAlpha;
	
	//float Grey = dot( OutColor.rgb, GREYIFY );
	//float winter = 1.2;
	
	//OutColor.rgb = lerp( OutColor.rgb, Grey.rrr, winter );
	//OutColor.rgb += float3(winter,winter,winter)*0.3;
	
	//OutColor.rgb = lerp(OutColor.rgb, float3(127.0/255.0,28.0/255.0,28.0/255.0), 0.6);
	return OutColor;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique TerrainShader_Graphical
{
	pass p0
	{
		VertexShader = compile vs_3_0 VertexShader_Map();
		PixelShader = compile ps_3_0 PixelShader_Map2_0();
	}
}

technique TerrainShader_General
{
	pass p0
	{
		VertexShader = compile vs_3_0 VertexShader_Map_General();
		PixelShader = compile ps_3_0 PixelShader_Map2_0_General();
	}
}

technique TerrainShader_General_Low
{
	pass p0
	{
		VertexShader = compile vs_3_0 VertexShader_Map_General_Low();
		PixelShader = compile ps_3_0 PixelShader_Map2_0_General_Low();
	}
}

technique TerrainShader_Border
{
	pass p0
	{
		ALPHABLENDENABLE = True;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		
		VertexShader = compile vs_3_0 VertexShader_Map_Border();
		PixelShader = compile ps_3_0 PixelShader_Map2_0_Border();
	}
}


technique BeachShader_Graphical
{
	pass p0
	{
		ALPHATESTENABLE = True;
	
		ALPHABLENDENABLE = True;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
			
		VertexShader = compile vs_3_0 VertexShader_Beach();
		PixelShader = compile ps_3_0 PixelShader_Beach();
	}
}


technique BeachShader_General
{
	pass p0
	{		
		
		//ALPHATESTENABLE = True;
		//ALPHABLENDENABLE = True;
		//SrcBlend = SRCALPHA;
		//§DestBlend = INVSRCALPHA;
				
		VertexShader = compile vs_3_0 VertexShader_Beach_General();
		PixelShader = compile ps_3_0 PixelShader_Beach_General();
	}
}

technique BeachShader_General_Low
{
	pass p0
	{
		VertexShader = compile vs_3_0 VertexShader_Beach_General();
		PixelShader = compile ps_3_0 PixelShader_Beach_General_Low();
	}
}

technique PTIShader
{
	pass p0
	{
		fvf = XYZ;

		LightEnable[0] = false;
		Lighting = False;

		ALPHABLENDENABLE = True;

		ColorOp[0] = Modulate;
		ColorArg1[0] = Texture;
		ColorArg2[0] = current;
  
		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;

		VertexShader = compile vs_3_0 VertexShader_PTI();
		PixelShader = compile ps_3_0 PixelShader_PTI();
	}
}

technique TreeShader
{
	pass p0
	{
		ALPHABLENDENABLE = True;
		ALPHATESTENABLE = True;

		VertexShader = compile vs_3_0 VertexShader_TREE();
		PixelShader = compile ps_3_0 PixelShader_TREE();
	}
}
