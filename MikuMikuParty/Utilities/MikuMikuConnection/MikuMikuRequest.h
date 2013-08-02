//
//  MikuMikuRequest.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
  MikuMikuRequestMethodUndefined   = 0,
  MikuMikuRequestMethodHttpGet     = 1,
  MikuMikuRequestMethodHttpPost    = 2,
}MikuMikuRequestMethod;

@class MikuMikuResponse;
@class MikuMikuError;

@interface MikuMikuRequest : NSObject

@property (nonatomic, assign) MikuMikuRequestMethod method;
@property (nonatomic, retain) NSString *controller;
@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSString *urlPrameterString;
@property (nonatomic, retain) NSMutableDictionary *httpHeaderFields;
@property (nonatomic, retain) NSMutableDictionary *parameters;

@property (nonatomic, copy) void(^succeededHandler)(MikuMikuResponse *response);
@property (nonatomic, copy) void(^failedHandler)(MikuMikuError *error);


- (void)performRequestWithSucceededHandler:(void(^)(MikuMikuResponse *response))succeededHandler
                             failedHandler:(void(^)(MikuMikuError *error))failedHandler;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

+ (id)requestWithController:(NSString*)controller action:(NSString*)action;

@end
