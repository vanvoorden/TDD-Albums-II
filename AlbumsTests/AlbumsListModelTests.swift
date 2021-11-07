//
//  AlbumsListModelTests.swift
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

final class AlbumsListModelTestCase : XCTestCase {
  private typealias AlbumsListModelTestDouble = AlbumsListModel<JSONOperationTestDouble>
}

extension AlbumsListModelTestCase {
  private struct JSONOperationTestDouble : AlbumsListModelJSONOperation {
    static var parameterRequest: URLRequest?
    static var returnJSON: Any?
    static let returnError = NSErrorTestDouble()
    
    static func json(for request: URLRequest) async throws -> Any {
      self.parameterRequest = request
      guard
        let returnJSON = self.returnJSON
      else {
        throw self.returnError
      }
      return returnJSON
    }
  }
}

extension AlbumsListModelTestCase {
  override func tearDown() {
    JSONOperationTestDouble.parameterRequest = nil
    JSONOperationTestDouble.returnJSON = nil
  }
}

extension AlbumsListModelTestCase {
  private static var request: URLRequest {
    return URLRequest(url: URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=100/json")!)
  }
}

extension AlbumsListModelTestCase {
  private static var json: Any {
    let bundle = Bundle(identifier: "com.northbronson.AlbumsTests")!
    let url = bundle.url(
      forResource: "Albums",
      withExtension: "json"
    )!
    let data = try! Data(contentsOf: url)
    let json = try! JSONSerialization.jsonObject(
      with: data,
      options: []
    )
    return json
  }
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

extension AlbumsListModelTestCase {
  private static var albums: Array<Album> {
    return Albums(self.json)
  }
}

extension AlbumsListModelTestCase {
  @MainActor func testError() async {
    JSONOperationTestDouble.returnJSON = nil
    
    let model = AlbumsListModelTestDouble()
    do {
      try await model.requestAlbums()
      XCTFail()
    } catch {
      XCTAssertEqual(
        JSONOperationTestDouble.parameterRequest,
        Self.request
      )
      
      XCTAssertEqual(
        model.albums,
        []
      )
      
      if let error = try? XCTUnwrap(error as NSError?) {
        XCTAssertIdentical(
          error,
          JSONOperationTestDouble.returnError
        )
      }
    }
  }
}

extension AlbumsListModelTestCase {
  @MainActor func testSuccess() async {
    JSONOperationTestDouble.returnJSON = Self.json
    
    let model = AlbumsListModelTestDouble()
    
    var modelDidChange = false
    let modelWillChange = model.objectWillChange.sink() { _ in
      modelDidChange = true
    }
    
    var albumsDidChange = false
    let albumsWillChange = model.$albums.sink() { _ in
      if modelDidChange {
        albumsDidChange = true
      }
    }
    
    do {
      try await model.requestAlbums()
      
      XCTAssertTrue(albumsDidChange)
      
      XCTAssertEqual(
        JSONOperationTestDouble.parameterRequest,
        Self.request
      )
      
      XCTAssertEqual(
        model.albums,
        Self.albums
      )
    } catch {
      XCTFail()
    }
    
    modelWillChange.cancel()
    albumsWillChange.cancel()
  }
}
