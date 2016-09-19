What is FUSEOFS?
================

The idea of FUSEOFS is to have a framework on top of ~~FUSEObjc~~ sdk-objc
which removes the need of procedural thinking and tracking of state and context
in a central object and instead delegating the traversal of a path to a set
of objects - something I'd call an
Object File System (OFS) on top of sdk-objc.

While sdk-objc itself is object oriented in a way (it's written in Objective-C),
you need to implement a delegate and a number of specific FUSE related methods
in order to implement your concept of a filesystem. It doesn't offer any other
object oriented tools to help you *model* your filesystem. If you want
to expose a complex model graph there's no intuitive tool at hand to just
let you do so, you'll have to wrap that functionality yourself.

This is where FUSEOFS suits as a generic tool.
With FUSEOFS you rather implement a very narrow set of much
more abstracted methods on any object, which, in doing so, automatically can be
exposed as filesystem objects.

What is the general principle behind that?
------------------------------------------

The general idea is to break down all the underlying calls of the filesystem
into two things:

- path traversal, which maps to a *lookup* of objects
- applying a request (i.e. *get content*, *get meta data*, *write data*, etc.)
to the resulting object of that lookup via a standardized method

How do you get at the data?
---------------------------

In order to simplify the concept, I'm only focussing at the read methods.
FUSEOFS implements the following categories on NSObject which deal with
filesystem requests:

- lookup

```
- (NSArray *)containerContents; // containers need to implement this
- (NSData *)fileContents; // files need to implement this
- (NSString *)symbolicLinkTarget; // both files or containers may implement this<
```

- reflection

```
- (BOOL)isContainer;
- (BOOL)isMutable;
```

- attributes

```
- (NSDictionary *)fileAttributes;
- (NSDictionary *)extendedFileAttributes;
- (NSDictionary *)fileSystemAttributes;
```

- MacOS X specific attributes

```
- (NSDictionary *)finderAttributes;
- (NSDictionary *)resourceAttributes;
```

Every object derived from NSObject can instantly act as a filesystem
object. Several methods are very easily implemented (i.e. reflection methods)
as these are used in different contexts as well. Also, some of these methods
are mutually exclusive (container vs. file) and only one or the other needs
to be implemented.

Special semantics like those for the Finder on Mac OS X are implemented in
separate methods. If your objects don't support any of these, you don't need
to implement them - your objects still inherit the default implementation
after all.

FUSEOFS already provides default implementations for various basic objects,
namely:

- NSString, NSMutableString
- NSData, NSMutableData
- NSDictionary, NSMutableDictionary
- NSArray, NSMutableArray

It turns out you don't even need to have more than this to implement a pretty
basic memory filesystem! NSString/NSData represent files, NSDictionary/NSArray
are able to represent directories. It's that simple.

How do you get at the objects?
------------------------------

The only mystery to solve now is how the structure of the filesystem gets
implemented. The concept of FUSEOFS is to implement just a single method:

```
- (id)lookupPathComponent:(NSString *)_pc inContext:(id)_ctx;
```

All container objects in your model need to implement this single method, which
is the central hub for lookup.

Every filesystem path, i.e. ```/foo/bar/baz``` is broken down in its path
components, i.e.

- foo
- bar
- baz

Traversal always starts with a root object, which you either provide or
use the default object (which you would then subclass).

The first path component,
```foo```, is what your root object needs to lookup. Its result is another
object (or ```nil``` if the lookup produced no result) which gets the
request for the next path component, ```bar``` and so on. The last
resulting object in this lookup chain is then asked for its *fileContents*,
*finderAttributes*, whatever depending on the underlying request.
And that's all there is to implement a filesystem in a truly object
oriented way!

If you need to share special context information
from object to object, instead of using global variables you can use the
*_ctx* argument object which is passed on until traversal is concluded.

It goes without saying that this way it's almost trivial to implement
filesystem semantics to any existing backend, i.e. IMAP or LDAP servers.

How does it all blend in with ~~MacFUSE~~ OSXFUSE?
--------------------------------------------------

FUSEOFS provides a delegate implementation for sdk-objc, named
```FUSEObjectFileSystem``` which does all the lowlevel stuff to map
sdk-objc's requests to the objects in FUSEOFS. When implementing your own
filesystem, you should subclass from ```FUSEObjectFileSystem``` and
provide your own root object for the lookup mechanism and possibly adjust
the properties given to FUSE on startup, although most of the time that's
not necessary.

How does it all blend in with GNUstep?
--------------------------------------

FUSEOFS is a GNUstep subproject type, suitable for inclusion in 3rd party
projects. It also comes with the ability to build the sdk-objc part on
platforms, where this isn't provided natively (everything else besides OSX).
I use it on FreeBSD and recently ported it to Linux.
