//
//  NetworkJSONOperationTests.swift
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

final class NetworkJSONOperationTestCase : XCTestCase {
  private typealias NetworkJSONOperationTestDouble = NetworkJSONOperation<SessionTestDouble, JSONHandlerTestDouble>
}

extension NetworkJSONOperationTestCase {
  private struct SessionTestDouble : NetworkJSONOperationSession {
    static var parameterRequest: URLRequest?
    static var returnData: Data?
    static var returnResponse: URLResponse?
    static let returnError = NSErrorTestDouble()
    
    static func data(for request: URLRequest) async throws -> (
      Data,
      URLResponse
    ) {
      self.parameterRequest = request
      guard
        let returnData = self.returnData,
        let returnResponse = self.returnResponse
      else {
        throw self.returnError
      }
      return (
        returnData,
        returnResponse
      )
    }
  }
}

extension NetworkJSONOperationTestCase {
  private struct JSONHandlerTestDouble : NetworkJSONOperationJSONHandler {
    static var parameterData: Data?
    static var parameterResponse: URLResponse?
    static var returnJSON: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func json(
      with data: Data,
      response: URLResponse
    ) throws -> NSObject {
      self.parameterData = data
      self.parameterResponse = response
      guard
        let returnJSON = self.returnJSON
      else {
        throw self.returnError
      }
      return returnJSON
    }
  }
}

extension NetworkJSONOperationTestCase {
  override func tearDown() {
    SessionTestDouble.parameterRequest = nil
    SessionTestDouble.returnData = nil
    SessionTestDouble.returnResponse = nil
    
    JSONHandlerTestDouble.parameterData = nil
    JSONHandlerTestDouble.parameterResponse = nil
    JSONHandlerTestDouble.returnJSON = nil
  }
}

extension NetworkJSONOperationTestCase {
  func testSessionError() async {
    SessionTestDouble.returnData = nil
    SessionTestDouble.returnResponse = nil
    
    JSONHandlerTestDouble.returnJSON = nil
    
    do {
      _ = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
      XCTFail()
    } catch {
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertNil(JSONHandlerTestDouble.parameterData)
      XCTAssertNil(JSONHandlerTestDouble.parameterResponse)
      
      if let error = try? XCTUnwrap(error as? NetworkJSONOperationTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .sessionError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            SessionTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkJSONOperationTestCase {
  func testJSONHandlerError() async {
    SessionTestDouble.returnData = DataTestDouble()
    SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
    
    JSONHandlerTestDouble.returnJSON = nil
    
    do {
      _ = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
      XCTFail()
    } catch {
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertEqual(
        JSONHandlerTestDouble.parameterData,
        SessionTestDouble.returnData
      )
      XCTAssertIdentical(
        JSONHandlerTestDouble.parameterResponse,
        SessionTestDouble.returnResponse
      )
      
      if let error = try? XCTUnwrap(error as? NetworkJSONOperationTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .jsonHandlerError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            JSONHandlerTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkJSONOperationTestCase {
  func testSuccess() async {
    SessionTestDouble.returnData = DataTestDouble()
    SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
    
    JSONHandlerTestDouble.returnJSON = NSObject()
    
    do {
      let json = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
      
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertEqual(
        JSONHandlerTestDouble.parameterData,
        SessionTestDouble.returnData
      )
      XCTAssertIdentical(
        JSONHandlerTestDouble.parameterResponse,
        SessionTestDouble.returnResponse
      )
      
      XCTAssertIdentical(
        json,
        JSONHandlerTestDouble.returnJSON
      )
    } catch {
      XCTFail()
    }
  }
}
