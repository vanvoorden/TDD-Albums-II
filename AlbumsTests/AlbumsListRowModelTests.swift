//
//  AlbumsListRowModelTests.swift
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

final class AlbumsListRowModelTestCase : XCTestCase {
  private typealias AlbumsListRowModelTestDouble = AlbumsListRowModel<ImageOperationTestDouble>
}

extension AlbumsListRowModelTestCase {
  private struct ImageOperationTestDouble : AlbumsListRowModelImageOperation {
    static var parameterRequest: URLRequest?
    static var returnImage: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func image(for request: URLRequest) async throws -> NSObject {
      self.parameterRequest = request
      guard
        let returnImage = self.returnImage
      else {
        throw self.returnError
      }
      return returnImage
    }
  }
}

extension AlbumsListRowModelTestCase {
  override func tearDown() {
    ImageOperationTestDouble.parameterRequest = nil
    ImageOperationTestDouble.returnImage = nil
  }
}

extension AlbumsListRowModelTestCase {
  private static var album: Album {
    return Album(
      id: "id",
      artist: "artist",
      name: "name",
      image: "image"
    )
  }
}

extension AlbumsListRowModelTestCase {
  @MainActor func testError() async {
    ImageOperationTestDouble.returnImage = nil
    
    let model = AlbumsListRowModelTestDouble(album: Self.album)
    
    XCTAssertEqual(
      model.artist,
      Self.album.artist
    )
    XCTAssertEqual(
      model.name,
      Self.album.name
    )
    
    do {
      try await model.requestImage()
      XCTFail()
    } catch {
      XCTAssertEqual(
        ImageOperationTestDouble.parameterRequest,
        URLRequest(url: URL(string: Self.album.image)!)
      )
      
      XCTAssertNil(model.image)
      
      if let error = try? XCTUnwrap(error as NSError?) {
        XCTAssertIdentical(
          error,
          ImageOperationTestDouble.returnError
        )
      }
    }
  }
}

extension AlbumsListRowModelTestCase {
  @MainActor func testSuccess() async {
    ImageOperationTestDouble.returnImage = NSObject()
    
    let model = AlbumsListRowModelTestDouble(album: Self.album)
    
    var modelDidChange = false
    let modelWillChange = model.objectWillChange.sink() { _ in
      modelDidChange = true
    }
    
    var imageDidChange = false
    let imageWillChange = model.$image.sink() { _ in
      if modelDidChange {
        imageDidChange = true
      }
    }
    
    XCTAssertEqual(
      model.artist,
      Self.album.artist
    )
    XCTAssertEqual(
      model.name,
      Self.album.name
    )
    
    do {
      try await model.requestImage()
      
      XCTAssertTrue(imageDidChange)
      
      XCTAssertEqual(
        ImageOperationTestDouble.parameterRequest,
        URLRequest(url: URL(string: Self.album.image)!)
      )
      
      XCTAssertIdentical(
        model.image,
        ImageOperationTestDouble.returnImage
      )
    } catch {
      XCTFail()
    }
    
    modelWillChange.cancel()
    imageWillChange.cancel()
  }
}
