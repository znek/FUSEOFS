/*
  Copyright (c) 2010, Marcus Müller <znek@mulle-kybernetik.com>.
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

#import "FUSEOFSMemoryContainer.h"
#import "NSObject+FUSEOFS.h"
#import "FUSEOFSMemoryFile.h"


@interface FUSEOFSMemoryContainer (Private)
- (void)touch;
@end

@implementation FUSEOFSMemoryContainer

static NSArray *emptyArray = nil;

+ (void)initialize {
  static BOOL didInit = NO;

  if (didInit) return;
  didInit    = YES;
  emptyArray = [[NSArray alloc] init];
}

- (id)initWithCapacity:(NSUInteger)_numItems {
  self = [self init];
  if (self) {
    self->folder = [[NSMutableDictionary alloc] initWithCapacity:_numItems];
  }
  return self;
}

- (void)dealloc {
	[self->folder release];
	[super dealloc];
}

/* public */

- (void)setItem:(id)_item forName:(NSString *)_name {
  if (!self->folder)
    self->folder = [[NSMutableDictionary alloc] initWithCapacity:5];
  [self->folder setObject:_item forKey:_name];
  [self touch];
}

- (NSUInteger)count {
  return self->folder ? [self->folder count] : 0;
}

- (NSArray *)allItems {
  if (!self->folder)
    return emptyArray;

  return [self->folder allValues];
}

/* private */

- (void)touch {
  [self->attrs setObject:[NSCalendarDate date] forKey:NSFileModificationDate];
}

/* FUSEOFS */

- (id)lookupPathComponent:(NSString *)_pc inContext:(id)_ctx {
  return [self->folder objectForKey:_pc];
}

/* reflection */

- (BOOL)isContainer {
  return YES;
}
- (BOOL)isMutable {
	return YES;
}

/* read */

- (NSArray *)containerContents {
  if (!self->folder)
    return emptyArray;

  return [self->folder allKeys];
}

/* write */

- (BOOL)createFileNamed:(NSString *)_name
	withAttributes:(NSDictionary *)_attrs
{
  id obj = [self->folder objectForKey:_name];
  if (obj) return NO;

  FUSEOFSMemoryFile *item = [[FUSEOFSMemoryFile alloc] init];
  [item setFileAttributes:_attrs];
  [self setItem:item forName:_name];
  [item release];
  return YES;
}

- (BOOL)createContainerNamed:(NSString *)_name
  withAttributes:(NSDictionary *)_attrs
{
  id obj = [self->folder objectForKey:_name];
  if (obj) return NO;

  FUSEOFSMemoryContainer *item = [[FUSEOFSMemoryContainer alloc] init];
  [item setFileAttributes:_attrs];
  [self setItem:item forName:_name];
  [item release];
  return YES;
}

- (BOOL)writeFileNamed:(NSString *)_name withData:(NSData *)_data {
  FUSEOFSMemoryFile *item = [self->folder objectForKey:_name];
  if (!item) {
    FUSEOFSMemoryFile *item = [[FUSEOFSMemoryFile alloc] init];
    [self setItem:item forName:_name];
    [item release];
  }
  [item setFileContents:_data];
  return YES;
}

- (BOOL)removeItemNamed:(NSString *)_name {
  if (![self->folder objectForKey:_name]) return NO;
  [self->folder removeObjectForKey:_name];
  [self touch];
	return YES;
}

- (void)removeAllObjects {
  [self->folder removeAllObjects];
  [self touch];
}

- (void)addEntriesFromContainer:(id)container {
  NSArray *names = [container containerContents];
  NSUInteger count = names ? [names count] : 0;
  if (count == 0)
    return;
  for (NSUInteger i = 0; i < count; i++) {
    NSString *name = [names objectAtIndex:i];
    id obj = [container lookupPathComponent:name inContext:nil];
    [self setItem:obj forName:name];
  }
}

@end /* FUSEOFSMemoryContainer */
