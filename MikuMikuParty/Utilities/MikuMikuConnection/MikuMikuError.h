//
//  MikuMikuConnectionError.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>


enum MikuMikuErrorCode {
  MikuMikuErrorCodeUnknown                = -1,
  
  MikuMikuErrorCodeOffline                = 1,
  MikuMikuErrorCodeTimeOut                = 2,
  MikuMikuErrorCodeConnectionFailed       = 3,
  
  MikuMikuErrorCodeInvalidRequestMethod   = 51,
  MikuMikuErrorCodeCannotConvertRequest  = 52,
  
  MikuMikuErrorCodeBadStatusCode          = 101,
  MikuMikuErrorCodeCannotSerializeJson    = 102,
  MikuMikuErrorCodeInvalidResponse        = 103,
  
  MikuMikuErrorCodeSessionTimeOut         = 201,
  
  MikuMikuErrorCodeObsoleteVersion        = 302,
  MikuMikuErrorCodeUnderMaintenance       = 303,
  
  MikuMikuErrorCodeServerReload           = 401,
  MikuMikuErrorCodeServerRetention        = 402,
  MikuMikuErrorCodeServerAction           = 403,
  
  MikuMikuErrorCodeReloginFailed          = 501,
};

typedef enum MikuMikuErrorCode MikuMikuErrorCode;

@interface MikuMikuError : NSError

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *action;

+ (id)errorWithCode:(NSInteger)code;

@end
