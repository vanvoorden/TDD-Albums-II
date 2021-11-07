//
//  NetworkImageSourceTests.m
//  AlbumsTests
//
//  Copyright © 2021 North Bronson Software
//
//  This Item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. In addition, no permission is required from the rights-holder(s) for scholarly, educational, or non-commercial uses. For other uses, you need to obtain permission from the rights-holder(s).
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <XCTest/XCTest.h>

#import "NetworkImageSource.h"

static CGImageSourceRef _Nullable NetworkImageSourceTestDoubleCreateImageSource(CFDataRef _Nonnull, CFDictionaryRef _Nullable) CF_RETURNS_RETAINED;

static id NetworkImageSourceTestDoubleCreateImageSourceParameterData = 0;
static id NetworkImageSourceTestDoubleCreateImageSourceParameterOptions = 0;
static id NetworkImageSourceTestDoubleCreateImageSourceReturnImageSource = 0;

CGImageSourceRef NetworkImageSourceTestDoubleCreateImageSource(CFDataRef data, CFDictionaryRef options) {
  NetworkImageSourceTestDoubleCreateImageSourceParameterData = (__bridge id)data;
  NetworkImageSourceTestDoubleCreateImageSourceParameterOptions = (__bridge id)options;
  return (__bridge_retained CGImageSourceRef)NetworkImageSourceTestDoubleCreateImageSourceReturnImageSource;
}

static CGImageRef _Nullable NetworkImageSourceTestDoubleCreateImage(CGImageSourceRef _Nonnull, size_t, CFDictionaryRef _Nullable) CF_RETURNS_RETAINED;

static id NetworkImageSourceTestDoubleCreateImageParameterImageSource = 0;
static size_t NetworkImageSourceTestDoubleCreateImageParameterIndex = 0;
static id NetworkImageSourceTestDoubleCreateImageParameterOptions = 0;
static id NetworkImageSourceTestDoubleCreateImageReturnImage = 0;

CGImageRef NetworkImageSourceTestDoubleCreateImage(CGImageSourceRef imageSource, size_t index, CFDictionaryRef options) {
  NetworkImageSourceTestDoubleCreateImageParameterImageSource = (__bridge id)imageSource;
  NetworkImageSourceTestDoubleCreateImageParameterIndex = index;
  NetworkImageSourceTestDoubleCreateImageParameterOptions = (__bridge id)options;
  return (__bridge_retained CGImageRef)NetworkImageSourceTestDoubleCreateImageReturnImage;
}

@interface NetworkImageSourceTestDouble : NetworkImageSource

@end

@implementation NetworkImageSourceTestDouble

@end

@implementation NetworkImageSourceTestDouble (CreateImageSource)

+ (CGImageSourceRef _Nullable (*_Nonnull)(CFDataRef _Nonnull, CFDictionaryRef _Nullable))createImageSource {
  return NetworkImageSourceTestDoubleCreateImageSource;
}

@end

@implementation NetworkImageSourceTestDouble (CreateImage)

+ (CGImageRef _Nullable (*_Nonnull)(CGImageSourceRef _Nonnull, size_t, CFDictionaryRef _Nullable))createImage {
  return NetworkImageSourceTestDoubleCreateImage;
}

@end

@interface NetworkImageSourceTestCase : XCTestCase

@end

@implementation NetworkImageSourceTestCase

@end

@implementation NetworkImageSourceTestCase (TearDown)

- (void)tearDown  {
  NetworkImageSourceTestDoubleCreateImageSourceParameterData = 0;
  NetworkImageSourceTestDoubleCreateImageSourceParameterOptions = 0;
  NetworkImageSourceTestDoubleCreateImageSourceReturnImageSource = 0;
  
  NetworkImageSourceTestDoubleCreateImageParameterImageSource = 0;
  NetworkImageSourceTestDoubleCreateImageParameterIndex = 0;
  NetworkImageSourceTestDoubleCreateImageParameterOptions = 0;
  NetworkImageSourceTestDoubleCreateImageReturnImage = 0;
}

@end

@implementation NetworkImageSourceTestCase (CreateImageSource)

- (void)testCreateImageSource {
  XCTAssert([NetworkImageSource createImageSource] == CGImageSourceCreateWithData);
}

@end

@implementation NetworkImageSourceTestCase (CreateImage)

- (void)testCreateImage {
  XCTAssert([NetworkImageSource createImage] == CGImageSourceCreateImageAtIndex);
}

@end

@implementation NetworkImageSourceTestCase (CreateImageSourceTestDouble)

- (void)testCreateImageSourceTestDouble {
  NetworkImageSourceTestDoubleCreateImageSourceReturnImageSource = [[NSObject alloc] init];
  
  id data = [[NSObject alloc] init];
  id options = [[NSObject alloc] init];
  
  id imageSource = (__bridge_transfer id)[NetworkImageSourceTestDouble createImageSourceWithData:(__bridge CFDataRef)data
                                                                                         options:(__bridge CFDictionaryRef)options];
  
  XCTAssert(NetworkImageSourceTestDoubleCreateImageSourceParameterData == data);
  XCTAssert(NetworkImageSourceTestDoubleCreateImageSourceParameterOptions == options);
  
  XCTAssert(imageSource == NetworkImageSourceTestDoubleCreateImageSourceReturnImageSource);
}

@end

@implementation NetworkImageSourceTestCase (CreateImageTestDouble)

- (void)testCreateImageTestDouble {
  NetworkImageSourceTestDoubleCreateImageReturnImage = [[NSObject alloc] init];
  
  id imageSource = [[NSObject alloc] init];
  size_t index = 1;
  id options = [[NSObject alloc] init];
  
  id image = (__bridge_transfer id)[NetworkImageSourceTestDouble createImageWithImageSource:(__bridge CGImageSourceRef)imageSource
                                                                                    atIndex:index
                                                                                    options:(__bridge CFDictionaryRef)options];
  
  XCTAssert(NetworkImageSourceTestDoubleCreateImageParameterImageSource == imageSource);
  XCTAssert(NetworkImageSourceTestDoubleCreateImageParameterIndex == index);
  XCTAssert(NetworkImageSourceTestDoubleCreateImageParameterOptions == options);
  
  XCTAssert(image == NetworkImageSourceTestDoubleCreateImageReturnImage);
}

@end
