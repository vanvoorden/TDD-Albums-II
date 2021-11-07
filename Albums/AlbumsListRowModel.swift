//
//  AlbumsListRowModel.swift
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

protocol AlbumsListRowModelImageOperation {
  associatedtype Image
  
  static func image(for: URLRequest) async throws -> Image
}

extension NetworkImageOperation : AlbumsListRowModelImageOperation where Session == NetworkSession<Foundation.URLSession>, ImageHandler == NetworkImageHandler<NetworkDataHandler, NetworkImageSerialization<NetworkImageSource>> {
  
}

@MainActor final class AlbumsListRowModel<ImageOperation : AlbumsListRowModelImageOperation> : ObservableObject {
  @Published private(set) var image: ImageOperation.Image?
  
  private let album: Album
  
  init(album: Album) {
    self.album = album
  }
}

extension AlbumsListRowModel {
  var artist: String {
    return self.album.artist
  }
}

extension AlbumsListRowModel {
  var name: String {
    return self.album.name
  }
}

extension AlbumsListRowModel {
  func requestImage() async throws {
    if let url = URL(string: self.album.image) {
      let request = URLRequest(url: url)
      let image = try await ImageOperation.image(for: request)
      self.image = image
    }
  }
}
