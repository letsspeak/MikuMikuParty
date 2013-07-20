//
//  pmxReader.cpp
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/20.
//
//

#import "pmxReader.h"

pmxReader::pmxReader()
{
}

pmxReader::~pmxReader()
{
}

bool pmxReader::init(NSString *filename)
{
  NSLog(@"pmxReader::init");
  NSLog(@"filename = %@", filename);
  
  _filename = [filename retain];
  
  NSError *error = nil;
  _data = [[NSData dataWithContentsOfFile:filename options:NSDataReadingUncached error:&error] retain];
  if (error || !_data) {
    NSLog(@"Failed to load data");
    return false;
  }
  
  _pData = (int8_t*)[_data bytes];
  if (!_pData) {
    NSLog(@"Failed to load data");
    return false;
  }
  
  _iOffset = 0;
  
  if (verifyHeader() == false) {
    NSLog(@"Failed to veryfyHeader()");
    return false;
  }
  
  if (parseHeader() == false) {
    NSLog(@"Failed to parseHeader()");
    return false;
  }
  
  if (parseModelInfo() == false) {
    NSLog(@"Failed to parseModelInfo()");
    return false;
  }
  
  if (parseVertices() == false) {
    NSLog(@"Failed to parseVertices()");
    return false;
  }
  
  if (parseIndices() == false) {
    NSLog(@"Failed to parseIndices()");
    return false;
  }
  
  if (parseTextures() == false) {
    NSLog(@"Failed to parseTextures()");
    return false;
  }
  
  if (parseMaterials() == false) {
    NSLog(@"Failed to parseMaterials()");
    return false;
  }
  
  NSLog(@"finished Loading %@", filename);
  
  return true;
}

int32_t pmxReader::getInteger()
{
	int32_t i =  *(int32_t*)&_pData[ _iOffset ];
	_iOffset += sizeof( int32_t );
	return i;
}

int16_t pmxReader::getShort()
{
	int16_t i =  *(int16_t*)&_pData[ _iOffset ];
	_iOffset += sizeof( int16_t );
	return i;
}

int8_t pmxReader::getChar()
{
  int8_t i =  *(int8_t*)&_pData[ _iOffset ];
  _iOffset += sizeof( int8_t );
  return i;
}

float pmxReader::getFloat()
{
  float f;
  memcpy(&f, &_pData[ _iOffset ], sizeof(float));
	_iOffset += sizeof( float );
	return f;
}

bool pmxReader::getFloat2(float *f)
{
  memcpy(f, &_pData[ _iOffset ], sizeof(float) * 2);
	_iOffset += sizeof( float ) * 2;
  return !(_iOffset > [_data length]);
}

bool pmxReader::getFloat3(float *f)
{
  memcpy(f, &_pData[ _iOffset ], sizeof(float) * 3);
	_iOffset += sizeof( float ) * 3;
  return !(_iOffset > [_data length]);
}

bool pmxReader::getString(pmx_string *pString)
{
  int32_t size = getInteger();
  pString->bytes = (char*)&_pData[ _iOffset ];
  pString->length = size;
  pString->charset = _pHeader->charset;
  _iOffset += size;
  return !(_iOffset > [_data length]);
}

bool pmxReader::verifyHeader()
{
  NSLog(@"pmxReader::veryfiHeader()");
  const int32_t PMX_MAGIC = ' ' << 24 | 'X' << 16 | 'M' << 8 | 'P';
  const float PMX_VERSION = 2.f;
  
  if (!_pData)
    return false;
  
  if (getInteger() != PMX_MAGIC)
    return false;
  
  float fVersion = getFloat();
  NSLog(@"pmx version %f", fVersion);
  if (fVersion < PMX_VERSION)
    return false;

  return true;
}

bool pmxReader::parseHeader()
{
  int8_t size = getChar();
  _pHeader = (pmx_header*)&_pData[ _iOffset ];
  
  // for debug
  NSLog(@"pmd header (size %d)---------", size);
  NSLog(@"charset: %d", _pHeader->charset);
  NSLog(@"additional_uv_count: %d", _pHeader->additional_uv_count);
  NSLog(@"vertex_index_size: %d", _pHeader->vertex_index_size);
  NSLog(@"texture_index_size: %d", _pHeader->texture_index_size);
  NSLog(@"material_index_size: %d", _pHeader->material_index_size);
  NSLog(@"bone_index_size: %d", _pHeader->bone_index_size);
  NSLog(@"morph_index_size: %d", _pHeader->morph_index_size);
  NSLog(@"regid_body_index_size: %d", _pHeader->regid_body_index_size);
  
  _iOffset += size;
  return !(_iOffset > [_data length]);
}

bool pmxReader::parseModelInfo()
{
  if (getString(&_modelInfo.name) == false) return false;
  if (getString(&_modelInfo.name_en) == false) return false;
  if (getString(&_modelInfo.comment) == false) return false;
  if (getString(&_modelInfo.comment_en) == false) return false;
  
  // for debug
  NSLog(@"name: %@", _modelInfo.name.string());
  NSLog(@"name_en: %@", _modelInfo.name_en.string());
  NSLog(@"comment: %@", _modelInfo.comment.string());
  NSLog(@"comment_en: %@", _modelInfo.comment_en.string());
  
  return true;
}

bool pmxReader::parseVertices()
{
 	int32_t iVertices = getInteger();
	NSLog( @"Num vertices: %d", iVertices );
  _iNumVertices = iVertices;
  
  for (int32_t i = 0; i < iVertices; i++) {
//    NSLog(@"vertex[%d]--------", i);
    if ( parseVertex() == false) return false;
  }
  
  return true;
}

bool pmxReader::parseVertex()
{
  pmx_vertex vertex;

  // basic data
  getFloat3(vertex.pos);
  getFloat3(vertex.normal_vec);
  getFloat2(vertex.uv);
  
//  LogFloat3(@"vertex.pos", vertex.pos);
//  LogFloat3(@"vertex.normal_vec", vertex.normal_vec);
//  LogFloat2(@"vertex.uv", vertex.uv);
  
  // additional_uv
  vertex.additional_ux_count = _pHeader->additional_uv_count;
//  NSLog(@"vertex_additional_ux_count: %d", vertex.additional_ux_count);
  if (vertex.additional_ux_count > 0) {
    vertex.additional_uv = (pmx_additional_uv*)&_pData[ _iOffset ];
    _iOffset += sizeof(pmx_additional_uv) * vertex.additional_ux_count;
  }
  
//  for (int i = 0; i < vertex.additional_ux_count; i++){
//    LogFloat4(([NSString stringWithFormat:@"additional_uv[%d]", i]), vertex.additional_uv[i]);
//  }
  
  vertex.weight_type = getChar();
  vertex.bone_index_size = _pHeader->bone_index_size;
  
  switch (vertex.weight_type) {
    case 0: // BDEF1
    {
//      NSLog(@"BDEF1");
      vertex.bone_count = 1;
      vertex.bone_num = (void*)&_pData[ _iOffset ];
      _iOffset += (vertex.bone_index_size * vertex.bone_count);
      vertex.bone_weight_count = 0;
    }
      break;
    case 1: // BDEF2
    {
//      NSLog(@"BDEF2");
      vertex.bone_count = 2;
      vertex.bone_num = (void*)&_pData[ _iOffset ];
      _iOffset += (vertex.bone_index_size * vertex.bone_count);
      vertex.bone_weight_count = 1;
      vertex.bone_weight = (float*)&_pData[ _iOffset ];
      _iOffset += (sizeof(float) * vertex.bone_weight_count);
    }
      break;
    case 2: // BDEF4
    {
//      NSLog(@"BDEF4");
      vertex.bone_count = 4;
      vertex.bone_num = (void*)&_pData[ _iOffset ];
      _iOffset += (vertex.bone_index_size * vertex.bone_count);
      vertex.bone_weight_count = 4;
      vertex.bone_weight = (float*)&_pData[ _iOffset ];
      _iOffset += (sizeof(float) * vertex.bone_weight_count);
    }
      break;
    case 3: // SDEF
    {
//      NSLog(@"SDEF");
      vertex.bone_count = 2;
      vertex.bone_num = (void*)&_pData[ _iOffset ];
      _iOffset += (vertex.bone_index_size * vertex.bone_count);
      vertex.bone_weight_count = 1;
      vertex.bone_weight = (float*)&_pData[ _iOffset ];
      _iOffset += (sizeof(float) * vertex.bone_weight_count);
      getFloat3((float*)&vertex.sdef[0]);
      getFloat3((float*)&vertex.sdef[1]);
      getFloat3((float*)&vertex.sdef[2]);
    }
      break;
    case 4: // QDEF
    {
//      NSLog(@"QDEF");
      vertex.bone_count = 4;
      vertex.bone_num = (void*)&_pData[ _iOffset ];
      _iOffset += (vertex.bone_index_size * vertex.bone_count);
      vertex.bone_weight_count = 4;
      vertex.bone_weight = (float*)&_pData[ _iOffset ];
      _iOffset += (sizeof(float) * vertex.bone_weight_count);
    }
      break;
    default:
      NSLog(@"pmxReader::parseVertex() unknown weight type");
      return false;
  }
  
  vertex.edge_magnification = getFloat();
  _vecVertices.push_back( vertex );
  
  if (_iOffset > [_data length]) return false;
  return true;
}

bool pmxReader::parseIndices()
{
  int32_t iIndices = getInteger();
  NSLog(@"Num Indices: %d", iIndices);
  _iNumIndices = iIndices;
  _pIndices = (void*)&_pData[ _iOffset ];
  _iOffset += (iIndices *_pHeader->vertex_index_size);
  
  return !(_iOffset > [_data length]);
}

bool pmxReader::parseTextures()
{
  int32_t iTextures = getInteger();
  NSLog(@"Num Textures: %d", iTextures);
  _iNumTextures = iTextures;
  
  for (int i = 0; i < iTextures; i++) {
    pmx_string string;
    if (getString(&string) == false) return false;
    _vecTextures.push_back( string );
    NSLog(@"_vecTextures[%d] = %@", i, string.string());
  }
  
  return true;
}

bool pmxReader::parseMaterials()
{
  int32_t iMaterials = getInteger();
  NSLog(@"Num Materials: %d", iMaterials);
  _iNumMaterials = iMaterials;
  
  for (int32_t i = 0; i < iMaterials; i++) {
//    NSLog(@"material[%d]--------", i);
    if ( parseMaterial() == false) return false;
  }
  
  return  true;
}

bool pmxReader::parseMaterial()
{
  pmx_material material;
  
  // name info
  getString(&material.name);
  getString(&material.name_en);
  
//  NSLog(@"material.name: %@", material.name.string());
//  NSLog(@"material.name_en: %@", material.name_en.string());
  
  // colors
  getFloat3(material.diffuse_color);
  material.diffuse_color_alpha = getFloat();
  getFloat3(material.specular_color);
  material.shininess = getFloat();
  getFloat3(material.ambient_color);
  
//  LogFloat3(@"material.diffuse_color", material.diffuse_color);
//  NSLog(@"material.diffuse_color_alpha: %f", material.diffuse_color_alpha);
//  LogFloat3(@"material.specular_color", material.specular_color);
//  NSLog(@"material.shiniess: %f", material.shininess);
//  LogFloat3(@"material.ambient_color", material.ambient_color);
  
  // edge
  material.edge_flag = getChar();
  getFloat3(material.edge_color);
  material.edge_color_alpha = getFloat();
  material.edge_size = getFloat();
  
//  NSLog(@"material.edge_flag: %d", material.edge_flag);
//  LogFloat3(@"material.edge_color", material.edge_color);
//  NSLog(@"material.edge_color_alpha: %f", material.edge_color_alpha);
//  NSLog(@"material.edge_size: %f", material.edge_size);
  
  // texture
  material.normal_texture = (void*)&_pData[ _iOffset ];
  _iOffset += _pHeader->texture_index_size;
  material.sphere_texture = (void*)&_pData[ _iOffset ];
  _iOffset += _pHeader->texture_index_size;
  material.sphere_mode = getChar();
  
//  NSLog(@"material.sphere_mode: %d", material.sphere_mode);
  
  // toon
  material.shared_toon_flag = getChar();
  material.toon_texture = (void*)&_pData[ _iOffset ];
//  NSLog(@"material.shared_toon_flag: %d", material.shared_toon_flag);
  
  switch (material.shared_toon_flag) {
    case 0:
      _iOffset += _pHeader->texture_index_size;
      break;
    case 1:
      _iOffset += sizeof(uint8_t);
      break;
    default:
      NSLog(@"pmxReader::parseMaterial() unknown shared toon flag");
      return false;
  }
  
  // memo
  getString(&material.memo);
//  NSLog(@"material.memo: %@", material.memo.string());
  
  // face_vert_count
  material.face_vert_count = getInteger();
//  NSLog(@"material.face_vert_count: %d", material.face_vert_count);
  
  _vecMaterials.push_back( material );
  
  return !(_iOffset > [_data length]);
}


