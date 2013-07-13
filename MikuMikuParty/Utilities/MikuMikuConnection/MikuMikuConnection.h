//
//  MikuMikuConnection.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <Foundation/Foundation.h>

#import "MikuMikuRequest.h"
#import "MikuMikuResponse.h"
#import "MikuMikuError.h"

@class MikuMikuConnection;

@protocol MikuMikuConnectionDelegate <NSObject>
- (void)mmConnection:(MikuMikuConnection*)connection didFinishLoading:(MikuMikuResponse*)response;
- (void)mmConnection:(MikuMikuConnection*)connection didFailWithError:(MikuMikuError*)error;
@end

@interface MikuMikuConnection : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, retain) MikuMikuRequest *request;
@property (nonatomic, assign) id<MikuMikuConnectionDelegate> delegate;

+ (id)connectionWithRequest:(MikuMikuRequest*)request delegate:(id<MikuMikuConnectionDelegate>)delegate;

@end
