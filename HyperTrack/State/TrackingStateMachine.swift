enum TrackingStateMachine: Equatable {
  /// External events that can trigger state transitions
  enum Event: Equatable {
    /// Location received from LocationManager
    case locationReceived
    /// Activity change that can trigger mode change
    ///
    /// What to consider an activity change is placed on the state machine user.
    /// For example a change from walk to run can be considered a non-changing event.
    case activityChanged
    /// A special timer that limits the critical mode
    case criticalTimerFired
    /// A special timer that limits the activity mode batching
    case activityTimerFired
    /// A special timer that sends a ping to server, indicating that SDK is
    /// still alive, and OS doesn't consider that location was changed
    case heartbeatTimerFired
    /// A final event, used when disabling a state machine from any state
    case final
  }

  /// Actions that need to be executed
  enum Action: Equatable {
    /// Settings that can influence parameters like `distanceFiler`, designed
    /// to obtain the first location event as fast as possible
    case setStartSettings
    /// Settings that can influence parameters like `distanceFiler`, designed
    /// to confirm current activity to platform
    case setCriticalSettings
    /// Settings that can influence parameters like `distanceFiler` and activity
    /// timer, designed to batch activity events in packages best suited for
    /// current activity
    case setActivitySettings
    /// Send all location events received from LocationManager. Place those
    /// events in a buffer and send only when `sendLocations` action is present
    case sendLocations
    /// Send the last location received from LocationManager again
    case sendLastKnownLocation
    /// Start critical timer. Restart it if it's already running
    case startCriticalTimer
    /// Stop critical timer
    case stopCriticalTimer
    /// Start activity timer. Restart it if it's already running
    case startActivityTimer
    /// Stop activity timer
    case stopActivityTimer
    /// Start heartbeat timer. Restart it if it's already running
    case startHeartbeatTimer
    /// Stop heartbeat timer
    case stopHeartbeatTimer
  }

  case start
  case tracking(TrackingState)
  /// This is the state that state machine switches to when it's disabled
  ///
  /// Don't send any events when state machine is disabled. Create a new one
  /// with `initialState` if SDK should start tracking again
  case final

  enum TrackingState: Equatable {
    case critical(CriticalState)
    case activity(ActivityState)

    enum CriticalState: Equatable {
      case countdown(CountdownState)
      case standby

      enum CountdownState: Equatable {
        case noLocations
        case oneLocation
        case twoLocations
        case threeLocations
        case fourLocations
      }
    }

    enum ActivityState: Equatable {
      case noLocations
      case batchingLocations
      case standby
    }
  }

  /// Use this static function to initialize the state. Execute any actions
  /// immediately
  static let initialState: (
    state: TrackingStateMachine,
    actions: Set<Action>
  ) = (.start, [.setStartSettings])
  /// Use this function if you use the state machine as a `var`, mutating it
  /// in place
  mutating func handleEvent(_ event: Event) -> Set<Action> {
    let (state, actions) = TrackingStateMachine.handleEvent(
      event,
      forState: self
    )
    self = state
    return actions
  }

  /// Use this function if state machine is immutable, or is used in simulation
  static func handleEvent(
    _ event: Event,
    forState state: TrackingStateMachine
  ) -> (newState: TrackingStateMachine, actions: Set<Action>) {
    let newStateAndActions: (
      newState: TrackingStateMachine,
      actions: Set<Action>
    )
    switch (state, event) {
      case (.start, .locationReceived):
        newStateAndActions = (
          .tracking(.critical(.countdown(.noLocations))),
          [
            .setCriticalSettings,
            .sendLocations,
            .startCriticalTimer,
            .startHeartbeatTimer
          ]
        )
      case (.start, .final):
        newStateAndActions = (.final, [])
      case (.start, .activityChanged):
        // Nothing to do in this state, but safe to ignore as activity change is ortogonal
        newStateAndActions = (state, [])
      case (.tracking(.critical(.countdown(.noLocations))), .locationReceived):
        newStateAndActions = (
          .tracking(.critical(.countdown(.oneLocation))),
          [.sendLocations, .startHeartbeatTimer]
        )
      case (.tracking(.critical(_)), .activityChanged):
        newStateAndActions = (
          .tracking(.critical(.countdown(.noLocations))),
          [.startCriticalTimer]
        )
      case (
      .tracking(.critical(.countdown(.noLocations))),
        .criticalTimerFired
      ):
        newStateAndActions = (.tracking(.critical(.standby)), [])
      case (.tracking(.critical(_)), .heartbeatTimerFired),
           (.tracking(.activity(.noLocations)), .heartbeatTimerFired),
           (.tracking(.activity(.standby)), .heartbeatTimerFired):
        newStateAndActions = (
          state,
          [.sendLastKnownLocation, .startHeartbeatTimer]
        )
      case (.tracking(.critical(.countdown(_))), .final):
        newStateAndActions = (
          .final,
          [.sendLastKnownLocation, .stopCriticalTimer, .stopHeartbeatTimer]
        )
      case (.tracking(.critical(.countdown(.oneLocation))), .locationReceived):
        newStateAndActions = (
          .tracking(.critical(.countdown(.twoLocations))),
          [.sendLocations, .startHeartbeatTimer]
        )
      case (
      .tracking(.critical(.countdown(.oneLocation))),
        .criticalTimerFired
      ),
    (
      .tracking(.critical(.countdown(.twoLocations))),
      .criticalTimerFired
    ),
    (
      .tracking(.critical(.countdown(.threeLocations))),
      .criticalTimerFired
    ),
    (
      .tracking(.critical(.countdown(.fourLocations))),
      .criticalTimerFired
    ):
        newStateAndActions = (
          .tracking(.activity(.noLocations)),
          [.setActivitySettings, .startActivityTimer]
        )
      case (.tracking(.critical(.countdown(.twoLocations))), .locationReceived):
        newStateAndActions = (
          .tracking(.critical(.countdown(.threeLocations))),
          [.sendLocations, .startHeartbeatTimer]
        )
      case (
      .tracking(.critical(.countdown(.threeLocations))),
        .locationReceived
      ):
        newStateAndActions = (
          .tracking(.critical(.countdown(.fourLocations))),
          [.sendLocations, .startHeartbeatTimer]
        )
      case (
      .tracking(.critical(.countdown(.fourLocations))),
        .locationReceived
      ):
        newStateAndActions = (
          .tracking(.activity(.noLocations)),
          [
            .setActivitySettings,
            .sendLocations,
            .stopCriticalTimer,
            .startActivityTimer,
            .startHeartbeatTimer
          ]
        )
      case (.tracking(.critical(.standby)), .locationReceived):
        newStateAndActions = (
          .tracking(.activity(.noLocations)),
          [
            .setActivitySettings,
            .sendLocations,
            .startActivityTimer,
            .startHeartbeatTimer
          ]
        )
      case (.tracking(.critical(.standby)), .final),
           (.tracking(.activity(.standby)), .final):
        newStateAndActions = (
          .final,
          [.sendLastKnownLocation, .stopHeartbeatTimer]
        )
      case (.tracking(.activity(.noLocations)), .locationReceived),
           (.tracking(.activity(.batchingLocations)), .locationReceived):
        newStateAndActions = (
          .tracking(.activity(.batchingLocations)),
          [.startHeartbeatTimer]
        )
      case (.tracking(.activity(.noLocations)), .activityChanged):
        newStateAndActions = (
          .tracking(.critical(.countdown(.noLocations))),
          [.setCriticalSettings, .startCriticalTimer, .stopActivityTimer]
        )
      case (.tracking(.activity(.noLocations)), .activityTimerFired):
        newStateAndActions = (.tracking(.activity(.standby)), [])
      case (.tracking(.activity(.noLocations)), .final):
        newStateAndActions = (
          .final,
          [.sendLastKnownLocation, .stopActivityTimer, .stopHeartbeatTimer]
        )
      case (.tracking(.activity(.batchingLocations)), .activityChanged):
        newStateAndActions = (
          .tracking(.critical(.countdown(.noLocations))),
          [
            .setCriticalSettings,
            .sendLocations,
            .startCriticalTimer,
            .stopActivityTimer
          ]
        )
      case (.tracking(.activity(.batchingLocations)), .activityTimerFired):
        newStateAndActions = (
          .tracking(.activity(.noLocations)),
          [.sendLocations, .startActivityTimer]
        )
      case (.tracking(.activity(.batchingLocations)), .heartbeatTimerFired),
           (.tracking(.activity(.standby)), .locationReceived):
        newStateAndActions = (
          .tracking(.activity(.noLocations)),
          [.sendLocations, .startActivityTimer, .startHeartbeatTimer]
        )
      case (.tracking(.activity(.batchingLocations)), .final):
        newStateAndActions = (
          .final,
          [.sendLocations, .stopActivityTimer, .stopHeartbeatTimer]
        )
      case (.tracking(.activity(.standby)), .activityChanged):
        newStateAndActions = (
          .tracking(.critical(.countdown(.noLocations))),
          [.setCriticalSettings, .startCriticalTimer]
        )
      case (.start, _),
           (.final, _),
           (.tracking(.critical(_)), .activityTimerFired),
           (.tracking(.critical(.standby)), .criticalTimerFired),
           (.tracking(.activity(_)), .criticalTimerFired),
           (.tracking(.activity(.standby)), .activityTimerFired):
        /// This assert is designed to debug wrong integrations in development,
        /// but it won't fire in production, and will just silently ignore the
        /// event.
        assert(false, "Can't send \(event) event to \(state) state")
        newStateAndActions = (state, [])
    }

    if state == newStateAndActions.newState {
      if newStateAndActions.actions.isEmpty {
        logTrackingState
          .log("Handling event \(event), remaining in \(state) state with no actions")
      } else {
        logTrackingState
          .log("Handling event \(event), remaining in \(state) state with actions: \(newStateAndActions.actions)")
      }
    } else {
      if newStateAndActions.actions.isEmpty {
        logTrackingState
          .log("Handling event \(event), for \(state) state, transitioning to \(newStateAndActions.newState) with no actions")
      } else {
        logTrackingState
          .log("Handling event \(event), for \(state) state, transitioning to \(newStateAndActions.newState) with actions: \(newStateAndActions.actions)")
      }
    }

    return newStateAndActions
  }
}

extension TrackingStateMachine.Event: CustomStringConvertible {
  var description: String {
    switch self {
      case .locationReceived:
        return "Location Received"
      case .activityChanged:
        return "Activity Changed"
      case .criticalTimerFired:
        return "Critical Timer Fired"
      case .activityTimerFired:
        return "Activity Timer Fired"
      case .heartbeatTimerFired:
        return "Heartbeat Timer Fired"
      case .final:
        return "Final"
    }
  }
}

extension TrackingStateMachine.Action: CustomStringConvertible {
  var description: String {
    switch self {
      case .setStartSettings:
        return "Set Start Settings"
      case .setCriticalSettings:
        return "Set Critical Settings"
      case .setActivitySettings:
        return "Set Activity Settings"
      case .sendLocations:
        return "Send Locations"
      case .sendLastKnownLocation:
        return "Send Last Known Location"
      case .startCriticalTimer:
        return "Start Critical Timer"
      case .stopCriticalTimer:
        return "Stop Critical Timer"
      case .startActivityTimer:
        return "Start Activity Timer"
      case .stopActivityTimer:
        return "Stop Activity Timer"
      case .startHeartbeatTimer:
        return "Start Heartbeat Timer"
      case .stopHeartbeatTimer:
        return "Stop Heartbeat Timer"
    }
  }
}

extension TrackingStateMachine: CustomStringConvertible {
  var description: String {
    switch self {
      case .start:
        return "Start"
      case let .tracking(tracking):
        switch tracking {
          case let .critical(critical):
            switch critical {
              case let .countdown(countdown):
                switch countdown {
                  case .noLocations:
                    return "Countdown No Locations"
                  case .oneLocation:
                    return "One Location"
                  case .twoLocations:
                    return "Two Locations"
                  case .threeLocations:
                    return "Three Locations"
                  case .fourLocations:
                    return "Four Locations"
                }
              case .standby:
                return "Critical Standby"
            }
          case let .activity(activity):
            switch activity {
              case .noLocations:
                return "Activity No Locations"
              case .batchingLocations:
                return "Batching Locations"
              case .standby:
                return "Activity Standby"
            }
        }
      case .final:
        return "Final"
    }
  }
}
