/*
  Copyright (c) 2007-2011, Marcus Müller <znek@mulle-kybernetik.com>.
  All rights reserved.


  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  - Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

  - Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

  - Neither the name of Mulle kybernetiK nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/

#import "NSObject+FUSEOFS.h"
#import "FUSESupport.h"

@implementation NSObject (FUSEOFS)

/* lookup */

- (id)lookupPathComponent:(NSString *)_pc inContext:(id)_ctx {
  return nil;
}


/* reflection */

- (BOOL)isContainer {
  return NO;
}
- (BOOL)isMutable {
  return NO;
}


/* attributes */

- (NSArray *)containerContents {
  return nil;
}
- (NSData *)fileContents {
  return nil;
}
- (NSString *)symbolicLinkTarget {
  return nil; 
}
- (NSDictionary *)fileAttributes {
  NSNumber *perm;
  NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:2];
  if ([self isContainer]) {
    perm = [NSNumber numberWithInt:[self isMutable] ? 0777 : 0555];
    [attrs setObject:NSFileTypeDirectory forKey:NSFileType];
    [attrs setObject:[self symbolicLinkTarget] ? NSFileTypeSymbolicLink
                                               : NSFileTypeDirectory
           forKey:NSFileType];
  }
  else {
    perm = [NSNumber numberWithInt:[self isMutable] ? 0666 : 0444];
		[attrs setObject:[self symbolicLinkTarget] ? NSFileTypeSymbolicLink
                                               : NSFileTypeRegular
           forKey:NSFileType];
  }
  [attrs setObject:perm forKey:NSFilePosixPermissions];
  return attrs;
}
- (NSDictionary *)extendedFileAttributes {
  return nil;
}
- (NSDictionary *)fileSystemAttributes {
  return nil;
}

#ifndef NO_OSX_ADDITIONS
- (NSDictionary *)resourceAttributes {
  NSData *iconData;
  
  if ((iconData = [self iconData])) {
    return [NSDictionary dictionaryWithObject:iconData
                         forKey:kGMUserFileSystemCustomIconDataKey];
  }
  return nil;
}
- (NSDictionary *)finderAttributes {
  if ([self iconData]) {
    NSNumber *finderFlags = [NSNumber numberWithLong:kHasCustomIcon];
    return [NSDictionary dictionaryWithObject:finderFlags
                                       forKey:kGMUserFileSystemFinderFlagsKey];
  }
  return nil;
}
#endif

- (NSData *)iconData {
  return nil;
}

/* write support */

- (BOOL)createFileNamed:(NSString *)_name
  withAttributes:(NSDictionary *)_attrs
{
  return NO;
}

- (BOOL)createContainerNamed:(NSString *)_name
  withAttributes:(NSDictionary *)_attrs
{
  return NO;
}

- (BOOL)writeFileNamed:(NSString *)_name withData:(NSData *)_data {
  return NO;
}

- (BOOL)removeItemNamed:(NSString *)_name {
  return NO;
}

- (BOOL)setFileAttributes:(NSDictionary *)_attrs {
  return NO;
}

- (BOOL)setExtendedAttribute:(NSString *)_name value:(NSData *)_value {
  return NO;
}
- (BOOL)removeExtendedAttribute:(NSString *)_name {
  return NO;
}

@end /* NSObject (FUSEOFS) */

@implementation NSData (FUSEOFS)

- (NSData *)fileContents {
  return self;
}

@end /* NSData (FUSEOFS) */

@implementation NSMutableData (FUSEOFS)

- (BOOL)isMutable {
  return YES;
}

@end /* NSMutableData (FUSEOFS) */

@implementation NSString (FUSEOFS)

- (NSData *)fileContents {
  return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end /* NSString (FUSEOFS) */

@implementation NSMutableString (FUSEOFS)

- (BOOL)isMutable {
  return YES;
}

@end /* NSMutableString (FUSEOFS) */

@implementation NSDictionary (FUSEOFS)

- (id)lookupPathComponent:(NSString *)_pc inContext:(id)_ctx {
  if ([_pc isEqualToString:@"_FinderAttributes"]) return nil;
  return [self objectForKey:_pc];
}

#ifndef NO_OSX_ADDITIONS
- (NSDictionary *)finderAttributes {
  id finderAttributes = [self objectForKey:@"_FinderAttributes"];
  if (finderAttributes) {
    return finderAttributes;
  }
	if ([self iconData]) {
		NSNumber *finderFlags = [NSNumber numberWithLong:kHasCustomIcon];
		return [NSDictionary dictionaryWithObject:finderFlags
                         forKey:kGMUserFileSystemFinderFlagsKey];
  }
  return nil;
}
- (NSDictionary *)resourceAttributes {
	NSData *iconData;
  
	if ((iconData = [self iconData])) {
		return [NSDictionary dictionaryWithObject:iconData
                         forKey:kGMUserFileSystemCustomIconDataKey];
	}
	return nil;
}
#endif

- (NSArray *)containerContents {
  if (![self objectForKey:@"_FinderAttributes"])
    return [self allKeys];
  NSMutableArray *keys = [[[self allKeys] mutableCopy] autorelease];
  [keys removeObject:@"_FinderAttributes"];
  return keys;
}
- (BOOL)isContainer {
  return YES;
}

@end /* NSDictionary (FUSEOFS) */

@implementation NSString (FUSEOFS_FSSupport)

- (NSString *)properlyEscapedFSRepresentation {
#ifndef NO_OSX_ADDITIONS
  static NSString       *colon     = nil;
  static NSCharacterSet *escapeSet = nil;
  
  NSRange         r;
  NSMutableString *proper;
  
  if (!colon) {
    const unichar colonChar = 0xFF1A; // 0xFE55
    colon     = [[NSString alloc] initWithCharacters:&colonChar length:1]; 
    escapeSet = [[NSCharacterSet characterSetWithCharactersInString:@"/:"]
                 copy];
  }
  
  // NOTE: we _always_ need to normalize the string into decomposed form!
  // ref: http://developer.apple.com/qa/qa2001/qa1235.html
  proper = [[self mutableCopy] autorelease];
  CFStringNormalize((CFMutableStringRef)proper, kCFStringNormalizationFormD);
  
  r = [self rangeOfCharacterFromSet:escapeSet];
  if (r.location == NSNotFound)
	  return proper;
  
  r.length = [self length] - r.location;
  [proper replaceOccurrencesOfString:@":" withString:colon options:0 range:r];
  [proper replaceOccurrencesOfString:@"/" withString:@":"  options:0 range:r];
  return proper;

#else

  static NSCharacterSet *escapeSet = nil;
  if (!escapeSet) {
    escapeSet = [[NSCharacterSet characterSetWithCharactersInString:@"/"] copy];
  }

  NSRange r = [self rangeOfCharacterFromSet:escapeSet];
  if (r.location == NSNotFound)
	  return self;

  NSMutableString *proper = [[self mutableCopy] autorelease];
  r.length = [self length] - r.location;
  [proper replaceOccurrencesOfString:@"/" withString:@":" options:0 range:r];
  return proper;
#endif
}

@end /* NSString (FUSEOFS_FSSupport) */
