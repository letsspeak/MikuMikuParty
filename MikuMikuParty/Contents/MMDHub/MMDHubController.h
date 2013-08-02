//
//  MMDHubController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface MMDHubController : NSObject

- (void)createUserWithTwitterAccount:(ACAccount*)account
                    succeededHandler:(void(^)(void))succeededHandler
                       failedHandler:(void(^)(void))failedHandler;

@end
