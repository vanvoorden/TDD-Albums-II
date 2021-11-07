//
//  AlbumsListModel.swift
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

protocol AlbumsListModelJSONOperation {
  associatedtype JSON
  
  static func json(for: URLRequest) async throws -> JSON
}

extension NetworkJSONOperation : AlbumsListModelJSONOperation where Session == NetworkSession<Foundation.URLSession>, JSONHandler == NetworkJSONHandler<NetworkDataHandler, Foundation.JSONSerialization> {
  
}

struct Album {
  let id: String
  let artist: String
  let name: String
  let image: String
}

extension Album : Hashable {
  
}

extension Album : Identifiable {
  
}

@MainActor final class AlbumsListModel<JSONOperation : AlbumsListModelJSONOperation> : ObservableObject {
  @Published private(set) var albums = Array<Album>()
}

private func Albums(_ json: Any) -> Array<Album> {
  var albums = Array<Album>()
  if let array = ((json as? Dictionary<String, Any>)?["feed"] as? Dictionary<String, Any>)?["entry"] as? Array<Dictionary<String, Any>> {
    for dictionary in array {
      if let artist = ((dictionary["im:artist"] as? Dictionary<String, Any>)?["label"] as? String),
         let name = ((dictionary["im:name"] as? Dictionary<String, Any>)?["label"] as? String),
         let image = ((dictionary["im:image"] as? Array<Dictionary<String, Any>>)?[2]["label"] as? String),
         let id = (((dictionary["id"] as? Dictionary<String, Any>)?["attributes"] as? Dictionary<String, Any>)?["im:id"] as? String) {
        let album = Album(
          id: id,
          artist: artist,
          name: name,
          image: image
        )
        albums.append(album)
      }
    }
  }
  return albums
}

extension AlbumsListModel {
  func requestAlbums() async throws {
    if let url = URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=100/json") {
      let request = URLRequest(url: url)
      let json = try await JSONOperation.json(for: request)
      self.albums = Albums(json)
    }
  }
}
