//
//  MMDHubController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import "MMDHubController.h"
#import <Twitter/Twitter.h>
#import "MikuMikuConnection.h"
#import "MikuMikuConnectionServer.h"
#import "WindowLocker+MikuMikuConnection.h"

@implementation MMDHubController

- (void)createUserWithTwitterAccount:(ACAccount*)account
                    succeededHandler:(void(^)(void))succeededHandler
                       failedHandler:(void(^)(void))failedHandler
{
  void(^_sh)(void) = [[succeededHandler retain] autorelease];
  void(^_fh)(void) = [[failedHandler retain] autorelease];
  
  NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
  TWRequest *twRequest = [[[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET] autorelease];
  [twRequest setAccount:account];
  
  NSURLRequest *signedURLRequest = [twRequest signedURLRequest];
  NSString *serviceProvider = [[signedURLRequest URL] absoluteString];
  NSString *authorization = [signedURLRequest valueForHTTPHeaderField:@"Authorization"];
  
  NSLog(@"X-Auth-Service-Provider=%@", serviceProvider );
  NSLog(@"X-Verify-Credentials-Authorization=%@", authorization );
  
  MikuMikuRequest *request = [MikuMikuRequest requestWithController:@"user" action:@"create"];
  request.method = MikuMikuRequestMethodHttpPost;
  [request.httpHeaderFields setObject:serviceProvider forKey:@"X-Auth-Service-Provider"];
  [request.httpHeaderFields setObject:authorization forKey:@"X-Verify-Credentials-Authorization"];
  [request.parameters setObject:[self generateSignature] forKey:@"signature"];
  
  __block MMDHubController *weakSelf = self;
  [WindowLocker lockWithRequest:request
               succeededHandler:
   ^(MikuMikuResponse *response){
     
     NSLog(@"response.responses = %@", response.responses);
     
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     [userDefaults setObject:response.responses[@"password"] forKey:MMP_PASSWORD_KEY];
     [userDefaults setObject:response.responses[@"user_id"] forKey:MMP_USER_ID_KEY];
     [userDefaults synchronize];
     
     [weakSelf loginWithSucceededHandler:^(void){
       if (_sh) _sh();
     } failedHandler:^(void){
       if (_fh) _fh();
     }];
   }
                  failedHandler:
   ^(MikuMikuError *error){
     
     NSLog(@"user/create failed with error:¥n%@", error);
     if (_fh) _fh();
     
   }];
  
}

- (NSString*)generateSignature
{
  CFUUIDRef uuidObj = CFUUIDCreate(nil);
  NSString *signature = [NSString stringWithString:CFBridgingRelease( CFUUIDCreateString(nil, uuidObj) )];
  CFRelease(uuidObj);
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:signature forKey:MMP_SIGNATURE_KEY];
  [defaults synchronize];
  
  return signature;
}

#pragma mark - login

- (void)loginWithSucceededHandler:(void(^)(void))succeededHandler
                    failedHandler:(void(^)(void))failedHandler
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *signature = [userDefaults objectForKey:MMP_SIGNATURE_KEY];
  NSString *password = [userDefaults objectForKey:MMP_PASSWORD_KEY];
  
  if (signature == nil || password == nil) {
    failedHandler();
    return;
  }
  
  // for debug
  [[MikuMikuConnectionServer sharedServer] deleteAllCookies];
  
  void(^_sh)(void) = [[succeededHandler retain] autorelease];
  void(^_fh)(void) = [[failedHandler retain] autorelease];
  
  MikuMikuRequest *request = [MikuMikuRequest requestWithController:@"user" action:@"login"];
  request.method = MikuMikuRequestMethodHttpPost;
  [request.parameters setObject:signature forKey:@"signature"];
  [request.parameters setObject:password forKey:@"password"];
  
  [WindowLocker lockWithRequest:request
               succeededHandler:
   ^(MikuMikuResponse *response){
     if (_sh) _sh();
   }
                  failedHandler:
   ^(MikuMikuError *error){
     NSLog(@"user/login failed with error:¥n%@", error);
     if (_fh) _fh();
   }];
}

@end
