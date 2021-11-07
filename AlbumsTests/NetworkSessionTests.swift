//
//  NetworkSessionTests.swift
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

final class NetworkSessionTestCase : XCTestCase {
  private typealias NetworkSessionTestDouble = NetworkSession<URLSessionTestDouble>
}

extension NetworkSessionTestCase {
  final private class URLSessionTestDouble : NetworkSessionURLSession {
    static let shared = URLSessionTestDouble()
    
    var parameterRequest: URLRequest?
    var parameterDelegate: URLSessionTaskDelegate?
    var returnData: Data?
    var returnResponse: URLResponse?
    let returnError = NSErrorTestDouble()
    
    func data(
      for request: URLRequest,
      delegate: URLSessionTaskDelegate?
    ) async throws -> (
      Data,
      URLResponse
    ) {
      self.parameterRequest = request
      self.parameterDelegate = delegate
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

extension NetworkSessionTestCase {
  override func tearDown() {
    URLSessionTestDouble.shared.parameterRequest = nil
    URLSessionTestDouble.shared.parameterDelegate = nil
    URLSessionTestDouble.shared.returnData = nil
    URLSessionTestDouble.shared.returnResponse = nil
  }
}

extension NetworkSessionTestCase {
  func testError() async {
    URLSessionTestDouble.shared.returnData = nil
    URLSessionTestDouble.shared.returnResponse = nil
    
    do {
      _ = try await NetworkSessionTestDouble.data(for: URLRequestTestDouble())
      XCTFail()
    } catch {
      XCTAssertEqual(
        URLSessionTestDouble.shared.parameterRequest,
        URLRequestTestDouble()
      )
      XCTAssertNil(URLSessionTestDouble.shared.parameterDelegate)
      
      if let error = try? XCTUnwrap(error as NSError?) {
        XCTAssertIdentical(
          error,
          URLSessionTestDouble.shared.returnError
        )
      }
    }
  }
}

extension NetworkSessionTestCase {
  func testSuccess() async {
    URLSessionTestDouble.shared.returnData = DataTestDouble()
    URLSessionTestDouble.shared.returnResponse = URLResponseTestDouble()
    
    do {
      let (
        data,
        response
      ) = try await NetworkSessionTestDouble.data(for: URLRequestTestDouble())
      
      XCTAssertEqual(
        URLSessionTestDouble.shared.parameterRequest,
        URLRequestTestDouble()
      )
      XCTAssertNil(URLSessionTestDouble.shared.parameterDelegate)
      
      XCTAssertEqual(
        data,
        URLSessionTestDouble.shared.returnData
      )
      XCTAssertIdentical(
        response,
        URLSessionTestDouble.shared.returnResponse
      )
    } catch {
      XCTFail()
    }
  }
}
