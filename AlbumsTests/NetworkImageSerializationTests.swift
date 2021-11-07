//
//  NetworkImageSerializationTests.swift
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

import XCTest

final class NetworkImageSerializationTestCase : XCTestCase {
  private typealias NetworkImageSerializationTestDouble = NetworkImageSerialization<ImageSourceTestDouble>
}

extension NetworkImageSerializationTestCase {
  private struct ImageSourceTestDouble : NetworkImageSerializationImageSource {
    static var imageSourceParameterData: CFData?
    static var imageSourceParameterOptions: CFDictionary?
    static var imageSourceReturnImageSource: NSObject?
    
    static func createImageSource(
      with data: CFData,
      options: CFDictionary?
    ) -> NSObject? {
      self.imageSourceParameterData = data
      self.imageSourceParameterOptions = options
      return self.imageSourceReturnImageSource
    }
    
    static var imageParameterImageSource: NSObject?
    static var imageParameterIndex: Int?
    static var imageParameterOptions: CFDictionary?
    static var imageReturnImage: NSObject?
    
    static func createImage(
      with imageSource: NSObject,
      at index: Int,
      options: CFDictionary?
    ) -> NSObject? {
      self.imageParameterImageSource = imageSource
      self.imageParameterIndex = index
      self.imageParameterOptions = options
      return self.imageReturnImage
    }
  }
}

extension NetworkImageSerializationTestCase {
  override func tearDown() {
    ImageSourceTestDouble.imageSourceParameterData = nil
    ImageSourceTestDouble.imageSourceParameterOptions = nil
    ImageSourceTestDouble.imageSourceReturnImageSource = nil
    
    ImageSourceTestDouble.imageParameterImageSource = nil
    ImageSourceTestDouble.imageParameterIndex = nil
    ImageSourceTestDouble.imageParameterOptions = nil
    ImageSourceTestDouble.imageReturnImage = nil
  }
}

extension NetworkImageSerializationTestCase {
  func testImageSourceError() {
    ImageSourceTestDouble.imageSourceReturnImageSource = nil
    
    ImageSourceTestDouble.imageReturnImage = nil
    
    XCTAssertThrowsError(
      try NetworkImageSerializationTestDouble.image(with: DataTestDouble())
    ) { error in
      XCTAssertEqual(
        ImageSourceTestDouble.imageSourceParameterData as Data?,
        DataTestDouble()
      )
      XCTAssertNil(ImageSourceTestDouble.imageSourceParameterOptions)
      
      XCTAssertNil(ImageSourceTestDouble.imageParameterImageSource)
      XCTAssertNil(ImageSourceTestDouble.imageParameterIndex)
      XCTAssertNil(ImageSourceTestDouble.imageParameterOptions)

      if let error = try? XCTUnwrap(error as? NetworkImageSerializationTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .imageSourceError
        )
        XCTAssertNil(error.underlying)
      }
    }
  }
}

extension NetworkImageSerializationTestCase {
  func testImageError() {
    ImageSourceTestDouble.imageSourceReturnImageSource = NSObject()
    
    ImageSourceTestDouble.imageReturnImage = nil
    
    XCTAssertThrowsError(
      try NetworkImageSerializationTestDouble.image(with: DataTestDouble())
    ) { error in
      XCTAssertEqual(
        ImageSourceTestDouble.imageSourceParameterData as Data?,
        DataTestDouble()
      )
      XCTAssertNil(ImageSourceTestDouble.imageSourceParameterOptions)
      
      XCTAssertIdentical(
        ImageSourceTestDouble.imageParameterImageSource,
        ImageSourceTestDouble.imageSourceReturnImageSource
      )
      XCTAssertEqual(
        ImageSourceTestDouble.imageParameterIndex,
        0
      )
      XCTAssertNil(ImageSourceTestDouble.imageSourceParameterOptions)

      if let error = try? XCTUnwrap(error as? NetworkImageSerializationTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .imageError
        )
        XCTAssertNil(error.underlying)
      }
    }
  }
}

extension NetworkImageSerializationTestCase {
  func testSuccess() {
    ImageSourceTestDouble.imageSourceReturnImageSource = NSObject()
    
    ImageSourceTestDouble.imageReturnImage = NSObject()
    
    XCTAssertNoThrow(
      try {
        let image = try NetworkImageSerializationTestDouble.image(with: DataTestDouble())
        
        XCTAssertEqual(
          ImageSourceTestDouble.imageSourceParameterData as Data?,
          DataTestDouble()
        )
        XCTAssertNil(ImageSourceTestDouble.imageSourceParameterOptions)
        
        XCTAssertIdentical(
          ImageSourceTestDouble.imageParameterImageSource,
          ImageSourceTestDouble.imageSourceReturnImageSource
        )
        XCTAssertEqual(
          ImageSourceTestDouble.imageParameterIndex,
          0
        )
        XCTAssertNil(ImageSourceTestDouble.imageSourceParameterOptions)
        
        XCTAssertIdentical(
          image,
          ImageSourceTestDouble.imageReturnImage
        )
      }()
    )
  }
}
