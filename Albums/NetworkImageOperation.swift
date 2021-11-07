//
//  NetworkImageOperation.swift
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

protocol NetworkImageOperationSession {
  static func data(for: URLRequest) async throws -> (
    Data,
    URLResponse
  )
}

extension NetworkSession : NetworkImageOperationSession where URLSession == Foundation.URLSession {
  
}

protocol NetworkImageOperationImageHandler {
  associatedtype Image
  
  static func image(
    with: Data,
    response: URLResponse
  ) throws -> Image
}

extension NetworkImageHandler : NetworkImageOperationImageHandler where DataHandler == NetworkDataHandler, ImageSerialization == NetworkImageSerialization<NetworkImageSource> {
  
}

struct NetworkImageOperation<
  Session : NetworkImageOperationSession,
  ImageHandler : NetworkImageOperationImageHandler
> {
  
}

extension NetworkImageOperation {
  static func image(for request: URLRequest) async throws -> ImageHandler.Image {
    let (
      data,
      response
    ) = try await { () -> (
      Data,
      URLResponse
    ) in
      do {
        return try await Session.data(for: request)
      } catch {
        throw Self.Error(
          .sessionError,
          underlying: error
        )
      }
    }()
    
    do {
      return try ImageHandler.image(
        with: data,
        response: response
      )
    } catch {
      throw Self.Error(
        .imageHandlerError,
        underlying: error
      )
    }
  }
}

extension NetworkImageOperation {
  struct Error : Swift.Error {
    enum Code {
      case sessionError
      case imageHandlerError
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
