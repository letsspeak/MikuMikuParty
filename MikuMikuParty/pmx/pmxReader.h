//
//  pmxReader.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/20.
//
//

#import <vector>
#import <Foundation/Foundation.h>
#import "Texture2D.h"

#define LogFloat2(s, f)   NSLog(@"%@: (%f, %f)", s, f[0], f[1])
#define LogFloat3(s, f)   NSLog(@"%@: (%f, %f, %f)", s, f[0], f[1], f[2])
#define LogFloat4(s, f)   NSLog(@"%@: (%f, %f, %f, %f)", s, f[0], f[1], f[2], f[3])



struct pmx_string
{
  uint32_t length;
  void *bytes;
  uint8_t charset;
  NSString *string() {
    NSData *data = [NSData dataWithBytes:bytes length:length];
    if (charset == 0) return [[[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding] autorelease];
    if (charset == 1) return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return nil;
  }
};

struct pmx_header
{
  uint8_t charset;
  uint8_t additional_uv_count;
  uint8_t vertex_index_size;
  uint8_t texture_index_size;
  uint8_t material_index_size;
  uint8_t bone_index_size;
  uint8_t morph_index_size;
  uint8_t rigid_index_size;
};

struct pmx_model_info
{
  pmx_string name;
  pmx_string name_en;
  pmx_string comment;
  pmx_string comment_en;
};

typedef float pmx_additional_uv[4];
typedef float pmx_sdef[3];

struct pmx_vertex
{
  float pos[3];
  float normal_vec[3];
  float uv[2];
  
  uint8_t additional_ux_count;
  pmx_additional_uv* additional_uv;
  
  uint8_t weight_type;
  
  uint8_t bone_count;
  
  int32_t bone_num[4];
  uint8_t bone_weight_count;
  float bone_weight[4];
  pmx_sdef* sdef[3];
  float edge_magnification;
  
  int32_t	getBoneIndex( const int32_t i )
	{
		switch( i )
		{
			case 0:
				return bone_num[ 0 ];
			case 1:
				if( bone_weight[0] < 100 )
				{
					return bone_num[ 1 ];
				}
				else return -1;
			default:
				return -1;
		}
	}
};

struct pmx_material
{
  pmx_string name;
  pmx_string name_en;
  
  float diffuse_color[3];
  float alpha;
  float specular_color[3];
  float intensity;
  float ambient_color[3];
  
  uint8_t edge_flag;
  float edge_color[3];
  float edge_color_alpha;
  float edge_size;
  
  void* normal_texture;
  void* sphere_texture;
  uint8_t sphere_mode;
  
  uint8_t shared_toon_flag;
  int32_t toon_texture_index;
  
  pmx_string memo;
  uint32_t face_vert_count;
  
  uint32_t _tex;
  Texture2D* _tex2D;
};

#define PMX_BONE_FLAG_TAIL_SPECIFY_TYPE_BIT   0x0001
#define PMX_BONE_FLAG_ROTATABLE_BIT           0x0002
#define PMX_BONE_FLAG_MOVABLE_BIT             0x0004
#define PMX_BONE_FLAG_DISPLAY_BIT             0x0008
#define PMX_BONE_FLAG_OPERABLE_BIT            0x0010
#define PMX_BONE_FLAG_IK_BIT                  0x0020
#define PMX_BONE_FLAG_LOCAL_GRANTEES_BIT      0x0080
#define PMX_BONE_FLAG_ROTATION_GRANT_BIT      0x0100
#define PMX_BONE_FLAG_MOVE_GRANT_BIT          0x0200
#define PMX_BONE_FLAG_FIXED_AXIS_BIT          0x0400
#define PMX_BONE_FLAG_LOCAL_AXIS_BIT          0x0800
#define PMX_BONE_FLAG_PHYSICS_ORDER_BIT       0x1000
#define PMX_BONE_FLAG_PARENT_TRANSFORM_BIT    0x2000

struct pmx_ik_link
{
  int32_t bone_index;
  uint8_t* radian_limitation_flag;
  float* lower_limit_vector;
  float* upper_limit_vector;
};


struct pmx_bone
{
  pmx_string name;
  pmx_string name_en;
  
  float bone_head_pos[3];
  int32_t ik_parent_bone_index;
  uint32_t transform_level;
  
  uint16_t bone_flag;
  
  void* tail_pos;
  
  int32_t rot_move_parent_bone_index;
  float* rot_move_rate;
  
  float* fixed_axis_vector;
  
  float* x_axis_vector;
  float* z_axis_vector;
  
  uint32_t* parent_transform_key;
  
  int32_t ik_target_bone_index;
  uint32_t ik_loop_count;
  float* ik_radian_limitaion;
  
  uint32_t ik_link_count;
  std::vector< pmx_ik_link > ik_links;
};

#define PMX_MORPH_TYPE_GROUP              0
#define PMX_MORPH_TYPE_VERTEX             1
#define PMX_MORPH_TYPE_BONE               2
#define PMX_MORPH_TYPE_UV                 3
#define PMX_MORPH_TYPE_ADDITIONAL_UV_1    4
#define PMX_MORPH_TYPE_ADDITIONAL_UV_2    5
#define PMX_MORPH_TYPE_ADDITIONAL_UV_3    6
#define PMX_MORPH_TYPE_ADDITIONAL_UV_4    7
#define PMX_MORPH_TYPE_MATERIAL           8

union pmx_morph_data
{
  struct vertex_morph
  {
    int32_t vertex_index;
    float offset_vector[3];
  }vertex_morph;
  
  struct uv_morph
  {
    void* vertex_index;
    float* offset_vector;
  }uv_morph;
  
  struct bone_morph
  {
    void* bone_index;
    float* movement_vector;
    float* rotation_vector;
  }bone_morph;
  
  struct material_morph
  {
    void* material_index;
    uint8_t* offset_calculation_type;
    float* diffuse_color;
    float* specular_color;
    float* specular_coefficient;
    float* ambient_color;
    float* edge_color;
    float* edge_size;
    float* texture_coefficient;
    float* sphere_texture_coefficient;
    float* toon_texture_coefficient;
  }material_morph;
  
  struct group_morph
  {
    void* morph_index;
    float* morph_rate;
  }group_morph;
};

struct pmx_morph
{
  pmx_string name;
  pmx_string name_en;
  
  uint8_t operation_panel;
  uint8_t type;
  
  uint32_t offset_count;
  std::vector< pmx_morph_data > offset_datas;
};

struct pmx_frame_element {
  uint8_t target;
  void* index;
};

struct pmx_frame
{
  pmx_string name;
  pmx_string name_en;
  uint8_t special_frame_flag;
  uint32_t frame_element_count;
  std::vector< pmx_frame_element > frame_elements;
};

struct pmx_rigid
{
  pmx_string name;
  pmx_string name_en;
  
  void* bone_index;
  
  uint8_t group;
  uint16_t collision_group_flag;
  
  uint8_t shape;
  float size[3];
  
  float position[3];
  float rotation[3];
  
  float mass;
  float translation_decay;
  float rotation_decay;
  float bounce;
  float friction;
  
  uint8_t calculation_type;
};

struct pmx_joint {
  pmx_string name;
  pmx_string name_en;
  uint8_t type;
  
  void* rigid_a_index;
  void* rigid_b_index;
  
  float* position;
  float* rotation;
  
  float* lower_translation_limit;
  float* upper_translation_limit;
  float* lower_rotation_limit;
  float* upper_rotation_limit;
  
  float* translation_spring_factor;
  float* rotation_spring_factor;
};

class pmxReader
{
  NSString *_filename;
  int8_t* _pData;
	int32_t _iOffset;
	NSData* _data;
  
  pmx_header* _pHeader;
  pmx_model_info _modelInfo;
  
  int32_t _iNumVertices;
  std::vector< pmx_vertex > _vecVertices;
  
  int32_t _iNumIndices;
  std::vector< int32_t > _vecIndices;
  void *_pIndices;
  
  int32_t _iNumTextures;
  std::vector< pmx_string > _vecTextures;
  
  int32_t _iNumMaterials;
  std::vector< pmx_material > _vecMaterials;
  
  int32_t _iNumBones;
  std::vector< pmx_bone > _vecBones;
  
  int32_t _iNumMorphs;
  std::vector< pmx_morph > _vecMorphs;
  
  int32_t _iNumFrames;
  std::vector< pmx_frame > _vecFrames;
  
  int32_t _iNumRigids;
  std::vector< pmx_rigid > _vecRigids;
  
  int32_t _iNumJoints;
  std::vector< pmx_joint > _vecJoints;
  
	int32_t getInteger();
	int16_t getShort();
  int8_t getChar();
	float getFloat();
	bool getFloat2(float f[2]);
	bool getFloat3(float f[3]);
  bool getString(pmx_string *pString);
  void* getPointer(int32_t size);
  int32_t getVertexIndex(uint8_t size);
  int32_t getIndex(uint8_t size);
  
  bool verifyHeader();
  bool parseHeader();
  bool parseModelInfo();
  bool parseVertices();
  bool parseVertex();
  bool parseIndices();
  bool parseTextures();
  bool parseMaterials();
  bool parseMaterial();
  bool parseBones();
  bool parseBone();
  bool parseMorphs();
  bool parseMorph();
  bool parseFrames();
  bool parseFrame();
  bool parseRigids();
  bool parseRigid();
  bool parseJoints();
  bool parseJoint();
  
public:
  
  pmxReader();
  ~pmxReader();
  bool init ( NSString* filename );
  bool unload();
  
  NSString *getRootPath();
  
  uint8_t vertexIndexSize() { return _pHeader->vertex_index_size; }
  
  int32_t getNumVertices() { return _iNumVertices; }
  std::vector< pmx_vertex > getVertices() { return _vecVertices; }
  
  int32_t getNumIndices() { return _iNumIndices; }
	void* getIndices() { return _pIndices; }
  std::vector<int32_t> getVecIndices() { return _vecIndices; }
  
  std::vector<pmx_string> getTextures() { return _vecTextures; }
  
  int32_t getNumMaterials() { return _iNumMaterials; }
  std::vector< pmx_material > getMaterials() { return _vecMaterials; }
  
  int32_t getNumBones() { return _iNumBones; }
  std::vector< pmx_bone > getBones() { return _vecBones; }
  
  int32_t getNumMorphs() { return _iNumMorphs; }
  std::vector< pmx_morph > getMorphs() { return _vecMorphs; }
};