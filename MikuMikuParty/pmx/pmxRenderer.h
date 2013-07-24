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
#import "RendererDefine.h"

class pmxRenderer
{
	vmdMotionProviderPMX* _motionProvider;
  
	SHADER_PARAMS _shaders[ NUM_SHADERS ];
  
	PVRTMat4 _mProjection;
	PVRTMat4 _mView;
  
	GLuint _vboRender;
	GLuint _vboIndex;
  
	GLuint _vboSkinAnimation;
	int32_t _iNumSkinAnimations;
	int32_t _iCurrentSkinAnimationIndex;
	int32_t _iSizeSkinanimatinVertices;
	std::vector< skinanimation_vertex* > _vecSkinAnimation;
  
	std::vector< DRAW_LIST > _vecDrawList;
	std::vector< pmx_material > _vecMaterials;
	
	void createVbo( pmxReader * pReader );
	void createIndexBuffer( pmxReader* pReader );
	void loadMaterials( pmxReader* pReader );
  
	BOOL compileShader( GLuint *shader, const GLenum type, const NSString *file );
	BOOL linkProgram( const GLuint prog );
	BOOL validateProgram(const GLuint prog );
	BOOL loadShaders( SHADER_PARAMS* params, NSString* strVsh, NSString* strFsh );
  
	bool partitionMeshes( pmxReader* reader );
	bool partitioning( pmxReader* reader, SkinningEvaluator* eval, int32_t iStart, int32_t iNumIndices );
	static NSComparisonResult compare(NSNumber *first, NSNumber *second, NSDictionary *dic);
	bool createMatrixMapping( NSArray* sortedKeys, NSDictionary* dicMatrixRefArray );
  
	std::vector< renderer_vertex > _vecMappedVertex;
	std::map< int32_t, std::map< int32_t, int32_t> > _mapVertexMapping;
	
	int32_t getMappedVertices( mmd_vertex* pVertex, const int32_t iVertexIndex, const uint32_t iVertexKey, const bool bSkining );
	int16_t getMappedBone( std::vector< int32_t >* pVec, const int32_t iBone );
  
	bool _bPerformSkinmeshAnimation;
public:
	pmxRenderer();
	~pmxRenderer();
	bool init( pmxReader* reader, vmdReader* motion );
	bool unload();
	
	void update( const double dTime );
	void render();
};

