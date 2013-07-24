//
//  vmdMotionProviderPMX.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//

//
//  vmdMotionProvider.h
//  MikuMikuPhone
//
//  Created by hakuroum on 1/19/11.
//  Copyright 2011 hakuroum@gmail.com. All rights reserved.
//
#import <vector>

#import <Foundation/Foundation.h>
#import "vmdReader.h"
#import "pmdReader.h"
#import "pmxReader.h"
#import "PVRTVector.h"
#import "PVRTQuaternion.h"
#import "vmdDefine.h"

class vmdMotionProviderPMX {
  
	NSMutableDictionary* _dicBones;
  
	float _fCurrentFrame;
	double _dStartTime;
	bool _bLoopPlayback;
	
	uint32_t _uiMaxFrame;
	std::vector<std::vector<motion_item>*> _vecMotions;
	std::vector<bone_stats> _vecMotionsWork;
	std::vector<mmd_bone> _vecBones;
	std::vector<ik_item> _vecIKs;
  
	int32_t	_iCurrentSkinAnimationIndex;
	float	_fSkinAnimationWeight;
	std::vector<skin_item> _vecSkinAnimations;
	int32_t _iCurrentSkinAnimationDataIndex;
	
  bool checkBones( pmxReader* reader, vmdReader* motion );
	void interpolateLinear(float fFrame, motion_item *M0, motion_item *pM1, motion_item *pOut);
	void slerp(float p[], float q[], float r[], double t);
	double bazier(const uint8_t* ip, const int ofs, const int size, const float t);
	void quaternionToMatrix(float* mat, const float* quat);
	void quaternionToMatrixPreserveTranslate(float* mat, const float* quat);
  
	void quaternionMul(float* res, float* r, float* q);
	void updateBoneMatrix( const int32_t i );
  
	void resolveIK();
	void ccdIK( ik_item* pIk);
	void getCurrentPosition( PVRTVec3& vec, int32_t iIndex);
	void clearUpdateFlags( int32_t iCurrentBone, int32_t iTargetBone );
	void makeQuaternion(float* quat, float angle, PVRTVec3 axis );
	
  void bindSkinAnimation( pmxReader* reader, vmdReader* motion );
	void unbindSkinAnimation();
	void updateSkinAnimation();
  
public:
	vmdMotionProviderPMX();
	~vmdMotionProviderPMX();
	
  bool bind( pmxReader* reader, vmdReader* motion );
	bool unbind();
	
	bool update( const double dTime );
	std::vector<bone_stats>* getMatrixPalette() { return &_vecMotionsWork; }
	int32_t getSkinAnimationParameters( float& fWeight );
	
};
