//
//  WindowLocker+MikuMikuConnection.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "WindowLocker.h"
#import "MikuMikuConnection.h"

@interface WindowLocker (MikuMikuConnection)

+ (id)lockWithRequest:(MikuMikuRequest*)request
succeededHandler:(void(^)(MikuMikuResponse *response))succeededHandler
        failedHandler:(void(^)(MikuMikuError *error))failedHandler;

@end
