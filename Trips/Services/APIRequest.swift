import Foundation

struct APIRequest {
  private let endpoint: APIEndpoint
  private var urlRequest: URLRequest
  init(endpoint: APIEndpoint) {
    self.endpoint = endpoint
    urlRequest = URLRequest(url: endpoint.url)
    urlRequest.httpMethod = endpoint.method.rawValue
    urlRequest.httpBody = endpoint.body
    for (header, value) in endpoint.headers {
      urlRequest.setValue(value, forHTTPHeaderField: header)
    }
    print("url - \(endpoint.url)")
  }
}

extension APIRequest { func getRequest() -> URLRequest { return urlRequest } }
