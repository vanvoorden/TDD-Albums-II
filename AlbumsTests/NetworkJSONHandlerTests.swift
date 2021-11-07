//
//  NetworkJSONHandlerTests.swift
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

final class NetworkJSONHandlerTestCase : XCTestCase {
  
}

extension NetworkJSONHandlerTestCase {
  private struct DataHandlerTestDouble : NetworkJSONHandlerDataHandler {
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

extension NetworkJSONHandlerTestCase {
  private struct JSONSerializationTestDouble : NetworkJSONHandlerJSONSerialization {
    static var parameterData: Data?
    static var parameterOptions: JSONSerialization.ReadingOptions?
    static var returnJSON: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func jsonObject(
      with data: Data,
      options: JSONSerialization.ReadingOptions
    ) throws -> NSObject {
      self.parameterData = data
      self.parameterOptions = options
      guard
        let returnJSON = self.returnJSON
      else {
        throw self.returnError
      }
      return returnJSON
    }
  }
}

extension NetworkJSONHandlerTestCase {
  private typealias NetworkJSONHandlerTestDouble = NetworkJSONHandler<DataHandlerTestDouble, JSONSerializationTestDouble>
}

extension NetworkJSONHandlerTestCase {
  override func tearDown() {
    DataHandlerTestDouble.parameterData = nil
    DataHandlerTestDouble.parameterResponse = nil
    DataHandlerTestDouble.returnData = nil
    
    JSONSerializationTestDouble.parameterData = nil
    JSONSerializationTestDouble.parameterOptions = nil
    JSONSerializationTestDouble.returnJSON = nil
  }
}

extension NetworkJSONHandlerTestCase {
  func testMimeTypeError() {
    DataHandlerTestDouble.returnData = nil
    
    JSONSerializationTestDouble.returnJSON = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
    
    XCTAssertThrowsError(
      try NetworkJSONHandlerTestDouble.json(
        with: DataTestDouble(),
        response: response
      )
    ) { error in
      XCTAssertNil(DataHandlerTestDouble.parameterData)
      XCTAssertNil(DataHandlerTestDouble.parameterResponse)
      
      XCTAssertNil(JSONSerializationTestDouble.parameterData)
      XCTAssertNil(JSONSerializationTestDouble.parameterOptions)
      
      if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .mimeTypeError
        )
        XCTAssertNil(error.underlying)
      }
    }
  }
}

extension NetworkJSONHandlerTestCase {
  func testDataHandlerError() {
    DataHandlerTestDouble.returnData = nil
    
    JSONSerializationTestDouble.returnJSON = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
    
    XCTAssertThrowsError(
      try NetworkJSONHandlerTestDouble.json(
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
      
      XCTAssertNil(JSONSerializationTestDouble.parameterData)
      XCTAssertNil(JSONSerializationTestDouble.parameterOptions)
      
      if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
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

extension NetworkJSONHandlerTestCase {
  func testJSONSerializationError() {
    DataHandlerTestDouble.returnData = DataTestDouble()
    
    JSONSerializationTestDouble.returnJSON = nil
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
    
    XCTAssertThrowsError(
      try NetworkJSONHandlerTestDouble.json(
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
        JSONSerializationTestDouble.parameterData,
        DataHandlerTestDouble.returnData
      )
      XCTAssertEqual(
        JSONSerializationTestDouble.parameterOptions,
        []
      )
      
      if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .jsonSerializationError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            JSONSerializationTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkJSONHandlerTestCase {
  func testSuccess() {
    DataHandlerTestDouble.returnData = DataTestDouble()
    
    JSONSerializationTestDouble.returnJSON = NSObject()
    
    let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
    
    XCTAssertNoThrow(
      try {
        let json = try NetworkJSONHandlerTestDouble.json(
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
          JSONSerializationTestDouble.parameterData,
          DataHandlerTestDouble.returnData
        )
        XCTAssertEqual(
          JSONSerializationTestDouble.parameterOptions,
          []
        )
        
        XCTAssertIdentical(
          json,
          JSONSerializationTestDouble.returnJSON
        )
      }()
    )
  }
}
