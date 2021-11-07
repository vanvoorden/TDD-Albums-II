//
//  NetworkImageSerialization.swift
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

protocol NetworkImageSerializationImageSource {
  associatedtype ImageSource
  associatedtype Image
  
  static func createImageSource(
    with: CFData,
    options: CFDictionary?
  ) -> ImageSource?
  
  static func createImage(
    with: ImageSource,
    at: Int,
    options: CFDictionary?
  ) -> Image?
}

extension NetworkImageSource : NetworkImageSerializationImageSource {

}

struct NetworkImageSerialization<ImageSource : NetworkImageSerializationImageSource> {
  static func image(with data: Data) throws -> ImageSource.Image {
    guard
      let imageSource = ImageSource.createImageSource(
        with: data as CFData,
        options: nil
      )
    else {
      throw Self.Error(.imageSourceError)
    }
    guard
      let image = ImageSource.createImage(
        with: imageSource,
        at: 0,
        options: nil
      )
    else {
      throw Self.Error(.imageError)
    }
    return image
  }
}

extension NetworkImageSerialization {
  struct Error : Swift.Error {
    enum Code {
      case imageSourceError
      case imageError
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
