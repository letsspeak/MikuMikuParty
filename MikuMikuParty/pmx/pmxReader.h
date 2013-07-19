//
//  pmxReader.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/20.
//
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"

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

class pmxReader
{
  NSString *_filename;
  int8_t* _pData;
	int32_t _iOffset;
	NSData* _data;
  
  pmx_header* _pHeader;
  pmx_model_info _modelInfo;
  
	int32_t getInteger();
	int16_t getShort();
  int8_t getChar();
	float getFloat();
  bool getString(pmx_string *pString);
  
  bool verifyHeader();
  bool parseHeader();
  bool parseModelInfo();
  
public:
  
  pmxReader();
  ~pmxReader();
  bool init ( NSString* filename );
  bool unload();
  
};