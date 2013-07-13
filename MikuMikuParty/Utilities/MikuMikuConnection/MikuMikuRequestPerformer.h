//
//  MikuMikuRequestPerformer.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>
#import "MikuMikuConnection.h"

@interface MikuMikuRequestPerformer : NSObject
<MikuMikuConnectionDelegate>

- (void)performRequest:(MikuMikuRequest*)request;
+ (MikuMikuRequestPerformer*)sharedPerformer;

@end
