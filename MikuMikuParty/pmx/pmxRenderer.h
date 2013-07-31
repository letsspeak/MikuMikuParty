//
//  pmxRenderer.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//

#import <vector>
#import <map>

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

#import "pmxReader.h"
#import "vmdReader.h"
#import "vmdMotionProviderPMX.h"
#import "SGXSkininngEvaluator.h"
#import "PVRTVector.h"
#import "Texture2D.h"

const int32_t PMX_MATRIX_UNDEFINED = -1;
const int32_t PMX_NUM_SHADERS = 4;

enum PMX_SHADER_INDEX {
	PMX_SHADER_NOTEXTURE = 0,
	PMX_SHADER_TEXTURE = 1,
	PMX_SHADER_SKIN = 2,
	PMX_SHADER_SKIN_TEXTURE = 3,
};

struct pmx_renderer_vertex
{
	float pos[3];
	float normal_vec[3];
	float uv[2];
	uint8_t bone[4];
};

struct pmx_skinanimation_vertex
{
	float pos[3];
};

struct PMX_DRAW_LIST
{
	bool	bSkinMesh;
	int32_t iMaterialIndex;
	int32_t iNumIndices;
	std::vector< int32_t > vecMatrixPalette;
};

struct PMX_SHADER_PARAMS
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

class pmxRenderer
{
	vmdMotionProviderPMX* _motionProvider;
  
	PMX_SHADER_PARAMS _shaders[ PMX_NUM_SHADERS ];
  
	PVRTMat4 _mProjection;
	PVRTMat4 _mView;
  
	GLuint _vboRender;
	GLuint _vboIndex;
  
	GLuint _vboSkinAnimation;
	int32_t _iNumSkinAnimations;
	int32_t _iCurrentSkinAnimationIndex;
	int32_t _iSizeSkinanimatinVertices;
	std::vector< pmx_skinanimation_vertex* > _vecSkinAnimation;
  
	std::vector< PMX_DRAW_LIST > _vecDrawList;
	std::vector< pmx_material > _vecMaterials;
  
  uint8_t _vertexIndexSize;
  int32_t _iNumIndices;
  
	void createVbo( pmxReader * pReader );
	void createIndexBuffer( pmxReader* pReader );
	void loadMaterials( pmxReader* pReader );
  
	BOOL compileShader( GLuint *shader, const GLenum type, const NSString *file );
	BOOL linkProgram( const GLuint prog );
	BOOL validateProgram(const GLuint prog );
	BOOL loadShaders( PMX_SHADER_PARAMS* params, NSString* strVsh, NSString* strFsh );
  
	bool partitionMeshes( pmxReader* reader );
	bool partitioning( pmxReader* reader, SkinningEvaluator* eval, int32_t iStart, int32_t iNumIndices );
	static NSComparisonResult compare(NSNumber *first, NSNumber *second, NSDictionary *dic);
	bool createMatrixMapping( NSArray* sortedKeys, NSDictionary* dicMatrixRefArray );
  
	std::vector< pmx_renderer_vertex > _vecMappedVertex;
	std::map< int32_t, std::map< int32_t, int64_t> > _mapVertexMapping;
	
	int32_t getMappedVertices( std::vector<pmx_vertex> vecVertex, const int32_t iVertexIndex, const int64_t iVertexKey, const bool bSkining );
	int32_t getMappedBone( std::vector< int32_t >* pVec, const int32_t iBone );
  
	bool _bPerformSkinmeshAnimation;
  
public:
	pmxRenderer();
	~pmxRenderer();
	bool init( pmxReader* reader, vmdReader* motion );
	bool unload();
	
	void update( const double dTime );
	void render();
};

