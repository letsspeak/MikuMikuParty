//
//  MikuMikuResponse.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>

@class MikuMikuRequest;

@interface MikuMikuResponse : NSObject

@property (nonatomic, retain) NSMutableDictionary *responses;
@property (nonatomic, retain) MikuMikuRequest *request;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

+ (id)responseWithJsonDictionary:(NSDictionary*)jsonDictionary request:(MikuMikuRequest*)request;

@end
