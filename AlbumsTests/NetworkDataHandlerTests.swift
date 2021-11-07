//
//  NetworkDataHandlerTests.swift
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

final class NetworkDataHandlerTestCase : XCTestCase {
  
}

extension NetworkDataHandlerTestCase {
  func testError() {
    XCTAssertThrowsError(
      try NetworkDataHandler.data(
        with: DataTestDouble(),
        response: URLResponseTestDouble()
      )
    ) { error in
      if let error = try? XCTUnwrap(error as? NetworkDataHandler.Error) {
        XCTAssertEqual(
          error.code,
          .statusCodeError
        )
        XCTAssertNil(error.underlying)
      }
    }
  }
}

extension NetworkDataHandlerTestCase {
  private static var errorCodes: Array<Int> {
    return Array(100...199) + Array(300...599)
  }
}

extension NetworkDataHandlerTestCase {
  func testErrorWithStatusCode() {
    for statusCode in Self.errorCodes {
      XCTAssertThrowsError(
        try NetworkDataHandler.data(
          with: DataTestDouble(),
          response: HTTPURLResponseTestDouble(statusCode: statusCode)
        ),
        "Status Code \(statusCode)"
      ) { error in
        if let error = try? XCTUnwrap(
          error as? NetworkDataHandler.Error,
          "Status Code \(statusCode)"
        ) {
          XCTAssertEqual(
            error.code,
            .statusCodeError,
            "Status Code \(statusCode)"
          )
          XCTAssertNil(
            error.underlying,
            "Status Code \(statusCode)"
          )
        }
      }
    }
  }
}

extension NetworkDataHandlerTestCase {
  private static var successCodes: Array<Int> {
    return Array(200...299)
  }
}

extension NetworkDataHandlerTestCase {
  func testSuccess() {
    for statusCode in Self.successCodes {
      XCTAssertNoThrow(
        try {
          let data = try NetworkDataHandler.data(
            with: DataTestDouble(),
            response: HTTPURLResponseTestDouble(statusCode: statusCode)
          )
          XCTAssertEqual(
            data,
            DataTestDouble(),
            "Status Code \(statusCode)"
          )
        }(),
        "Status Code \(statusCode)"
      )
    }
  }
}
