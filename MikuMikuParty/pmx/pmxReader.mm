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
  
  if (parseBones() == false) {
    NSLog(@"Failed to parseBones()");
    return false;
  }
  
  if (parseMorphs() == false) {
    NSLog(@"Failed to parseMorphs()");
    return false;
  }
  
  if (parseFrames() == false) {
    NSLog(@"Failed to parseFrames()");
    return false;
  }
  
  if (parseRigids() == false) {
    NSLog(@"Failed to parseRigids()");
    return false;
  }
  
  NSLog(@"finished Loading %@", filename);
  
  return true;
}

int32_t pmxReader::getInteger()
{
	int32_t i;
  memcpy(&i, &_pData[ _iOffset ], sizeof(int32_t));
	_iOffset += sizeof( int32_t );
	return i;
}

int16_t pmxReader::getShort()
{
	int16_t i;
  memcpy(&i, &_pData[ _iOffset ], sizeof(int16_t));
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

bool pmxReader::getFloat2(float f[2])
{
  f[0] = getFloat();
  f[1] = getFloat();
  return !(_iOffset > [_data length]);
}

bool pmxReader::getFloat3(float f[3])
{
  f[0] = getFloat();
  f[1] = getFloat();
  f[2] = getFloat();
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

void* pmxReader::getPointer(int32_t size)
{
  void *p = (void*)&_pData[ _iOffset ];
  _iOffset += (size);
  return p;
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
  // memo : there is no alignment error here, because above datas are in alignment.
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
      vertex.sdef[0] = (pmx_sdef*)getPointer(sizeof(float) * 3);
      vertex.sdef[1] = (pmx_sdef*)getPointer(sizeof(float) * 3);
      vertex.sdef[2] = (pmx_sdef*)getPointer(sizeof(float) * 3);
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

bool pmxReader::parseBones()
{
  int32_t iBones = getInteger();
  NSLog(@"Num Bones: %d", iBones);
  _iNumBones = iBones;
  
  for (int i = 0; i < iBones; i++) {
//    NSLog(@"bone[%d]--------", i);
    if ( parseBone() == false) return false;
  }
  
  return true;
}

bool pmxReader::parseBone()
{
  pmx_bone bone;
  
  // name
  getString(&bone.name);
  getString(&bone.name_en);
  
//  NSLog(@"bone.name: %@", bone.name.string());
//  NSLog(@"bone.name_en: %@", bone.name_en.string());
  
  // basic data
  getFloat3(bone.bone_head_pos);
  bone.ik_parent_bone_index = (void*)&_pData[ _iOffset ];
  _iOffset += _pHeader->bone_index_size;
  bone.transform_level = getInteger();
  
  uint16_t flag = getShort();
  bone.bone_flag = flag;
  
//  NSLog(@"PMX_BONE_FLAG_TAIL_SPECIFY_TYPE_BIT: %d", (int)(flag & PMX_BONE_FLAG_TAIL_SPECIFY_TYPE_BIT));
//  NSLog(@"PMX_BONE_FLAG_ROTATABLE_BIT: %d", (int)(flag & PMX_BONE_FLAG_ROTATABLE_BIT));
//  NSLog(@"PMX_BONE_FLAG_MOVABLE_BIT: %d", (int)(flag & PMX_BONE_FLAG_MOVABLE_BIT));
//  NSLog(@"PMX_BONE_FLAG_DISPLAY_BIT: %d", (int)(flag & PMX_BONE_FLAG_DISPLAY_BIT));
//  NSLog(@"PMX_BONE_FLAG_OPERABLE_BIT: %d", (int)(flag & PMX_BONE_FLAG_OPERABLE_BIT));
//  NSLog(@"PMX_BONE_FLAG_IK_BIT: %d", (int)(flag & PMX_BONE_FLAG_IK_BIT));
//  NSLog(@"PMX_BONE_FLAG_LOCAL_GRANTEES_BIT: %d", (int)(flag & PMX_BONE_FLAG_LOCAL_GRANTEES_BIT));
//  NSLog(@"PMX_BONE_FLAG_ROTATION_GRANT_BIT: %d", (int)(flag & PMX_BONE_FLAG_ROTATION_GRANT_BIT));
//  NSLog(@"PMX_BONE_FLAG_MOVE_GRANT_BIT: %d", (int)(flag & PMX_BONE_FLAG_MOVE_GRANT_BIT));
//  NSLog(@"PMX_BONE_FLAG_FIXED_AXIS_BIT: %d", (int)(flag & PMX_BONE_FLAG_FIXED_AXIS_BIT));
//  NSLog(@"PMX_BONE_FLAG_LOCAL_AXIS_BIT: %d", (int)(flag & PMX_BONE_FLAG_LOCAL_AXIS_BIT));
//  NSLog(@"PMX_BONE_FLAG_PHYSICS_ORDER_BIT: %d", (int)(flag & PMX_BONE_FLAG_PHYSICS_ORDER_BIT));
//  NSLog(@"PMX_BONE_FLAG_PARENT_TRANSFORM_BIT: %d", (int)(flag & PMX_BONE_FLAG_PARENT_TRANSFORM_BIT));
  
  // PMX_BONE_FLAG_TAIL_SPECIFY_TYPE_BIT
  bone.tail_pos = (void*)&_pData[ _iOffset];
  if (flag & PMX_BONE_FLAG_TAIL_SPECIFY_TYPE_BIT) _iOffset += _pHeader->bone_index_size;
  else _iOffset += (sizeof(float) * 3);
  
  // PMX_BONE_FLAG_ROTATION_GRANT_BIT
  // PMX_BONE_FLAG_MOVE_GRANT_BIT
  if ((flag & PMX_BONE_FLAG_ROTATION_GRANT_BIT) || (flag & PMX_BONE_FLAG_MOVE_GRANT_BIT)) {
    bone.rot_move_parent_bone_index = getPointer(_pHeader->bone_index_size);
    bone.rot_move_rate = (float*)getPointer(sizeof(float));
  }
  
  // PMX_BONE_FLAG_FIXED_AXIS_BIT
  if (flag & PMX_BONE_FLAG_FIXED_AXIS_BIT) {
    bone.fixed_axis_vector = (float*)getPointer(sizeof(float) * 3);
  }
  
  // PMX_BONE_FLAG_LOCAL_AXIS_BIT
  if (flag & PMX_BONE_FLAG_LOCAL_AXIS_BIT) {
    bone.x_axis_vector = (float*)getPointer(sizeof(float) * 3);
    bone.z_axis_vector = (float*)getPointer(sizeof(float) * 3);
  }
  
  // PMX_BONE_FLAG_PARENT_TRANSFORM_BIT
  if (flag & PMX_BONE_FLAG_PARENT_TRANSFORM_BIT) {
    bone.parent_transform_key = (uint32_t*)getPointer(sizeof(uint32_t));
  }

  // PMX_BONE_FLAG_IK_BIT
  if (flag & PMX_BONE_FLAG_IK_BIT) {
    
    bone.ik_target_bone_index = getPointer(_pHeader->bone_index_size);
    bone.ik_loop_count = (uint32_t*)getPointer(sizeof(uint32_t));
    bone.ik_radian_limitaion = (float*)getPointer(sizeof(float));
    
    bone.ik_link_count = (uint32_t*)getPointer(sizeof(uint32_t));
    
    int32_t link_count;
    memcpy(&link_count, bone.ik_link_count, sizeof(int32_t));
    for (int i = 0; i < link_count; i++) {
//      NSLog(@"bone ik link[%d]-------", i);
      pmx_ik_link link;
      link.bone_index = getPointer(_pHeader->bone_index_size);
      link.radian_limitation_flag = (uint8_t*)getPointer(sizeof(uint8_t));
      
      if ((bool)(*link.radian_limitation_flag)) {
        link.lower_limit_vector = (float*)getPointer(sizeof(float) * 3);
        link.upper_limit_vector = (float*)getPointer(sizeof(float) * 3);
      }
      
      bone.ik_links.push_back(link);
    }
  }
  
  _vecBones.push_back( bone );
  
  return true;
}

bool pmxReader::parseMorphs()
{
  int32_t iMorphs = getInteger();
  NSLog(@"Num Morphs: %d", iMorphs);
  _iNumMorphs = iMorphs;
  
  for (int i = 0; i < iMorphs; i++) {
//    NSLog(@"morph[%d]--------", i);
    if ( parseMorph() == false) return false;
  }
  
  return true;
}

bool pmxReader::parseMorph()
{
  pmx_morph morph;
  
  getString(&morph.name);
  getString(&morph.name_en);
  
//  NSLog(@"morph.name: %@", morph.name.string());
//  NSLog(@"morph.name_en: %@", morph.name_en.string());
  
  morph.operation_panel = getChar();
  morph.type = getChar();
  
  uint32_t count = getInteger();
  morph.offset_count = count;
  
//  NSLog(@"morph.type = %d", morph.type);
  
  for (int i = 0; i < count; i++) {
    
//    NSLog(@"type:%d morph_offset_data[%d]", morph.type, i);
    
    pmx_morph_data data;
    
    switch (morph.type) {
      case PMX_MORPH_TYPE_GROUP:
        data.group_morph.morph_index = getPointer(_pHeader->morph_index_size);
        data.group_morph.morph_rate = (float*)getPointer(sizeof(float));
        break;
      case PMX_MORPH_TYPE_VERTEX:
        data.vertex_morph.vertex_index = getPointer(_pHeader->vertex_index_size);
        data.vertex_morph.offset_vector = (float*)getPointer(sizeof(float) * 3);
        break;
      case PMX_MORPH_TYPE_BONE:
        data.bone_morph.bone_index = getPointer(_pHeader->bone_index_size);
        data.bone_morph.movement_vector = (float*)getPointer(sizeof(float) * 3);
        data.bone_morph.rotation_vector = (float*)getPointer(sizeof(float) * 4);
        break;
      case PMX_MORPH_TYPE_UV:
      case PMX_MORPH_TYPE_ADDITIONAL_UV_1:
      case PMX_MORPH_TYPE_ADDITIONAL_UV_2:
      case PMX_MORPH_TYPE_ADDITIONAL_UV_3:
      case PMX_MORPH_TYPE_ADDITIONAL_UV_4:
        data.uv_morph.vertex_index = getPointer(_pHeader->vertex_index_size);
        data.uv_morph.offset_vector = (float*)getPointer(sizeof(float) * 4);
        break;
      case PMX_MORPH_TYPE_MATERIAL:
        data.material_morph.material_index = getPointer(_pHeader->material_index_size);
        data.material_morph.offset_calculation_type = (uint8_t*)getPointer(sizeof(uint8_t));
        data.material_morph.diffuse_color = (float*)getPointer(sizeof(float) * 4);
        data.material_morph.specular_color = (float*)getPointer(sizeof(float) * 3);
        data.material_morph.specular_coefficient = (float*)getPointer(sizeof(float));
        data.material_morph.ambient_color = (float*)getPointer(sizeof(float) * 3);
        data.material_morph.edge_color = (float*)getPointer(sizeof(float) * 4);
        data.material_morph.edge_size = (float*)getPointer(sizeof(float));
        data.material_morph.texture_coefficient = (float*)getPointer(sizeof(float) * 4);
        data.material_morph.sphere_texture_coefficient = (float*)getPointer(sizeof(float) * 4);
        data.material_morph.toon_texture_coefficient = (float*)getPointer(sizeof(float) * 4);
        break;
      default:
        NSLog(@"pmxReader::parseMorph() unknown morph type");
        return false;
    }
    
    morph.offset_datas.push_back( data );
    
  }
  
  _vecMorphs.push_back( morph );

  return !(_iOffset > [_data length]);
}

bool pmxReader::parseFrames()
{
  int32_t iFrames = getInteger();
  NSLog(@"Num Frames: %d", iFrames);
  _iNumFrames = iFrames;
  
  for (int i = 0; i < iFrames; i++) {
//    NSLog(@"frame[%d]--------", i);
    if ( parseFrame() == false) return false;
  }
  
  return true;
}

bool pmxReader::parseFrame()
{
  pmx_frame frame;
  
  getString(&frame.name);
  getString(&frame.name_en);
  
//  NSLog(@"frame.name: %@", frame.name.string());
//  NSLog(@"frame.name_en: %@", frame.name_en.string());
  
  frame.special_frame_flag = getChar();
  frame.frame_element_count = getInteger();
  
  for (int i = 0; i < frame.frame_element_count; i++) {
    
    pmx_frame_element element;
    element.target = getChar();
    
    switch (element.target) {
      case 0: // bone index
        element.index = getPointer(_pHeader->bone_index_size);
        break;
      case 1: // morph index
        element.index = getPointer(_pHeader->morph_index_size);
        break;
      default:
        NSLog(@"pmxReader::parseFrame() unknown frame element target type");
        return false;
    }
    
    frame.frame_elements.push_back( element );
  }
  
  _vecFrames.push_back( frame );
  
  return !(_iOffset > [_data length]);
}

bool pmxReader::parseRigids()
{
  int32_t iRigids = getInteger();
  NSLog(@"Num Rigids: %d", iRigids);
  _iNumRigids = iRigids;
  
  for (int i = 0; i < iRigids; i++) {
//    NSLog(@"rigid[%d]--------", i);
    if ( parseRigid() == false) return false;
  }
  
  return true;
}

bool pmxReader::parseRigid()
{
  pmx_rigid rigid;
  
  getString(&rigid.name);
  getString(&rigid.name_en);
  
//  NSLog(@"rigid.name: %@", rigid.name.string());
//  NSLog(@"rigid.name_en: %@", rigid.name_en.string());
  
  rigid.bone_index = getPointer(_pHeader->bone_index_size);
  
  rigid.group = getChar();
  rigid.collision_group_flag = getShort();
  
  rigid.shape = getChar();
  getFloat3(rigid.size);
  
  getFloat3(rigid.position);
  getFloat3(rigid.rotation);
  
  rigid.mass = getFloat();
  rigid.translation_decay = getFloat();
  rigid.rotation_decay = getFloat();
  rigid.bounce = getFloat();
  rigid.friction = getFloat();
  
  rigid.calculation_type = getChar();
  
  _vecRigids.push_back( rigid );
  
  return !(_iOffset > [_data length]);
}

