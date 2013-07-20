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
  void *bytes;
  uint32_t length;
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
  uint8_t regid_body_index_size;
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
  
  uint8_t bone_index_size;
  uint8_t bone_count;
  void* bone_num;
  
  uint8_t bone_weight_count;
  float* bone_weight;
  pmx_sdef* sdef[3];
  float edge_magnification;
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
  void *_pIndices;
  
	int32_t getInteger();
	int16_t getShort();
  int8_t getChar();
	float getFloat();
	bool getFloat2(float *f);
	bool getFloat3(float *f);
  bool getString(pmx_string *pString);
  
  bool verifyHeader();
  bool parseHeader();
  bool parseModelInfo();
  bool parseVertices();
  bool parseVertex();
  bool parseIndices();
  
public:
  
  pmxReader();
  ~pmxReader();
  bool init ( NSString* filename );
  bool unload();
  
};