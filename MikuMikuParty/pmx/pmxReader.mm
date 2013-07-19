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

bool pmxReader::getString(pmx_string *pString)
{
  int32_t size = getInteger();
  pString->bytes = (char*)&_pData[ _iOffset ];
  pString->length = size;
  pString->charset = _pHeader->charset;
  
  _iOffset += size;
  if (_iOffset > [_data length]) return false;
  
  return true;
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
  if (_iOffset > [_data length]) return false;
  
  return true;
}

bool pmxReader::parseModelInfo()
{
//  _pModelInfo->name = getString();
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

