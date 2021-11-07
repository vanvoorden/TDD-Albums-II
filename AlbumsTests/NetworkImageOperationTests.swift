//
//  NetworkImageOperationTests.swift
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

final class NetworkImageOperationTestCase: XCTestCase {
  private typealias NetworkImageOperationTestDouble = NetworkImageOperation<SessionTestDouble, ImageHandlerTestDouble>
}

extension NetworkImageOperationTestCase {
  private struct SessionTestDouble : NetworkImageOperationSession {
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

extension NetworkImageOperationTestCase {
  private struct ImageHandlerTestDouble : NetworkImageOperationImageHandler {
    static var parameterData: Data?
    static var parameterResponse: URLResponse?
    static var returnImage: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func image(
      with data: Data,
      response: URLResponse
    ) throws -> NSObject {
      self.parameterData = data
      self.parameterResponse = response
      guard
        let returnImage = self.returnImage
      else {
        throw self.returnError
      }
      return returnImage
    }
  }
}

extension NetworkImageOperationTestCase {
  override func tearDown() {
    SessionTestDouble.parameterRequest = nil
    SessionTestDouble.returnData = nil
    SessionTestDouble.returnResponse = nil
    
    ImageHandlerTestDouble.parameterData = nil
    ImageHandlerTestDouble.parameterResponse = nil
    ImageHandlerTestDouble.returnImage = nil
  }
}

extension NetworkImageOperationTestCase {
  func testSessionError() async {
    SessionTestDouble.returnData = nil
    SessionTestDouble.returnResponse = nil
    
    ImageHandlerTestDouble.returnImage = nil
    
    do {
      _ = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())
      XCTFail()
    } catch {
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertNil(ImageHandlerTestDouble.parameterData)
      XCTAssertNil(ImageHandlerTestDouble.parameterResponse)
      
      if let error = try? XCTUnwrap(error as? NetworkImageOperationTestDouble.Error) {
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

extension NetworkImageOperationTestCase {
  func testImageHandlerError() async {
    SessionTestDouble.returnData = DataTestDouble()
    SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
    
    ImageHandlerTestDouble.returnImage = nil
    
    do {
      _ = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())
      XCTFail()
    } catch {
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertEqual(
        ImageHandlerTestDouble.parameterData,
        SessionTestDouble.returnData
      )
      XCTAssertIdentical(
        ImageHandlerTestDouble.parameterResponse,
        SessionTestDouble.returnResponse
      )
      
      if let error = try? XCTUnwrap(error as? NetworkImageOperationTestDouble.Error) {
        XCTAssertEqual(
          error.code,
          .imageHandlerError
        )
        if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
          XCTAssertIdentical(
            underlying,
            ImageHandlerTestDouble.returnError
          )
        }
      }
    }
  }
}

extension NetworkImageOperationTestCase {
  func testSuccess() async {
    SessionTestDouble.returnData = DataTestDouble()
    SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
    
    ImageHandlerTestDouble.returnImage = NSObject()
    
    do {
      let image = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())
      
      XCTAssertEqual(
        SessionTestDouble.parameterRequest,
        URLRequestTestDouble()
      )
      
      XCTAssertEqual(
        ImageHandlerTestDouble.parameterData,
        SessionTestDouble.returnData
      )
      XCTAssertIdentical(
        ImageHandlerTestDouble.parameterResponse,
        SessionTestDouble.returnResponse
      )
      
      XCTAssertIdentical(
        image,
        ImageHandlerTestDouble.returnImage
      )
    } catch {
      XCTFail()
    }
  }
}
