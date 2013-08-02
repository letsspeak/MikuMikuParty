//
//  TwitterController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface TwitterController : NSObject

+ (void)getTwitterAccountWithUsername:(NSString*)username
                     succeededHandler:(void(^)(ACAccount *account))succeededHandler
                        failedHandler:(void(^)(void))failedHandler
                 parentViewController:(UIViewController*)parent;

@end