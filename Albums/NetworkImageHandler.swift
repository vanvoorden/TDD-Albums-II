//
//  NetworkImageHandler.swift
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

protocol NetworkImageHandlerDataHandler {
  static func data(
    with: Data,
    response: URLResponse
  ) throws -> Data
}

extension NetworkDataHandler : NetworkImageHandlerDataHandler {
  
}

protocol NetworkImageHandlerImageSerialization {
  associatedtype Image
  
  static func image(with: Data) throws -> Image
}

extension NetworkImageSerialization : NetworkImageHandlerImageSerialization where ImageSource == NetworkImageSource {
  
}

struct NetworkImageHandler<
  DataHandler : NetworkImageHandlerDataHandler,
  ImageSerialization : NetworkImageHandlerImageSerialization
> {
  
}

extension NetworkImageHandler {
  static func image(
    with data: Data,
    response: URLResponse
  ) throws -> ImageSerialization.Image {
    guard
      let mimeType = response.mimeType?.lowercased(),
      mimeType == "image/png"
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
      return try ImageSerialization.image(with: data)
    } catch {
      throw Self.Error(
        .imageSerializationError,
        underlying: error
      )
    }
  }
}

extension NetworkImageHandler {
  struct Error : Swift.Error {
    enum Code {
      case mimeTypeError
      case dataHandlerError
      case imageSerializationError
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

