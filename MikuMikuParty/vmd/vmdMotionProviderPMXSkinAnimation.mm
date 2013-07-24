//
//  vmdMotionProviderPMXSkinAnimation.mm
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/24.
//
//
#include <algorithm>
#import "vmdMotionProviderPMX.h"

int32_t vmdMotionProviderPMX::getSkinAnimationParameters( float& fWeight )
{
	fWeight = _fSkinAnimationWeight;
	return _iCurrentSkinAnimationDataIndex;
}

void vmdMotionProviderPMX::updateSkinAnimation()
{
	//
	//1. get current motion
	//
	skin_item* pCurrentItem = &_vecSkinAnimations[_iCurrentSkinAnimationIndex];
	skin_item* pNextItem = &_vecSkinAnimations[_iCurrentSkinAnimationIndex + 1];
	
	//Next index?
	while( pNextItem->iFrame <= _fCurrentFrame )
	{
		if( _iCurrentSkinAnimationIndex < _vecSkinAnimations.size() -2 )
		{
			_iCurrentSkinAnimationIndex++;
			pCurrentItem = pNextItem;
			pNextItem = &_vecSkinAnimations[_iCurrentSkinAnimationIndex + 1];
		}
		else
		{
			//Runnning out of motion.
			pCurrentItem = pNextItem;
			pNextItem = NULL;
			
			_fSkinAnimationWeight = 1.f;
			_iCurrentSkinAnimationDataIndex = pCurrentItem->iIndex;
			return;
		}
	}
	
	int32_t iDiff = pNextItem->iFrame - pCurrentItem->iFrame;
	float a0 = _fCurrentFrame - pCurrentItem->iFrame;
	_fSkinAnimationWeight = a0 / iDiff;
	_iCurrentSkinAnimationDataIndex = pCurrentItem->iIndex;
}

void vmdMotionProviderPMX::bindSkinAnimation( pmxReader* reader, vmdReader* motion )
{
	int32_t iNumMorphs = reader->getNumMorphs();
  std::vector< pmx_morph > vecMorph = reader->getMorphs();
	NSMutableDictionary* dicSkinName = [[NSMutableDictionary alloc] init];
  
	for( int32_t i = 0; i < iNumMorphs; ++i )
	{
		NSString* strSkinName = vecMorph[i].name.string();
		
		if( strSkinName )
		{
			[dicSkinName setObject:[NSNumber numberWithInteger:i] forKey:strSkinName];
			NSLog( @"Skin: %@", strSkinName );
		}
	}
  
	int32_t iNumAnimations = motion->getNumSkins();
	vmd_skin* pAnimation = motion->getSkins();
  
	_vecSkinAnimations.clear();
	for( int32_t i = 0; i < iNumAnimations; ++i )
	{
		NSString* strSkinName = [NSString stringWithCString:pAnimation[ i ].SkinName encoding:NSShiftJISStringEncoding];
		
		NSNumber* num = [dicSkinName objectForKey:strSkinName];
		if( num != nil )
		{
			skin_item item;
			item.iIndex = [num intValue];
			item.Weight = pAnimation[ i ].Weight;
			item.iFrame = pAnimation[ i ].FlameNo;
			
			_vecSkinAnimations.push_back( item );
		}
	}
	
	_iCurrentSkinAnimationIndex = 0;
	[dicSkinName release];
}

void vmdMotionProviderPMX::unbindSkinAnimation()
{
	_vecSkinAnimations.clear();
}