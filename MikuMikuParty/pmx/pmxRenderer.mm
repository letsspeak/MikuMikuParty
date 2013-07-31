//
//  pmxRenderer.mm
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//

#import "pmxRenderer.h"
#import "NSString+Charset.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static int getMappedBoneCallCount = 0;
static int getMappedVerticesCallCount = 0;

//#define DUMP_PARTITIONS (1)

enum {
	ATTRIB_VERTEX,
	ATTRIB_NORMAL,
	ATTRIB_UV,
	ATTRIB_BONE,
	ATTRIB_SKINANIMATION,
};

#pragma mark Ctor
pmxRenderer::pmxRenderer()
{
}
#pragma mark Dtor
pmxRenderer::~pmxRenderer()
{
	unload();
	
	for( int32_t i = 0; i < sizeof( _shaders ) / sizeof( _shaders[ 0 ] ); ++i)
	{
		if (_shaders[ i ]._program)
		{
			glDeleteProgram(_shaders[ i ]._program);
		}
	}
}

bool pmxRenderer::unload()
{
	if (_vboRender)
	{
		glDeleteBuffers(1, &_vboRender);
		_vboRender = NULL;
	}
  
	if (_vboIndex)
	{
		glDeleteBuffers(1, &_vboIndex);
		_vboIndex = NULL;
	}
  
	if( _vboSkinAnimation )
	{
		glDeleteBuffers( 1, &_vboSkinAnimation );
		_iNumSkinAnimations = 0;
    
		for( int32_t i = 0; i < _vecSkinAnimation.size(); ++i )
		{
			delete [] _vecSkinAnimation[ i ];
		}
		_vecSkinAnimation.clear();
	}
	
	for( int32_t i = 0; i < _vecMaterials.size(); ++i )
	{
		if( _vecMaterials[ i ]._tex2D )
		{
			[_vecMaterials[ i ]._tex2D release];
			_vecMaterials[ i ]._tex2D = nil;
		}
	}
	
	delete _motionProvider;
	_motionProvider = NULL;
	_vecDrawList.clear();
	_vecMaterials.clear();
	return true;
}

#pragma mark Update
void pmxRenderer::update( const double dTime )
{
	if( _motionProvider )
	{
		_motionProvider->update( dTime );
	}
}

#pragma mark Render
void pmxRenderer::render()
{
  // Bind the VBO
  glBindBuffer(GL_ARRAY_BUFFER, _vboRender);
	
  int32_t iStride = sizeof(pmx_renderer_vertex);
  // Pass the vertex data
  glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, iStride, BUFFER_OFFSET( 0 ));
  glEnableVertexAttribArray(ATTRIB_VERTEX);
  
  glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, iStride, BUFFER_OFFSET( 3 * sizeof(GLfloat) ));
  glEnableVertexAttribArray(ATTRIB_NORMAL);
  
  glVertexAttribPointer(ATTRIB_BONE, 4, GL_UNSIGNED_BYTE, GL_FALSE, iStride, BUFFER_OFFSET( 8 * sizeof(GLfloat) ));
  glEnableVertexAttribArray(ATTRIB_BONE);
	
	// Bind the IB
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vboIndex);
  
	//State
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
	glCullFace(GL_CCW);
  
  // Feed Projection and Model View matrices to the shaders
  PVRTMat4 mVP = _mProjection * _mView;
	
	int32_t iOffset = 0;
	
	GLuint lastProgram = -1;
	GLuint currentProgram = -1;
	
	std::vector<bone_stats>* matrixPalette = NULL;
  
	float fWeight;
	if( _motionProvider )
	{
		matrixPalette = _motionProvider->getMatrixPalette();
    
//		if( _bPerformSkinmeshAnimation )
//		{
//			int32_t iSkinAnimationIndex = _motionProvider->getSkinAnimationParameters( fWeight );
//
//			if( iSkinAnimationIndex != _iCurrentSkinAnimationIndex )
//			{
//				_iCurrentSkinAnimationIndex = iSkinAnimationIndex;
//				//Update vbo
//				glBindBuffer(GL_ARRAY_BUFFER, _vboSkinAnimation);
//				glBufferSubData(GL_ARRAY_BUFFER, 0, _iSizeSkinanimatinVertices * sizeof(pmx_skinanimation_vertex), _vecSkinAnimation[ _iCurrentSkinAnimationIndex-1 ] );
//			}
//		}
	}
	
	std::vector< PMX_DRAW_LIST >::iterator itBegin = _vecDrawList.begin();
	std::vector< PMX_DRAW_LIST >::iterator itEnd = _vecDrawList.end();
	for( ;itBegin != itEnd; ++itBegin )
	{
		int32_t iNumIndices = itBegin->iNumIndices;
		int32_t i = itBegin->iMaterialIndex;
		
		//Set materials
		if( _vecMaterials[ i ].alpha < 1.0f )
			glEnable(GL_BLEND);
		else
			glDisable(GL_BLEND);
		
//		if( _vecMaterials[ i ].edge_flag )
			glDisable(GL_CULL_FACE);
//		else
//			glEnable(GL_CULL_FACE);
		
		
		int32_t iShaderIndex = PMX_SHADER_NOTEXTURE;
		
		if( _vecMaterials[ i ]._tex )
		{
			iShaderIndex = PMX_SHADER_TEXTURE;
			glUseProgram(_shaders[iShaderIndex]._program);
			glEnable(GL_TEXTURE_2D);
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, _vecMaterials[ i ]._tex);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			// Pass the texture coordinates data
			glVertexAttribPointer(ATTRIB_UV, 2, GL_FLOAT, GL_FALSE, iStride, BUFFER_OFFSET( (3 * sizeof(GLfloat)) + (3 * sizeof(GLfloat)) ) );
			glEnableVertexAttribArray(ATTRIB_UV);
			currentProgram = _shaders[iShaderIndex]._program;
		}
		else
		{
			iShaderIndex = PMX_SHADER_NOTEXTURE;
			glUseProgram(_shaders[iShaderIndex]._program);
			glDisable(GL_TEXTURE_2D);
			glDisableVertexAttribArray(ATTRIB_UV);
			currentProgram = _shaders[iShaderIndex]._program;
		}
		
//		//
//		//
//		//Bind skin animation
//		if( _bPerformSkinmeshAnimation )
//		{
//			if( itBegin->bSkinMesh )
//			{
//				glBindBuffer(GL_ARRAY_BUFFER, _vboSkinAnimation);
//				
//				iStride = sizeof(pmx_skinanimation_vertex);
//				glVertexAttribPointer(ATTRIB_SKINANIMATION, 3, GL_FLOAT, GL_FALSE, iStride, BUFFER_OFFSET( 0 ));
//				glEnableVertexAttribArray(ATTRIB_SKINANIMATION);
//				
//				if( iShaderIndex == PMX_SHADER_NOTEXTURE )
//					iShaderIndex = PMX_SHADER_SKIN;
//				else
//					iShaderIndex = PMX_SHADER_SKIN_TEXTURE;
//				
//				glUseProgram(_shaders[iShaderIndex]._program);
//				currentProgram = _shaders[iShaderIndex]._program;
//				
//				glUniform1f( _shaders[iShaderIndex]._uiSkinWeight, fWeight );
//				
//			}
//			else
//			{
//				glDisableVertexAttribArray(ATTRIB_SKINANIMATION);
//			}
//      
//		}
		
		glUniform4f( _shaders[iShaderIndex]._uiMaterialDiffuse, _vecMaterials[ i ].diffuse_color[ 0 ],
                _vecMaterials[ i ].diffuse_color[ 1 ],
                _vecMaterials[ i ].diffuse_color[ 2 ],
                _vecMaterials[ i ].alpha );
		glUniform4f( _shaders[iShaderIndex]._uiMaterialSpecular, _vecMaterials[ i ].specular_color[ 0 ],
                _vecMaterials[ i ].specular_color[ 1 ],
                _vecMaterials[ i ].specular_color[ 2 ],
                _vecMaterials[ i ].intensity );
		
		glUniform3fv( _shaders[iShaderIndex]._uiMaterialAmbient, 1, _vecMaterials[ i ].ambient_color );
		
//		//
//		//Set up matrix palette
//		//
//		if( _motionProvider )
//		{
//			std::vector< int32_t >& vec = itBegin->vecMatrixPalette;
//			for( int32_t iPaletteIndex = 0; iPaletteIndex < BATCH_DIVISION_THRESHOLD; ++iPaletteIndex )
//			{
//				if( vec[ iPaletteIndex ] != -1 )
//				{
//          // TODO : invalid value of vec[ iPaletteIndex ]...
//          if ( vec[ iPaletteIndex] < (*matrixPalette).size() ){
//            glUniformMatrix4fv( _shaders[iShaderIndex]._uiMatrixPalette + iPaletteIndex * 4, 1, GL_FALSE,
//                               (*matrixPalette)[ vec[ iPaletteIndex ] ].mat.ptr());
//          }
//				}
//        
//			}
//      
//		}
    
		if( currentProgram != lastProgram )
		{
			glUniformMatrix4fv( _shaders[iShaderIndex]._uiMatrixP, 1, GL_FALSE,  mVP.ptr());
			glUniform3f( _shaders[iShaderIndex]._uiLight0, 0.f, 10.f, 1.f );
		}
		lastProgram = currentProgram;
    
    if ( _vertexIndexSize == 1) {
      glDrawElements(GL_TRIANGLES, iNumIndices, GL_UNSIGNED_BYTE, BUFFER_OFFSET(iOffset * sizeof(uint8_t) ));
    } else if ( _vertexIndexSize == 2) {
      glDrawElements(GL_TRIANGLES, iNumIndices, GL_UNSIGNED_SHORT, BUFFER_OFFSET(iOffset * sizeof(uint16_t) ));
    } else if (_vertexIndexSize == 4) {
      glDrawElements(GL_TRIANGLES, iNumIndices, GL_UNSIGNED_INT, BUFFER_OFFSET(iOffset * sizeof(uint32_t) ));
//                   GL_UNSIGNED_SHORT, BUFFER_OFFSET(iOffset * sizeof(uint16_t) ));
    }
    iOffset += iNumIndices;
	}
	
}

#pragma mark Init
bool pmxRenderer::init( pmxReader* reader, vmdReader* motion )
{
	if( reader == NULL )
		return false;
	
	_bPerformSkinmeshAnimation = true;
//	_bPerformSkinmeshAnimation = false;
  
  _vertexIndexSize = reader->vertexIndexSize();
  NSLog(@"_vertexIndexSize = %d", _vertexIndexSize);
  
	if( motion != NULL )
	{
		_motionProvider = new vmdMotionProviderPMX();
		_motionProvider->bind( reader, motion );
		partitionMeshes( reader );
	}
	else
	{
		createVbo( reader );
		createIndexBuffer( reader );
	}
	
	//Load materials
	loadMaterials( reader );
  
	if( _shaders[ 0 ]._program == 0 )
	{
		NSString* strVShaders[PMX_NUM_SHADERS] = { @"ShaderPlain", @"ShaderPlainTex", @"ShaderPlainSkin",  @"ShaderPlainSkin" };
		NSString* strFShaders[PMX_NUM_SHADERS] = { @"ShaderPlain", @"ShaderPlainTex", @"ShaderPlainSkin",  @"ShaderPlainTex" };
		for( int32_t i = 0; i < PMX_NUM_SHADERS; ++i )
		{
      NSLog(@"loading sharders %d", i);
			loadShaders(&_shaders[ i ], strVShaders[ i ], strFShaders[ i ] );
//#if defined(DEBUG)
			if (!validateProgram(_shaders[ i ]._program))
			{
				NSLog(@"Failed to validate program: %d", _shaders[ i ]._program);
        //				return false;
			}
//#endif
		}
	}
	
	//Init matrices
	float fAspect = 320.f/480.f;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		fAspect = 0.75;
  
  const float CAM_FOV  = M_PI_2/4;
  const float CAM_NEAR = 0.5f;
	const float CAM_Z = 64.f;
	
  bool bRotate = false;
  _mProjection = PVRTMat4::PerspectiveFovFloatDepthRH(CAM_FOV, fAspect, CAM_NEAR, PVRTMat4::OGL, bRotate);
  _mView = PVRTMat4::LookAtRH(PVRTVec3(0.f, 10.f, -CAM_Z), PVRTVec3(0.f,10.f,0.f), PVRTVec3(0.f, 1.f, 0.f));
	
	return true;
}

void pmxRenderer::createVbo( pmxReader* pReader )
{
  int32_t iStride = sizeof( pmx_renderer_vertex );
	glGenBuffers(1, &_vboRender);
	
	// Bind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, _vboRender);
	
	int32_t iNum = pReader->getNumVertices();
  std::vector< pmx_vertex > vecVertices = pReader->getVertices();
	std::vector< pmx_renderer_vertex > vec;
	pmx_renderer_vertex vertex;
	for( int32_t iVertexIndex = 0; iVertexIndex < iNum; ++iVertexIndex )
	{
		vertex.pos[ 0 ] = vecVertices[ iVertexIndex ].pos[ 0 ];
		vertex.pos[ 1 ] = vecVertices[ iVertexIndex ].pos[ 1 ];
		vertex.pos[ 2 ] = vecVertices[ iVertexIndex ].pos[ 2 ];
		vertex.normal_vec[ 0 ] = vecVertices[ iVertexIndex ].normal_vec[ 0 ];
		vertex.normal_vec[ 1 ] = vecVertices[ iVertexIndex ].normal_vec[ 1 ];
		vertex.normal_vec[ 2 ] = vecVertices[ iVertexIndex ].normal_vec[ 2 ];
		vertex.uv[ 0 ] = vecVertices[ iVertexIndex ].uv[ 0 ];
		vertex.uv[ 1 ] = vecVertices[ iVertexIndex ].uv[ 1 ];
		vertex.bone[ 0 ] = 0;
		vertex.bone[ 1 ] = 0;
		vertex.bone[ 2 ] = 0;
//		vertex.bone[ 3 ] = vecVertices[ iVertexIndex ].bone_weight;
		vertex.bone[ 3 ] = (uint8_t)(vecVertices[ iVertexIndex ].bone_weight[0] * 100.0f);
		vec.push_back( vertex );
	}
	
	// Set the buffer's data
	glBufferData(GL_ARRAY_BUFFER, iStride * vec.size(), &vec[ 0 ], GL_STATIC_DRAW);
  
	// Unbind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
  
	return;
}

void *getVertex(int32_t *to, void* p, int32_t size)
{
  if (size == 1) {
    
    uint8_t i, *inc;
    memcpy(&i, p, size);
    *to = (int32_t)i;
    inc = (uint8_t*)p;
    
    return ++inc;
  }
  
  if (size == 2) {
    
    uint16_t i, *inc;
    memcpy(&i, p, size);
    *to = (int32_t)i;
    inc = (uint16_t*)p;
    
    return ++inc;
  }
  
  if (size == 4) {
    
    int32_t *inc;
    memcpy(to, p, size);
    inc = (int32_t*)p;
    
    return ++inc;
  }
  
  return p;
}

void pmxRenderer::createIndexBuffer( pmxReader* pReader )
{
//  // dump indices
//  NSLog(@"pmxRenderer::createIndexBuffer dump indices ----");
//  int32_t vertexIndexSize = pReader->vertexIndexSize();
//  void *p = pReader->getIndices();
//  for (int i = 0; i < pReader->getNumIndices();) {
//    int32_t v[3];
//    p = getVertex(&v[0], p, vertexIndexSize);
//    p = getVertex(&v[1], p, vertexIndexSize);
//    p = getVertex(&v[2], p, vertexIndexSize);
//    NSLog(@"index %d : (%d, %d, %d)", i, v[0], v[1], v[2]);
//    i += 3;
//  }
  
  int32_t iStride = (int32_t)pReader->vertexIndexSize(); //sizeof( uint16_t );
	glGenBuffers(1, &_vboIndex);
	
	// Bind the VBO
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vboIndex);
	
	// Set the buffer's data
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, iStride * pReader->getNumIndices(), pReader->getIndices(), GL_STATIC_DRAW);
	
	// Unbind the VBO
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  
	int32_t iMaterials = pReader->getNumMaterials();
  std::vector<pmx_material> vecMaterial = pReader->getMaterials();
  
	for( int32_t i = 0; i < iMaterials; ++i )
	{
		PMX_DRAW_LIST list;
		list.iMaterialIndex = i;
		list.iNumIndices = vecMaterial[ i ].face_vert_count;
		_vecDrawList.push_back( list );
	}
	return;
}

void pmxRenderer::loadMaterials( pmxReader* pReader )
{
  NSString *rootPath = pReader->getRootPath();
  NSLog(@"rootPath = %@", rootPath);
  
  std::vector<pmx_string> vecTexture = pReader->getTextures();
  
	for( int32_t i = 0; i < pReader->getNumMaterials(); ++i )
	{
		_vecMaterials.push_back( pReader->getMaterials()[ i ] );
		
		pmx_material& mat = _vecMaterials[ i ];
    
    if (mat.shared_toon_flag == 1) {
      // TODO : set shared toon
      continue;
    }
    
    if (mat.shared_toon_flag == 0) {
      
      if (mat.toon_texture_index == -1) continue;
      
//      NSLog(@"mat.toon_texture_index = %d", mat.toon_texture_index);
      NSString *textureFilename = vecTexture[mat.toon_texture_index].string();
      
      if( textureFilename )
      {
        NSString* fullPath = [NSString stringWithFormat:@"%@/%@", rootPath, textureFilename];
        NSLog( @"Texture:%@", fullPath);
        
        mat._tex2D = [[Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile:fullPath]];
        mat._tex = mat._tex2D.name;
        
      }
      else
      {
        mat._tex2D = nil;
        mat._tex = 0;
      }
    }
	}
}

#pragma mark partitioning
bool pmxRenderer::partitioning( pmxReader* reader, SkinningEvaluator* eval, int32_t iStart, int32_t iNumIndices )
{
	if( iNumIndices % 3 )
		return false;
  
	if( reader == NULL || eval == NULL )
	{
		return false;
	}
  
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  std::vector <int32_t> vecIndices = reader->getVecIndices();
  std::vector<pmx_vertex> vecVertex = reader->getVertices();
//	int32_t* pIndices = (uint16_t*)reader->getIndices() + iStart;
  
	
	NSMutableDictionary* meshStats = [[[NSMutableDictionary alloc] init] autorelease];
	for( int32_t i = 0; i < iNumIndices/3; ++i )
	{
		//Triangle stats array
		NSMutableDictionary* triangleStats = [[[NSMutableDictionary alloc] init] autorelease];
		for( int32_t j = 0; j < 3; ++j )
		{
			int32_t iMatrix0 = vecVertex[ vecIndices[i * 3 + j + iStart]].getBoneIndex( 0 );
			NSNumber* n0 = [NSNumber numberWithInt:iMatrix0];
			[triangleStats setObject:n0 forKey:n0];
      
			int32_t iMatrix1 = vecVertex[ vecIndices[i * 3 + j + iStart]].getBoneIndex( 1 );
			if( iMatrix1 != -1 )
			{
				NSNumber* n1 = [NSNumber numberWithInt:iMatrix1];
				[triangleStats setObject:n1 forKey:n1];
			}
		}
    
		//Sort matrix used in the mesh
		NSArray *keys = [triangleStats allKeys];
		NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
		
		int64_t iKey = 0;
		for( NSNumber* n in sortedKeys )
		{
			iKey <<= 8;
			iKey |= [n intValue];
			if( [n intValue] > 255 )
			{
//				NSLog( @"Invalid bone #, assuming # bones less than 255" );
			}
		}
		
		NSNumber* numKey = [NSNumber numberWithLongLong:iKey];
		if( [meshStats objectForKey:numKey] == nil )
		{
			[meshStats setObject:[[[NSMutableArray alloc] init] autorelease]
                    forKey:numKey];
		}
		[[meshStats objectForKey:numKey] addObject:[NSNumber numberWithInt:vecIndices[i * 3]]];
		[[meshStats objectForKey:numKey] addObject:[NSNumber numberWithInt:vecIndices[i * 3 + 1]]];
		[[meshStats objectForKey:numKey] addObject:[NSNumber numberWithInt:vecIndices[i * 3 + 2]]];
	}
	
	//
	//meshStats[key][triangle index]
	NSArray *keys = [meshStats allKeys];
	NSMutableArray *sortedMeshStats = [NSMutableArray arrayWithArray:[keys sortedArrayUsingSelector:@selector(compare:)]];
	NSLog( @"Num keys:%d", [sortedMeshStats count] );
  //	NSLog( @"keys:%@", [sortedMeshStats description] );
	
	//Start.
	//Add 1st item
	eval->addItem([sortedMeshStats objectAtIndex:0],
                [meshStats objectForKey:[sortedMeshStats objectAtIndex:0]],
                0);
	[sortedMeshStats removeObjectAtIndex:0];
	
	while( [sortedMeshStats count] )
	{
		int32_t iLeastScore = INT_MAX;
		int32_t iLeastIndex = INT_MAX;
		int32_t iLeastScoreSlot;
		int32_t iSlot;
		
		int32_t iCount = [sortedMeshStats count];
		for( int32_t iIndex = 0; iIndex < iCount; ++iIndex )
		{
			//Get least score
			int32_t iScore = eval->getScore( [[sortedMeshStats objectAtIndex:iIndex] longLongValue], iSlot);
			if( iScore < iLeastScore )
			{
				iLeastScore = iScore;
				iLeastIndex = iIndex;
				iLeastScoreSlot = iSlot;
			}
		}
		eval->addItem( [sortedMeshStats objectAtIndex:iLeastIndex], [meshStats objectForKey:[sortedMeshStats objectAtIndex:iLeastIndex]], iLeastScoreSlot);
		[sortedMeshStats removeObjectAtIndex:iLeastIndex];
	}
	
	//Done partitioning
	
	[pool drain];
	return true;
}

NSComparisonResult pmxRenderer::compare(NSNumber *first, NSNumber *second, NSDictionary *dic)
{
	int32_t iValueFirst = [[dic objectForKey:first] intValue];
	int32_t iValueSecond = [[dic objectForKey:second] intValue];
	if ( iValueFirst < iValueSecond)
		return NSOrderedDescending;
	else 	if ( iValueFirst > iValueSecond)
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

bool pmxRenderer::createMatrixMapping( NSArray* sortedKeys, NSDictionary* dicMatrixRefArray )
{
	for( int32_t i = 0; i < _vecDrawList.size(); ++i )
	{
		_vecDrawList[ i ].vecMatrixPalette.clear();
		_vecDrawList[ i ].vecMatrixPalette.reserve( BATCH_DIVISION_THRESHOLD );
		for( int32_t iIndex = 0; iIndex < BATCH_DIVISION_THRESHOLD; ++iIndex )
			_vecDrawList[ i ].vecMatrixPalette.push_back( PMX_MATRIX_UNDEFINED );
	}
	
  //	NSLog( @"sortedKeys:%@", [sortedKeys description] );
  
	//Sorted decending order
	for( NSNumber* num in sortedKeys )
	{
		//Create matrix map
		NSArray* batches = [dicMatrixRefArray objectForKey:num];
    
		int32_t iLeastScore = BATCH_DIVISION_THRESHOLD + 1;
		int32_t iLeastIndex = BATCH_DIVISION_THRESHOLD + 1;
		for( int32_t iBottom = 0; iBottom < BATCH_DIVISION_THRESHOLD; ++iBottom )
		{
			int32_t iScore = 0;
			for( NSNumber* numBatch in batches )
			{
				if( _vecDrawList[ [numBatch intValue] ].vecMatrixPalette[ iBottom ] != PMX_MATRIX_UNDEFINED )
				{
					//Slot is used
					iScore++;
				}
			}
			//Pick least score
			if( iLeastScore > iScore )
			{
				iLeastScore = iScore;
				iLeastIndex = iBottom;
			}
		}
		
		//Map it!!
		for( NSNumber* numBatch in batches )
		{
			int32_t iIndex = 0;
			for( iIndex = 0; iIndex < BATCH_DIVISION_THRESHOLD; ++iIndex )
			{
				if( _vecDrawList[ [numBatch intValue] ].vecMatrixPalette[ (iIndex + iLeastIndex ) % BATCH_DIVISION_THRESHOLD ] == PMX_MATRIX_UNDEFINED )
				{
					_vecDrawList[ [numBatch intValue] ].vecMatrixPalette[ (iIndex + iLeastIndex ) % BATCH_DIVISION_THRESHOLD ] = [num intValue];
					break;
				}
			}
			
			if( iIndex == BATCH_DIVISION_THRESHOLD )
			{
				NSLog( @"No slot available" );
			}
		}
	}
	
#ifdef DUMP_PARTITIONS
	//Dump out..
	for( int32_t i = 0; i < _vecDrawList.size(); ++i )
	{
		NSLog( @"----%d----\n", i );
		for( int32_t iIndex = 0; iIndex < BATCH_DIVISION_THRESHOLD; ++iIndex )
			NSLog( @"%2x", _vecDrawList[ i ].vecMatrixPalette[ iIndex ] );
		NSLog( @"\n" );
	}
#endif
	
	return true;
}

int32_t pmxRenderer::getMappedVertices(std::vector<pmx_vertex> vecVertex,
                                       const int32_t iVertexIndex,
                                       const int64_t iVertexKey,
                                       const bool bSkinning )
{
  getMappedVerticesCallCount++;
	
	std::map< int32_t, int64_t >::iterator it = _mapVertexMapping[ iVertexIndex ].find( iVertexKey );
	if( it != _mapVertexMapping[ iVertexIndex ].end() )
	{
		return it->second;
	}
	
	int32_t iNewIndex = _vecMappedVertex.size();
	_mapVertexMapping[ iVertexIndex ][ iVertexKey ] = iNewIndex;
	
	pmx_renderer_vertex vertex;
	vertex.pos[ 0 ] = vecVertex[ iVertexIndex ].pos[ 0 ];
	vertex.pos[ 1 ] = vecVertex[ iVertexIndex ].pos[ 1 ];
	vertex.pos[ 2 ] = vecVertex[ iVertexIndex ].pos[ 2 ];
	vertex.normal_vec[ 0 ] = vecVertex[ iVertexIndex ].normal_vec[ 0 ];
	vertex.normal_vec[ 1 ] = vecVertex[ iVertexIndex ].normal_vec[ 1 ];
	vertex.normal_vec[ 2 ] = vecVertex[ iVertexIndex ].normal_vec[ 2 ];
	vertex.uv[ 0 ] = vecVertex[ iVertexIndex ].uv[ 0 ];
	vertex.uv[ 1 ] = vecVertex[ iVertexIndex ].uv[ 1 ];
	vertex.bone[ 0 ] = int32_t(iVertexKey >> 32);
	vertex.bone[ 1 ] = int32_t(iVertexKey & 0xffffffff);
	vertex.bone[ 2 ] = bSkinning;
  // memo : ayashii
	vertex.bone[ 3 ] = uint8_t( float(vecVertex[ iVertexIndex ].bone_weight[0]) * 255.f);
//	vertex.bone[ 3 ] = uint8_t( float(vecVertex[ iVertexIndex ].bone_weight[0]) / 100.f * 255.f);
	_vecMappedVertex.push_back( vertex );
	
	//NSLog( @"vertex %d, weight %d bone0 %d, bone1 %d", iNewIndex, vertex.bone[ 3 ], vertex.bone[ 0 ], vertex.bone[ 1 ] );
	return iNewIndex;
}

int32_t pmxRenderer::getMappedBone( std::vector< int32_t >*pVec, const int32_t iBone )
{
  getMappedBoneCallCount++;
	//
	//Get the bone index in current matrix palette skinning entries
	//
	int32_t iCount = pVec->size();
	int32_t iIndex = -1;
	for( int32_t i = 0; i < iCount; ++i )
	{
		if( pVec->at( i ) == iBone )
		{
			iIndex = i;
			break;
		}
	}
  
	if( iIndex == -1 )
		NSLog( @"Bone Index not found!");
  
	return iIndex;
}

//
//Check bones used in each material
//
bool pmxRenderer::partitionMeshes( pmxReader* reader )
{
	SGXSkinningEvaluator* eval = new SGXSkinningEvaluator();
	int32_t iMaterials = reader->getNumMaterials();
  std::vector<pmx_material> vecMaterial = reader->getMaterials();
	int32_t iOffset = 0;
	
  std::vector<pmx_vertex> vecVerices = reader->getVertices();
  std::vector<int32_t> readerIndices = reader->getVecIndices();
	
	int32_t iNumMatrix = eval->getNumBoneMatrixPalette();
	int32_t MAX_BONES = 255;
	if( iNumMatrix > MAX_BONES )
	{
		return false;
	}
	
	NSMutableDictionary* dicMatrixRefCount = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* dicMatrixRefArray = [[NSMutableDictionary alloc] init];
  
	std::vector< int32_t > vecIndices;
	int32_t iBatchIndex = 0;
	
	//
	//1. Check bone ussage stats and perform pertitioning if necessary
	//
	
	for( int32_t i = 0; i < iMaterials; ++i )
	{
		NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
		int32_t iNumIndices = vecMaterial[ i ].face_vert_count;
		
		bool bPartitioned = false;
    
		for( int32_t j = 0; j < iNumIndices; ++j )
		{
			int32_t iIndex = readerIndices[ iOffset + j ];
			int32_t iBone0 = vecVerices[ iIndex ].getBoneIndex( 0 );
			NSNumber* num0 = [NSNumber numberWithInt:iBone0];
			[dic setObject:num0 forKey:num0];
			
			int32_t iBone1 = vecVerices[ iIndex ].getBoneIndex( 1 );
			if( iBone1 != -1 )
			{
				NSNumber* num1 = [NSNumber numberWithInt:iBone1];
				[dic setObject:num1 forKey:num1];
			}
			
			if( [dic count] > iNumMatrix )
			{
				bPartitioned = true;
				//Need to partition mesh
				NSLog( @"Partitioning..." );
				partitioning( reader, eval, iOffset, iNumIndices );
				break;
			}
			
		}
		
		//Create index list
		if( bPartitioned )
		{
      //			NSLog( @"Partitioning..." );
      //			partitioning( reader, eval, iOffset, iNumIndices );
      
			NSArray* arrayPartitions = eval->getResult();
      
			for( NSArray* indices in arrayPartitions )
			{
				NSNumber* numBatch = [NSNumber numberWithInt:iBatchIndex];
				
				for( NSNumber* index in indices )
				{
					int32_t iIndex = [index integerValue];
					vecIndices.push_back( iIndex );
					
					//Count matrix usage for matrix palette index mapping
					for( int32_t iBoneIndex = 0; iBoneIndex < 2; ++iBoneIndex )
					{
						int32_t iBone = vecVerices[ iIndex ].getBoneIndex( iBoneIndex );
						NSNumber* num = [NSNumber numberWithInt:iBone];
						
						NSNumber* numCount = [dicMatrixRefCount objectForKey:num];
						if( numCount == nil )
							[dicMatrixRefCount setObject:[NSNumber numberWithInt:1]  forKey:num];
						else
							[dicMatrixRefCount setObject:[NSNumber numberWithInt:[numCount intValue] + 1]  forKey:num];
						
						NSMutableDictionary* dicMatrix = [dicMatrixRefArray objectForKey:num];
						if( dicMatrix == nil )
							dicMatrix = [[[NSMutableDictionary alloc] init] autorelease];
						
						[dicMatrix setObject:numBatch forKey:numBatch];
						[dicMatrixRefArray setObject:dicMatrix forKey:num];
            
						if( vecVerices[ iIndex ].getBoneIndex( iBoneIndex + 1 ) == -1 )
							break;
					}
          
				}
        
				PMX_DRAW_LIST list = { 0 };
				list.iMaterialIndex = i;
				list.iNumIndices = [indices count];
				_vecDrawList.push_back( list );
				
				iBatchIndex++;
			}
			
			eval->clearResult();
		}
		else
		{
			NSNumber* numBatch = [NSNumber numberWithInt:iBatchIndex];
      
			//Push indices to index list
			for( int32_t j = 0; j < iNumIndices; ++j )
			{
				int32_t iIndex = readerIndices[ iOffset + j ];
				vecIndices.push_back( iIndex );
        
				//Count matrix usage for matrix palette index mapping
				for( int32_t iBoneIndex = 0; iBoneIndex < 2; ++iBoneIndex )
				{
					int32_t iBone = vecVerices[ iIndex ].getBoneIndex( iBoneIndex );
					NSNumber* num = [NSNumber numberWithInt:iBone];
					
					NSNumber* numCount = [dicMatrixRefCount objectForKey:num];
					if( numCount == nil )
						[dicMatrixRefCount setObject:[NSNumber numberWithInt:1]  forKey:num];
					else
						[dicMatrixRefCount setObject:[NSNumber numberWithInt:[numCount intValue] + 1]  forKey:num];
					
					NSMutableDictionary* dicMatrix = [dicMatrixRefArray objectForKey:num];
					if( dicMatrix == nil )
						dicMatrix = [[[NSMutableDictionary alloc] init] autorelease];
					
					[dicMatrix setObject:numBatch forKey:numBatch];
					[dicMatrixRefArray setObject:dicMatrix forKey:num];
					
					if( vecVerices[ iIndex ].getBoneIndex( iBoneIndex + 1 ) == -1 )
						break;
				}
			}
			
			PMX_DRAW_LIST list = { 0 };
			list.iMaterialIndex = i;
			list.iNumIndices = iNumIndices;
			_vecDrawList.push_back( list );
      
			iBatchIndex++;
		}
		
#ifdef DUMP_PARTITIONS
		NSLog( @"Bones in material %d: %d, %@", i, [dic count], [dic description]);
#endif
		[dic release];
		
		iOffset += iNumIndices;
	}
	
	//NSLog( @"matrix dic:%@", [dicMatrixRefArray description] );
	
	//
	//Now we have index list
	//
  
	//
	//2. Crete matrix mapping for vs constant array
	//
	
	//dicMatrixRefCount
	//bone0 - nsnumber: # reference count
	//bone1 - nsnumber: # reference count.
	
	//dicMatrixRefArray
	//bone0 - dic { batch using the bone }
	//bone1 - dic { batch using the bone }
	
	//Sort bones by ref count
	NSArray *keys = [dicMatrixRefCount allKeys];
	NSArray *sortedKeys = [keys sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))compare context:dicMatrixRefCount];
	//NSLog( @"%@", [sortedKeys description] );
	//NSLog( @"%@", [dicMatrixRefCount description] );
	
	createMatrixMapping( sortedKeys, dicMatrixRefArray );
	
	//Go through index buffer & duplicate vertex if necessary
	int32_t iIndex = 0;
  
	_vecMappedVertex.clear();
	_mapVertexMapping.clear();
  
	
	//
	//3. Create skin mesh mapping
	//
	NSMutableDictionary* dicSkinmeshVertices = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* dicSkinmeshVerticesReverse = [[NSMutableDictionary alloc] init];
	if( _bPerformSkinmeshAnimation )
	{
		//
		//Note:
		//now only support 1 base mesh
		//
		
    std::vector< pmx_morph > vecMorphs = reader->getMorphs();
		for( int32_t i = 0; i < vecMorphs.size(); ++i )
		{
      
      // TODO : ???
//			if( vecMorphs[i].type == 0 )	//if base skin data
      if ( vecMorphs[i].operation_panel == 0) { // ???
        if( vecMorphs[i].type == 1 )	//if vertex morph ?
        {
          for( int32_t j = 0; j < vecMorphs[i].offset_count; ++j )
          {
            
            [dicSkinmeshVertices setObject:[NSNumber numberWithBool:true]
                                    forKey:[NSNumber numberWithInt:vecMorphs[i].offset_datas[j].vertex_morph.vertex_index] ];
            [dicSkinmeshVerticesReverse setObject:[NSNumber numberWithInt:vecMorphs[i].offset_datas[j].vertex_morph.vertex_index]
                                           forKey:[NSNumber numberWithInt:j]];
          }
        }
      }
		}
		
		_iNumSkinAnimations = vecMorphs.size();
	}
	
	//
	//4. vbo, index buffer registrations
	//
	
	//now it takes 2 passes
	//first pass: regsiter vertices with skinning animation
	//2nd pass: register vertices without skinning animation
	
	std::vector< PMX_DRAW_LIST >::iterator itBegin = _vecDrawList.begin();
	std::vector< PMX_DRAW_LIST >::iterator itEnd = _vecDrawList.end();
	std::vector< int32_t > vecMappedIndices;
	if( _bPerformSkinmeshAnimation )
	{
		NSMutableDictionary* dicSkinningVertexMap = [[[NSMutableDictionary alloc] init] autorelease];
		
		for( ;itBegin != itEnd; ++itBegin )
		{
			int32_t iNumIndices = itBegin->iNumIndices;
			NSLog( @"Batch material:%d # indices:%d", itBegin->iMaterialIndex, iNumIndices );
      NSLog( @"map: %d vertices: %d", getMappedBoneCallCount, getMappedVerticesCallCount);
			std::vector< int32_t >* pVec = &itBegin->vecMatrixPalette;
			for( int32_t i = 0; i < iNumIndices; ++i )
			{
				int32_t iCurrentIndex = vecIndices[ iIndex ];
				if( [dicSkinmeshVertices objectForKey:[NSNumber numberWithInt:iCurrentIndex] ] != nil )
				{
          NSLog(@"i = %d iCurrentIndex = %d dic found ", i, iCurrentIndex);
					itBegin->bSkinMesh = true;
					
					int32_t iBone0 = vecVerices[ iCurrentIndex ].getBoneIndex( 0 );
					int32_t iMappedBone0 = getMappedBone( pVec, iBone0 );
					
					int32_t iBone1 = vecVerices[ iCurrentIndex ].getBoneIndex( 1 );
					int32_t iMappedBone1 = -1;
					int32_t iMappedVertexIndex;
					if( iBone1 != -1 )
					{
						iMappedBone1 = getMappedBone( pVec, iBone1 );
						int64_t iKey = (int64_t)iMappedBone0 << 32 | iMappedBone1;
						iMappedVertexIndex = getMappedVertices( vecVerices, iCurrentIndex, iKey, true );
					}
					else
					{
						int64_t iKey = (int64_t)iMappedBone0 << 32;
						iMappedVertexIndex = getMappedVertices( vecVerices, iCurrentIndex, iKey, true );
					}
					
					NSNumber* num = [NSNumber numberWithInt:iCurrentIndex];
					NSMutableDictionary* dic = [dicSkinningVertexMap objectForKey:num];
					if( dic == nil )
						dic = [[[NSMutableDictionary alloc] init] autorelease];
					[dic setObject:num forKey:[NSNumber numberWithInt:iMappedVertexIndex]];
					[dicSkinningVertexMap setObject:dic forKey:num];
				}
				iIndex++;
			}
		}
    
		_iSizeSkinanimatinVertices = _vecMappedVertex.size();
		NSLog( @"# of skinanimation vertices: %d", _iSizeSkinanimatinVertices );
    NSLog( @"map: %d vertices: %d", getMappedBoneCallCount, getMappedVerticesCallCount);
		
		//
		//dicSkinmeshVertices: dic[ vertex -> bool ];
		//dicSkinmeshVerticesReverse: dic[ base index -> vertex index in vbo ];
		//
    
		
		//Create skin data arrayVBOs
    std::vector< pmx_morph > vecMorphs = reader->getMorphs();
		
		for( int32_t i = 0; i < vecMorphs.size(); ++i )
		{
			pmx_skinanimation_vertex* pVertices = new pmx_skinanimation_vertex[ _iSizeSkinanimatinVertices ];
			//Clear
			for( int32_t j = 0; j < _iSizeSkinanimatinVertices; ++j )
			{
				pVertices[ j ].pos[ 0 ] = pVertices[ j ].pos[ 1 ] = pVertices[ j ].pos[ 2 ] = 0.f;
			}
			
      // TODO : ???
//			if( pSkin->skin_type != 0 )
      if ( vecMorphs[i].operation_panel != 0) { // ??
        if ( vecMorphs[i].type == 1) {
          for( int32_t j = 0; j < vecMorphs[i].offset_count; ++j )
          {
            
            NSNumber* num = [dicSkinmeshVerticesReverse objectForKey:[NSNumber numberWithInt:vecMorphs[i].offset_datas[j].vertex_morph.vertex_index]];
            NSDictionary* dic = [dicSkinningVertexMap objectForKey:num];
            for( NSNumber* n in dic )
            {
              int32_t iIndex = [n intValue];
              pVertices[ iIndex ].pos[ 0 ] = vecMorphs[i].offset_datas[j].vertex_morph.offset_vector[0];
              pVertices[ iIndex ].pos[ 1 ] = vecMorphs[i].offset_datas[j].vertex_morph.offset_vector[1];
              pVertices[ iIndex ].pos[ 2 ] = vecMorphs[i].offset_datas[j].vertex_morph.offset_vector[2];
            }
          }
          _vecSkinAnimation.push_back( pVertices );
          
        }
      }
		}
	}
  
	//2nd pass
	itBegin = _vecDrawList.begin();
	itEnd = _vecDrawList.end();
	iIndex = 0;
	
	for( ;itBegin != itEnd; ++itBegin )
	{
		int32_t iNumIndices = itBegin->iNumIndices;
		NSLog( @"Batch material:%d # indices:%d", itBegin->iMaterialIndex, iNumIndices );
    NSLog( @"map: %d vertices: %d", getMappedBoneCallCount, getMappedVerticesCallCount);
		std::vector< int32_t >* pVec = &itBegin->vecMatrixPalette;
		for( int32_t i = 0; i < iNumIndices; ++i )
		{
      bool a = (i % 200 == 0);
      if (a) NSLog(@"i = %d", i);
      if (a) NSLog( @"map: %d vertices: %d", getMappedBoneCallCount, getMappedVerticesCallCount);
			int32_t iCurrentIndex = vecIndices[ iIndex ];
			int32_t iBone0 = vecVerices[ iCurrentIndex ].getBoneIndex( 0 );
			int32_t iMappedBone0 = getMappedBone( pVec, iBone0 );
			
			int32_t iBone1 = vecVerices[ iCurrentIndex ].getBoneIndex( 1 );
			int32_t iMappedBone1 = -1;
			if( iBone1 != -1 )
			{
        if (a) NSLog(@" iBone1 != -1");
				iMappedBone1 = getMappedBone( pVec, iBone1 );
				int64_t iKey = (int64_t)iMappedBone0 << 32 | iMappedBone1;
				int32_t iMappedIndex = getMappedVertices( vecVerices, iCurrentIndex, iKey, false );
				vecMappedIndices.push_back( iMappedIndex );
			}
			else
			{
        if (a) NSLog(@" iBone1 == -1");
				int64_t iKey = (int64_t)iMappedBone0 << 32;
				int32_t iMappedIndex = getMappedVertices( vecVerices, iCurrentIndex, iKey, false );
				vecMappedIndices.push_back( iMappedIndex );
			}
			iIndex++;
		}
	}
	
	//
	//5. create buffers
	//
	
	//Create Index buffer
	glGenBuffers(1, &_vboIndex);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vboIndex);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, vecMappedIndices.size() * sizeof( uint32_t ), &vecMappedIndices[ 0 ], GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	
	//Create VBO
  int32_t iStride = sizeof( pmx_renderer_vertex );
	glGenBuffers(1, &_vboRender);
	glBindBuffer(GL_ARRAY_BUFFER, _vboRender);
	glBufferData(GL_ARRAY_BUFFER, iStride * _vecMappedVertex.size(), &_vecMappedVertex[ 0 ], GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	if( _bPerformSkinmeshAnimation )
	{
		iStride = sizeof( pmx_skinanimation_vertex );
		glGenBuffers(1, &_vboSkinAnimation);
		glBindBuffer(GL_ARRAY_BUFFER, _vboSkinAnimation);
		
		//Fill with Dummy data
		pmx_skinanimation_vertex* pVertices = new pmx_skinanimation_vertex[_vecMappedVertex.size()];
		glBufferData(GL_ARRAY_BUFFER, iStride * _vecMappedVertex.size(), pVertices, GL_STATIC_DRAW);
    
		delete []pVertices;
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	
	NSLog( @"Duplicated vertices:%ld", _vecMappedVertex.size() - reader->getNumVertices() );
  
	_vecMappedVertex.clear();
	_mapVertexMapping.clear();
	[dicMatrixRefCount release];
	[dicMatrixRefArray release];
	[dicSkinmeshVertices release];
	[dicSkinmeshVerticesReverse release];
	delete eval;
	return true;
}

#pragma mark ShaderHelper

BOOL pmxRenderer::compileShader( GLuint *shader, const GLenum type, const NSString *file )
{
  GLint status;
  const GLchar *source;
	
  source = (GLchar *)[[NSString stringWithContentsOfFile:(NSString*)file encoding:NSUTF8StringEncoding error:nil] UTF8String];
  
  if (!source)
  {
    NSLog(@"Failed to load vertex shader");
    return FALSE;
  }
	
  *shader = glCreateShader(type);
  glShaderSource(*shader, 1, &source, NULL);
  glCompileShader(*shader);
	
#if defined(DEBUG)
  GLint logLength;
  glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    NSLog(@"Shader compile log:\n%s", log);
    free(log);
  }
#endif
	
  glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
  if (status == 0)
  {
    glDeleteShader(*shader);
    return FALSE;
  }
	
  return TRUE;
}

BOOL pmxRenderer::linkProgram( const GLuint prog )
{
  NSLog(@"pmxRenderer::linkProgram");
  GLint status;
	
  glLinkProgram(prog);
	
#if defined(DEBUG)
  GLint logLength;
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program link log:\n%s", log);
    free(log);
  }
#endif
	
  glGetProgramiv(prog, GL_LINK_STATUS, &status);
  if (status == 0)
    return FALSE;
	
  return TRUE;
}

BOOL pmxRenderer::validateProgram(const GLuint prog )
{
  GLint logLength, status;
	
  glValidateProgram(prog);
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }
	
  glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
  if (status == 0)
    return FALSE;
	
  return TRUE;
}

BOOL pmxRenderer::loadShaders( PMX_SHADER_PARAMS* params, NSString* strVsh, NSString* strFsh )
{
  NSLog(@"pmxRenderer::loadShaders");
  NSLog(@"vsh = %@", strVsh);
  NSLog(@"fsh = %@", strFsh);
  
	GLuint program;
  GLuint vertShader, fragShader;
  NSString *vertShaderPathname, *fragShaderPathname;
	
  // Create shader program
  program = glCreateProgram();
	
  // Create and compile vertex shader
  vertShaderPathname = [[NSBundle mainBundle] pathForResource:strVsh ofType:@"vsh"];
  if (!compileShader( &vertShader, GL_VERTEX_SHADER, vertShaderPathname ))
  {
    NSLog(@"Failed to compile vertex shader");
    return FALSE;
  }
	
  // Create and compile fragment shader
  fragShaderPathname = [[NSBundle mainBundle] pathForResource:strFsh ofType:@"fsh"];
  if (!compileShader( &fragShader, GL_FRAGMENT_SHADER, fragShaderPathname ))
  {
    NSLog(@"Failed to compile fragment shader");
    return FALSE;
  }
	
  // Attach vertex shader to program
  glAttachShader(program, vertShader);
  
  // Attach fragment shader to program
  glAttachShader(program, fragShader);
	
  // Bind attribute locations
  // this needs to be done prior to linking
  glBindAttribLocation(program, ATTRIB_VERTEX, "myVertex");
  glBindAttribLocation(program, ATTRIB_NORMAL, "myNormal");
  glBindAttribLocation(program, ATTRIB_UV, "myUV");
  glBindAttribLocation(program, ATTRIB_BONE, "myBone");
  glBindAttribLocation(program, ATTRIB_SKINANIMATION, "mySkinAnimation");
  
	// Link program
  if( !linkProgram(program) )
  {
    NSLog(@"Failed to link program: %d", program);
		
    if (vertShader)
    {
      glDeleteShader(vertShader);
      vertShader = 0;
    }
    if (fragShader)
    {
      glDeleteShader(fragShader);
      fragShader = 0;
    }
    if (program)
    {
      glDeleteProgram(program);
      params->_program = 0;
    }
    
    return FALSE;
  }
	
  // Get uniform locations
	params->_uiMatrixPalette = glGetUniformLocation(program, "uMatrixPalette");
	params->_uiMatrixP = glGetUniformLocation(program, "uPMatrix");
	
	params->_uiLight0 = glGetUniformLocation(program, "vLight0");
	params->_uiMaterialDiffuse = glGetUniformLocation(program, "vMaterialDiffuse");
	params->_uiMaterialAmbient = glGetUniformLocation(program, "vMaterialAmbient");
	params->_uiMaterialSpecular = glGetUniformLocation(program, "vMaterialSpecular");
	params->_uiSkinWeight = glGetUniformLocation(program, "fSkinWeight");
	
  
	// Set the sampler2D uniforms to corresponding texture units
	glUniform1i(glGetUniformLocation(program, "sTexture"), 0);
  
	// Release vertex and fragment shaders
  if (vertShader)
    glDeleteShader(vertShader);
	if (fragShader)
		glDeleteShader(fragShader);
  
	params->_program = program;
	return TRUE;
}



