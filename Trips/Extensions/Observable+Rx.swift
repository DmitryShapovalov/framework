import Foundation
import RxCocoa
import RxSwift
import UIKit

protocol OptionalType {
  associatedtype Wrapped
  var asOptional: Wrapped? { get }
}

/// Implementation of the OptionalType protocol by the Optional type
extension Optional: OptionalType { var asOptional: Wrapped? { return self } }

extension Observable where Element: OptionalType {
  func unwrappedOptional() -> Observable<Element.Wrapped> {
    return filter { $0.asOptional != nil }.map { $0.asOptional! }
  }
}
