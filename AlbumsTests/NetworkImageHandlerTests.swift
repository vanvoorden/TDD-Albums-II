//
//  NetworkImageHandlerTests.swift
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

final class NetworkImageHandlerTestCase : XCTestCase {
  private typealias NetworkImageHandlerTestDouble = NetworkImageHandler<DataHandlerTestDouble, ImageSerializationTestDouble>
}

extension NetworkImageHandlerTestCase {
  private struct DataHandlerTestDouble : NetworkImageHandlerDataHandler {
    static var parameterData: Data?
    static var parameterResponse: URLResponse?
    static var returnData: Data?
    static let returnError = NSErrorTestDouble()
    
    static func data(
      with data: Data,
      response: URLResponse
    ) throws -> Data {
      self.parameterData = data
      self.parameterResponse = response
      guard
        let returnData = self.returnData
      else {
        throw self.returnError
      }
      return returnData
    }
  }
}

extension NetworkImageHandlerTestCase {
  private struct ImageSerializationTestDouble : NetworkImageHandlerImageSerialization {
    static var parameterData: Data?
    static var returnImage: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func image(with data: Data) throws -> NSObject {
      self.parameterData = data
      guard
        let returnImage = self.returnImage
      else {
        throw self.returnError
      }
      return returnImage
    }
  }
}

extension NetworkImageHandlerTestCase {
  override func tearDown() {
    DataHandlerTestDouble.parameterData = nil
    DataHandlerTestDouble.parameterResponse = nil
    DataHandlerTestDouble.returnData = nil
    
    ImageSerializationTestDouble.parameterData = nil
    ImageSerializationTestDouble.returnImage = nil
  }
}

extension NetworkImageHandlerTestCase {
  func testMimeTypeError() {
    DataHandlerTestDouble.returnData = nil
    
    ImageSerializationTestDouble.returnImage = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
    
    XCTAssertThrowsError(
      try NetworkImageHandlerTestDouble.image(
        with: DataTestDouble(),
        response: response
      )
    ) { error in
      XCTAssertNil(DataHandlerTestDouble.parameterData)
      XCTAssertNil(DataHandlerTestDouble.parameterResponse)
      
      XCTAssertNil(ImageSerializationTestDouble.parameterData)
      
      if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .mimeTypeError
        )
        XCTAssertNil(error.underlying)
      }
    }
  }
}

extension NetworkImageHandlerTestCase {
  func testDataHandlerError() {
    DataHandlerTestDouble.returnData = nil
    
    ImageSerializationTestDouble.returnImage = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
    
    XCTAssertThrowsError(
      try NetworkImageHandlerTestDouble.image(
        with: DataTestDouble(),
        response: response
      )
    ) { error in
      XCTAssertEqual(
        DataHandlerTestDouble.parameterData,
        DataTestDouble()
      )
      XCTAssertIdentical(
        DataHandlerTestDouble.parameterResponse,
        response
      )
      
      XCTAssertNil(ImageSerializationTestDouble.parameterData)
      
      if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .dataHandlerError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            DataHandlerTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkImageHandlerTestCase {
  func testImageSerializationError() {
    DataHandlerTestDouble.returnData = DataTestDouble()
    
    ImageSerializationTestDouble.returnImage = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
    
    XCTAssertThrowsError(
      try NetworkImageHandlerTestDouble.image(
        with: DataTestDouble(),
        response: response
      )
    ) { error in
      XCTAssertEqual(
        DataHandlerTestDouble.parameterData,
        DataTestDouble()
      )
      XCTAssertIdentical(
        DataHandlerTestDouble.parameterResponse,
        response
      )
      
      XCTAssertEqual(
        ImageSerializationTestDouble.parameterData,
        DataHandlerTestDouble.returnData
      )
      
      if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .imageSerializationError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            ImageSerializationTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkImageHandlerTestCase {
  func testSuccess() {
    DataHandlerTestDouble.returnData = DataTestDouble()
    
    ImageSerializationTestDouble.returnImage = NSObject()
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
    
    XCTAssertNoThrow(
      try {
        let image = try NetworkImageHandlerTestDouble.image(
          with: DataTestDouble(),
          response: response
        )
        
        XCTAssertEqual(
          DataHandlerTestDouble.parameterData,
          DataTestDouble()
        )
        XCTAssertIdentical(
          DataHandlerTestDouble.parameterResponse,
          response
        )
        
        XCTAssertEqual(
          ImageSerializationTestDouble.parameterData,
          DataHandlerTestDouble.returnData
        )
        
        XCTAssertIdentical(
          image,
          ImageSerializationTestDouble.returnImage
        )
      }()
    )
  }
}
