import Foundation

protocol ErrorProtocol: LocalizedError {
  var title: String? { get }
  var errorDescription: String? { get }
}

struct APIError: ErrorProtocol {
  private var description: String
  var title: String?
  var errorDescription: String? { return description }
  init(_ title: String?, _ description: String) {
    self.title = title ?? "Error"
    self.description = description
  }
}
