//
//  WindowLocker+MikuMikuConnection.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "WindowLocker+MikuMikuConnection.h"

@implementation WindowLocker (MikuMikuConnection)

+ (id)lockWithRequest:(MikuMikuRequest*)request
succeededHandler:(void(^)(MikuMikuResponse *response))succeededHandler
        failedHandler:(void(^)(MikuMikuError *error))failedHandler
{
  void(^sh_)(MikuMikuResponse *response)  = [[succeededHandler copy] autorelease];
  void(^fh_)(MikuMikuError *error)  = [[failedHandler copy] autorelease];
  __block WindowLocker *locker = [WindowLocker loadingLocker];
  
  [request performRequestWithSucceededHandler:
   ^(MikuMikuResponse *response) {
     sh_(response);
     [locker close];
   } failedHandler:^(MikuMikuError *error){
     fh_(error);
     [locker close];
   }];
  
  return locker;
}


@end
