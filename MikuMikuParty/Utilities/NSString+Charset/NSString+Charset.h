//
//  NSString+Charset.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/19.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Charset)

- (NSString*)trimDisabledCharactersForWindowsFilesystem:(int)maxSize;

+ (BOOL)isSJIS:(char*)inp;

@end
