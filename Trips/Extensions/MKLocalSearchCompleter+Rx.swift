import MapKit
import RxCocoa
import RxSwift

extension Reactive where Base: MKLocalSearchCompleter {
  public var delegate:
    DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate>
  { return RxMKLocalSearchCompleterDelegateProxy.proxy(for: base) }
  public var didUpdateResults: ControlEvent<MKLocalSearchCompleter> {
    let source = delegate.methodInvoked(
      #selector(MKLocalSearchCompleterDelegate.completerDidUpdateResults(_:))
    ).map { a in try castOrThrow(MKLocalSearchCompleter.self, a[0]) }
    return ControlEvent(events: source)
  }

  public var didFailWithError: ControlEvent<Error> {
    let source = delegate.methodInvoked(
      #selector(MKLocalSearchCompleterDelegate.completer(_:didFailWithError:))
    ).map { a in try castOrThrow(Error.self, a[1]) }
    return ControlEvent(events: source)
  }

  public var queryFragment: Binder<String> {
    return Binder(base) { localSearchCompleter, query in
      localSearchCompleter.queryFragment = query
    }
  }
}

extension MKLocalSearchCompleter: HasDelegate {
  public typealias Delegate = MKLocalSearchCompleterDelegate
}

class RxMKLocalSearchCompleterDelegateProxy: DelegateProxy<
  MKLocalSearchCompleter, MKLocalSearchCompleterDelegate
>, DelegateProxyType, MKLocalSearchCompleterDelegate {
  public private(set) weak var localSearchCompleter: MKLocalSearchCompleter?
  public init(localSearchCompleter: ParentObject) {
    self.localSearchCompleter = localSearchCompleter
    super.init(
      parentObject: localSearchCompleter,
      delegateProxy: RxMKLocalSearchCompleterDelegateProxy.self
    )
  }

  static func registerKnownImplementations() {
    register { RxMKLocalSearchCompleterDelegateProxy(localSearchCompleter: $0) }
  }
}

extension MKLocalSearch {
  static func getSearch(search: MKLocalSearchCompletion) -> MKLocalSearch {
    let searchRequest = Request(completion: search)
    return MKLocalSearch(request: searchRequest)
  }
}
