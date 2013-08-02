//
//  MikuMikuConnectionServer.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>
#import "MikuMikuRequest.h"

@interface MikuMikuConnectionServer : NSObject

- (NSString*)generateUriWithRequest:(MikuMikuRequest*)request;
- (NSDictionary*)httpHeaderFieldDictionary;

- (void)deleteCookie:(NSString*)name;
- (void)deleteAllCookies;

+ (MikuMikuConnectionServer*)sharedServer;

@end
