//
//  MikuMikuDownloader.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/17.
//
//

#import <Foundation/Foundation.h>
#import "MikuMikuError.h"

@interface MikuMikuDownloader : NSObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *filePath;

// for NSURLConnection
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;

// for temporaryDownload
@property (nonatomic, assign) BOOL isTemporaryDownload;
@property (nonatomic, copy) void(^temporarySucceededHandler)(NSString *temporaryPath);
@property (nonatomic, copy) void(^temporaryFailedHandler)(MikuMikuError *error);
@property (nonatomic, retain) NSString *temporaryDirectory;

+ (void)temporaryDownloadWithUrl:(NSString*)url
                succeededHandler:(void(^)(NSString *temporaryPath))succeededHandler
                   failedHandler:(void(^)(MikuMikuError *error))failedHandler;

@end
