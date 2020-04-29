import Foundation

final class GCDRepeatingTimer {
  var timeInterval: TimeInterval
  var repeating: Bool

  init(timeInterval: TimeInterval, repeating: Bool = true) {
    self.timeInterval = timeInterval
    self.repeating = repeating
  }

  private lazy var timer: DispatchSourceTimer = {
    let timerSource = DispatchSource.makeTimerSource()
    timerSource.schedule(
      deadline: self
        .repeating ? .now() :
        (DispatchTime.now() + DispatchTimeInterval
          .seconds(Int(self.timeInterval))),
      repeating: self.repeating ? self.timeInterval : .infinity
    )
    timerSource.setEventHandler(handler: { [weak self] in self?.eventHandler?()
    })
    return timerSource
  }()

  var eventHandler: (() -> Void)?

  enum State {
    case suspended
    case resumed
  }

  private(set) var state: State = .suspended

  deinit {
    timer.setEventHandler {}
    timer.cancel()
    // If the timer is suspended, calling cancel without resuming
    //         triggers a crash. This is documented here
    //         https://forums.developer.apple.com/thread/15902
    resume()
    eventHandler = nil
  }

  func resume() {
    if state == .resumed { return }
    state = .resumed
    timer.resume()
  }

  func suspend() {
    if state == .suspended { return }
    state = .suspended
    timer.suspend()
  }

  func reset(timeInterval: TimeInterval) {
    self.timeInterval = timeInterval
    timer.schedule(
      deadline: repeating ? .now() + self
        .timeInterval :
        (DispatchTime.now() + DispatchTimeInterval
          .seconds(Int(self.timeInterval))),
      repeating: repeating ? self.timeInterval : .infinity
    )
    resume()
  }
}
