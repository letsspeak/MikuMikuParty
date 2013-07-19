//
//  NSString+Charset.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/19.
//
//

#import "NSString+Charset.h"

@implementation NSString (Charset)

// Windowsのファイルシステム上で使用できない文字までをNSStringで返す
- (NSString*)trimDisabledCharactersForWindowsFilesystem:(int)maxSize
{
  if (self.length < maxSize) maxSize = self.length;
  NSString *result = [NSString string];
  for (int i = 0; i < maxSize; i++) {
    NSString *ch = [self substringWithRange:NSMakeRange(i, 1)];
    if ([ch isDisabledCharacterForWindowsFilesystem]) return result;
    result = [result stringByAppendingString:ch];
  }
  return result;
}

- (BOOL)isDisabledCharacterForWindowsFilesystem
{
  if ([self isEqualToString:@"¥¥"]) return YES;
  if ([self isEqualToString:@"/"]) return YES;
  if ([self isEqualToString:@":"]) return YES;
  if ([self isEqualToString:@"*"]) return YES;
  if ([self isEqualToString:@"?"]) return YES;
  if ([self isEqualToString:@""""]) return YES;
  if ([self isEqualToString:@"<"]) return YES;
  if ([self isEqualToString:@">"]) return YES;
  if ([self isEqualToString:@"|"]) return YES;
  return NO;
}

// Shift_JIS判定
+ (BOOL)isSJIS:(char*)inp
{
  int  cnt = 0;
  
  while (*inp) {
    if ((Byte)*inp <= 0x7F) {
      inp++;      // ASCII
    } else if ((Byte)*inp>=0x81 && (Byte)*inp<=0x9F &&
               (((Byte)*(inp+1)>=0x40 && (Byte)*(inp+1)<=0x7E) || ((Byte)*(inp+1)>=0x80 && (Byte)*(inp+1)<=0xFC))) {
      inp += 2;   // 漢字
      cnt++;
    } else if ((Byte)*inp>=0xA1 && (Byte)*inp<=0xDF) {
      inp++;      // 半角カナ
      cnt++;
    } else if ((Byte)*inp>=0xE0 && (Byte)*inp<=0xEF &&
               (((Byte)*(inp+1)>=0x40 && (Byte)*(inp+1)<=0x7E) || ((Byte)*(inp+1)>=0x80 && (Byte)*(inp+1)<=0xFC))) {
      inp += 2;   // 漢字
      cnt++;
    } else {
      return 0;
    }
  }
  
  return (BOOL)cnt; // 日本語文字数
}

@end
