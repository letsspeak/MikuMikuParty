//
//  vmdDefine.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//

#ifndef MikuMikuParty_vmdDefine_h
#define MikuMikuParty_vmdDefine_h

const double FRAME_PERSEC = 60.0;
NSString* const STR_IK_KNEE = @"ひざ";

enum JOINT_TYPE {
	JOINT_TYPE_NORMAL,
	JOINT_TYPE_KNEE,
};

struct ik_item {
	uint16_t ik_bone_index;
	uint16_t ik_target_bone_index;
	uint8_t ik_chain_length;
	uint16_t iterations;
	float control_weight;
	std::vector<uint16_t> _vec_ik_child_bone_index;
};

struct motion_item {
	uint32_t iFrame;
	float fPos[ 3 ];
	float fRotation[ 4 ];
	uint8_t	cInterpolation[ 16 ];
};

struct bone_stats {
	bool bUpdated;
	JOINT_TYPE	iJointType;
	int32_t	iCurrentIndex;
	PVRTMat4 matCurrent;
	PVRTMat4 mat;
	float fQuaternion[ 4 ];
};

struct skin_item
{
	int32_t		iIndex;
	uint32_t	iFrame;
	float		Weight;
};

static bool dataSortPredicate(const motion_item& d1, const motion_item& d2)
{
	return d1.iFrame < d2.iFrame;
}

#endif
