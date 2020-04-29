import Foundation
import RxSwift

enum APIClientError: Error { case creationFailed }

protocol APIClientType {
  @discardableResult func createTrip(payload: TripModel) -> Observable<
    AWSGraphQLDataCreateTrip
  >
  func getUserTrips() -> Observable<AWSGraphQLData>
  func endTrip(payload: TripModel) -> Observable<TripModel>
}

struct APIClient: APIClientType {
  private let credential: Credential
  private let session: URLSession
  private let config: Configuration
  init(config: Configuration) {
    credential = config.credential
    self.config = config
    session = URLSession(configuration: URLSessionConfiguration.default)
  }

  func getUserTrips() -> Observable<AWSGraphQLData> {
    return send(
      apiRequest: APIRequest(endpoint: ApiRouter.getTrips(config, credential))
    ).map { $0 }
  }

  func createTrip(payload: TripModel) -> Observable<AWSGraphQLDataCreateTrip> {
    return send(
      apiRequest: APIRequest(
        endpoint: ApiRouter.createTrip(config, credential, payload)
      )
    ).map { $0 }
  }

  func endTrip(payload: TripModel) -> Observable<TripModel> {
    return send(
      apiRequest: APIRequest(
        endpoint: ApiRouter.endTrip(config, credential, payload)
      )
    ).map { $0 }
  }

  func cancelAllRequests() {
    session.getTasksWithCompletionHandler { data, _, _ in
      for task in data { task.cancel() }
    }
  }

  private func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
    return Observable.create { observer in
      let task = self.session.dataTask(with: apiRequest.getRequest()) {
        data,
          _,
          error in
        if let error = error {
          observer.onError(
            APIError(
              nil,
              "\(String(data: data ?? Data("Something went wrong".utf8), encoding: String.Encoding.utf8)!)\n\nError: \(error.localizedDescription)"
            )
          )
        } else {
          do {
            let model: T = try JSONDecoder().decode(
              T.self,
              from: data ?? Data()
            )
            observer.onNext(model)
          } catch {
            print(
              String(
                data: data ?? Data("Something went wrong".utf8),
                encoding: String.Encoding.utf8
              )!
            )
            print(error)
            observer.onError(
              APIError(
                nil,
                "\(String(data: data ?? Data("Something went wrong".utf8), encoding: String.Encoding.utf8)!)\n\nError: \(error.localizedDescription)"
              )
            )
          }
        }
        observer.onCompleted()
      }
      task.resume()
      return Disposables.create { task.cancel() }
    }
  }
}
