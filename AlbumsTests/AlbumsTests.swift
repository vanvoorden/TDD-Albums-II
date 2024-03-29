//
//  AlbumsTests.swift
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

import Foundation

func DataTestDouble() -> Data {
  return Data(UInt8.min...UInt8.max)
}

func HTTPURLResponseTestDouble(
  statusCode: Int = 200,
  headerFields: Dictionary<String, String>? = nil
) -> HTTPURLResponse {
  return HTTPURLResponse(
    url: URLTestDouble(),
    statusCode: statusCode,
    httpVersion: "HTTP/1.1",
    headerFields: headerFields
  )!
}

func NSErrorTestDouble() -> NSError {
  return NSError(
    domain: "",
    code: 0
  )
}

func URLRequestTestDouble() -> URLRequest {
  return URLRequest(url: URLTestDouble())
}

func URLResponseTestDouble() -> URLResponse {
  return URLResponse(
    url: URLTestDouble(),
    mimeType: nil,
    expectedContentLength: 0,
    textEncodingName: nil
  )
}

func URLTestDouble() -> URL {
  return URL(string: "http://localhost/")!
}
