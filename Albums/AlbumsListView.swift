//
//  AlbumsListView.swift
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

import SwiftUI

@MainActor protocol AlbumsListViewModel : ObservableObject {
  var albums: Array<Album> { get }
  
  func requestAlbums() async throws
}

extension AlbumsListModel : AlbumsListViewModel where JSONOperation == NetworkJSONOperation<NetworkSession<Foundation.URLSession>, NetworkJSONHandler<NetworkDataHandler, Foundation.JSONSerialization>> {
  
}

struct AlbumsListView<ListViewModel : AlbumsListViewModel, ListRowViewModel : AlbumsListRowViewModel> : View {
  @ObservedObject private var model: ListViewModel
  
  init(model: ListViewModel) {
    self.model = model
  }
}

extension AlbumsListView {
  var body: some View {
    List(
      self.model.albums
    ) { album in
      AlbumsListRowView<ListRowViewModel>(
        model: ListRowViewModel(album: album)
      )
    }.listStyle(
      .plain
    ).task {
      do {
        try await self.model.requestAlbums()
      } catch {
        print(error)
      }
    }
  }
}

struct AlbumsListView_Previews: PreviewProvider {
  
}

extension AlbumsListView_Previews {
  private final class ListModel : AlbumsListViewModel {
    @Published private(set) var albums = Array<Album>()
    
    func requestAlbums() async throws {
      self.albums = [
        Album(
          id: "Rubber Soul",
          artist: "Beatles",
          name: "Rubber Soul",
          image: "http://localhost/rubber-soul.jpeg"
        ),
        Album(
          id: "Pet Sounds",
          artist: "Beach Boys",
          name: "Pet Sounds",
          image: "http://localhost/pet-sounds.jpeg"
        ),
      ]
    }
  }
}

extension AlbumsListView_Previews {
  private final class ListRowModel : AlbumsListRowViewModel {
    let artist: String
    let name: String
    
    @Published private(set) var image: CGImage?
    
    init(album: Album) {
      self.artist = album.artist
      self.name = album.name
    }
    
    func requestImage() async throws {
      if let context = CGContext(
        data: nil,
        width: 256,
        height: 256,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      ) {
        context.setFillColor(
          red: 0.5,
          green: 0.5,
          blue: 0.5,
          alpha: 1
        )
        context.fill(
          CGRect(
            x: 0,
            y: 0,
            width: 256,
            height: 256
          )
        )
        self.image = context.makeImage()
      }
    }
  }
}

extension AlbumsListView_Previews {
  static var previews: some View {
    AlbumsListView<ListModel, ListRowModel>(
      model: ListModel()
    )
  }
}
