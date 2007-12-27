/*
  Copyright (c) 2007, Marcus Müller <znek@mulle-kybernetik.com>.
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

#import "FUSEObjectFileSystem.h"
#import "NSObject+FUSEOFS.h"

@interface FUSEObjectFileSystem (Private)
- (id)lookupPath:(NSString *)_path;
@end

@implementation FUSEObjectFileSystem

static BOOL         debugLookup = NO;
static NSDictionary *emptyDict  = nil;

+ (void)initialize {
  static BOOL    didInit = NO;
  NSUserDefaults *ud;
  
  if (didInit) return;
  didInit     = YES;
  ud          = [NSUserDefaults standardUserDefaults];
  debugLookup = [ud boolForKey:@"FUSEObjectFileSystemDebugPathLookup"];
  emptyDict   = [[NSDictionary alloc] init];
}

- (NSArray *)pathFromFSPath:(NSString *)_path {
  return [_path pathComponents];
}

- (id)rootObject {
  return self;
}

- (id)lookupPath:(NSString *)_path {
  NSArray  *path;
  id       obj;
  unsigned i, count;
  
  path = [self pathFromFSPath:_path];
  count = [path count];
  if (!count) return nil;
  obj = [self rootObject];
  if (debugLookup)
    NSLog(@"lookup [#0, %@] -> %@", [path objectAtIndex:0], obj);
  for (i = 1; i < count; i++) {
    obj = [obj lookupPathComponent:[path objectAtIndex:i]];
    if (debugLookup)
      NSLog(@"lookup [#%d, %@] -> %@", i, [path objectAtIndex:i], obj);
  }
  return obj;
}

/* required FUSE methods */

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)_path error:(NSError **)_err {
  return [[self lookupPath:_path] directoryContents];
}

- (BOOL)fileExistsAtPath:(NSString *)_path isDirectory:(BOOL *)isDirectory {
  id obj;
  
  obj          = [self lookupPath:_path];
  *isDirectory = [obj isDirectory];
  if ([obj isDirectory]) return YES;
  return [obj isFile];
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)_path
  error:(NSError **)_err
{
  NSDictionary *attr = [[self lookupPath:_path] fileAttributes];
  if (!attr)
    attr = emptyDict;
  return attr;
}

- (NSData *)contentsAtPath:(NSString *)_path {
  return [[self lookupPath:_path] fileContents];
}

- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)_path
  error:(NSError **)_err
{
  return [[self lookupPath:_path] symbolicLinkTarget];
}

/* optional FUSE methods */

- (NSImage *)iconForPath:(NSString *)_path {
  return [[self lookupPath:_path] icon];
}

- (NSDictionary *)attributesOfFileSystemForPath:(NSString *)_path
  error:(NSError **)_err
{
  NSDictionary *attr = [[self lookupPath:_path] fileSystemAttributes];
  if (!attr)
    attr = emptyDict;
  return attr;
}

#if 0
- (NSArray *)extendedAttributesForPath:path error:(NSError **)_err {
// TODO: Implement!
  return nil;
}
#endif

@end /* FUSEObjectFileSystem */
