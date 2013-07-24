//
//  RendererDefine.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//

#ifndef MikuMikuParty_RendererDefine_h
#define MikuMikuParty_RendererDefine_h

const int32_t MATRIX_UNDEFINED = -1;
const int32_t NUM_SHADERS = 4;

enum SHADER_INDEX {
	SHADER_NOTEXTURE = 0,
	SHADER_TEXTURE = 1,
	SHADER_SKIN = 2,
	SHADER_SKIN_TEXTURE = 3,
};

struct renderer_vertex
{
	float pos[3];
	float normal_vec[3];
	float uv[2];
	uint8_t bone[4];
};

struct skinanimation_vertex
{
	float pos[3];
};

struct DRAW_LIST
{
	bool	bSkinMesh;
	int32_t iMaterialIndex;
	int32_t iNumIndices;
	std::vector< int32_t > vecMatrixPalette;
};

struct SHADER_PARAMS
{
	GLuint _program;
	GLuint _uiLight0;
	GLuint _uiMaterialDiffuse;
	GLuint _uiMaterialAmbient;
	GLuint _uiMaterialSpecular;
	
	GLuint _uiMatrixPalette;
	GLuint _uiMatrixP;
  
	GLuint _uiSkinWeight;
};

#endif
