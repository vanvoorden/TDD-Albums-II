//
//  NetworkJSONHandler.swift
//  Albums
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

protocol NetworkJSONHandlerDataHandler {
  static func data(
    with: Data,
    response: URLResponse
  ) throws -> Data
}

extension NetworkDataHandler : NetworkJSONHandlerDataHandler {
  
}

protocol NetworkJSONHandlerJSONSerialization {
  associatedtype JSON
  
  static func jsonObject(
    with: Data,
    options: JSONSerialization.ReadingOptions
  ) throws -> JSON
}

extension JSONSerialization : NetworkJSONHandlerJSONSerialization {
  
}

struct NetworkJSONHandler<
  DataHandler : NetworkJSONHandlerDataHandler,
  JSONSerialization : NetworkJSONHandlerJSONSerialization
> {
  
}

extension NetworkJSONHandler {
  static func json(
    with data: Data,
    response: URLResponse
  ) throws -> JSONSerialization.JSON {
    guard
      let mimeType = response.mimeType?.lowercased(),
      mimeType == "text/javascript"
    else {
      throw Self.Error(.mimeTypeError)
    }
    
    let data = try { () -> Data in
      do {
        return try DataHandler.data(
          with: data,
          response: response
        )
      } catch {
        throw Self.Error(
          .dataHandlerError,
          underlying: error
        )
      }
    }()
    
    do {
      return try JSONSerialization.jsonObject(
        with: data,
        options: []
      )
    } catch {
      throw Self.Error(
        .jsonSerializationError,
        underlying: error
      )
    }
  }
}

extension NetworkJSONHandler {
  struct Error : Swift.Error {
    enum Code {
      case mimeTypeError
      case dataHandlerError
      case jsonSerializationError
    }
    
    let code: Self.Code
    let underlying: Swift.Error?
    
    init(
      _ code: Self.Code,
      underlying: Swift.Error? = nil
    ) {
      self.code = code
      self.underlying = underlying
    }
  }
}
