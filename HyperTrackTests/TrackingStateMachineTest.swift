@testable import HyperTrack
import XCTest

class TrackingStateMachineTest: XCTestCase {
  func testInitialState() {
    let (state, actions) = TrackingStateMachine.initialState
    XCTAssertEqual(state, TrackingStateMachine.start)
    XCTAssertEqual(actions, [TrackingStateMachine.Action.setStartSettings])
  }

  func testFullStateRun() {
    let eventsAndActions: [
      (
        TrackingStateMachine.Event,
        Set<TrackingStateMachine.Action>
      )
    ]
    eventsAndActions = [
      /// Start -> Tracking.Critical.Countdown.NoLocations
      (
        .locationReceived,
        [
          .sendLocations,
          .startHeartbeatTimer,
          .setCriticalSettings,
          .startCriticalTimer
        ]
      ),
      /// Tracking.Critical.Countdown.NoLocations -> Tracking.Critical.Countdown.OneLocation
      (.locationReceived, [.sendLocations, .startHeartbeatTimer]),
      /// Tracking.Critical.Countdown.OneLocation -> Tracking.Critical.Countdown.TwoLocations
      (.locationReceived, [.sendLocations, .startHeartbeatTimer]),
      /// Tracking.Critical.Countdown.TwoLocations -> Tracking.Critical.Countdown.ThreeLocations
      (.locationReceived, [.sendLocations, .startHeartbeatTimer]),
      /// Tracking.Critical.Countdown.ThreeLocations -> Tracking.Critical.Countdown.FourLocations
      (.locationReceived, [.sendLocations, .startHeartbeatTimer]),
      /// Tracking.Critical.Countdown.FourLocations -> Tracking.Activity.NoLocations
      (
        .locationReceived,
        [
          .sendLocations,
          .startHeartbeatTimer,
          .stopCriticalTimer,
          .setActivitySettings,
          .startActivityTimer
        ]
      ),
      /// Tracking.Activity.NoLocations -> Tracking.Activity.BatchingLocations
      (.locationReceived, [.startHeartbeatTimer]),
      /// Tracking.Activity.BatchingLocations
      (.locationReceived, [.startHeartbeatTimer]),
      /// Tracking.Activity.BatchingLocations --> Tracking.Activity.NoLocations
      (.activityTimerFired, [.sendLocations, .startActivityTimer]),
      /// Tracking.Activity.NoLocations --> Tracking.Activity.Standby
      (.activityTimerFired, []),
      /// Tracking.Activity.Standby --> Tracking.Activity.NoLocations
      (
        .locationReceived,
        [.sendLocations, .startActivityTimer, .startHeartbeatTimer]
      ),
      /// Tracking.Activity.NoLocations -> Tracking.Activity.BatchingLocations
      (.locationReceived, [.startHeartbeatTimer]),
      /// Tracking.Activity.BatchingLocations -> Tracking.Critical.Countdown.NoLocations
      (
        .activityChanged,
        [
          .sendLocations,
          .stopActivityTimer,
          .setCriticalSettings,
          .startCriticalTimer
        ]
      ),
      /// Tracking.Critical.Countdown.NoLocations -> Tracking.Critical.Standby
      (.criticalTimerFired, []),
      /// Tracking.Critical.Standby
      (.heartbeatTimerFired, [.sendLastKnownLocation, .startHeartbeatTimer]),
      /// Tracking.Critical.Standby -> Tracking.Critical.Countdown.NoLocations
      (.activityChanged, [.startCriticalTimer]),
      /// Tracking.Critical.Countdown.NoLocations -> Tracking.Critical.Countdown.OneLocation
      (.locationReceived, [.sendLocations, .startHeartbeatTimer]),
      /// Tracking.Critical.Countdown.OneLocation -> Final
      (
        .final,
        [.stopCriticalTimer, .sendLastKnownLocation, .stopHeartbeatTimer]
      )
    ]

    _ = eventsAndActions
      .reduce(TrackingStateMachine.initialState
        .state) { currentState, eventAndActions in
        let (event, expectedActions) = eventAndActions
        let (nextState, resultingActions) = TrackingStateMachine.handleEvent(
          event,
          forState: currentState
        )
        XCTAssertEqual(expectedActions, resultingActions)
        return nextState
      }
  }

  func testPureAndMutatingHandlersParity() {
    let pureState = TrackingStateMachine.initialState.state
    var mutatingState = TrackingStateMachine.initialState.state
    XCTAssertEqual(pureState, mutatingState)

    let event: TrackingStateMachine.Event = .locationReceived

    let newPureState = TrackingStateMachine.handleEvent(
      event,
      forState: pureState
    ).newState
    _ = mutatingState.handleEvent(event)

    XCTAssertEqual(newPureState, mutatingState)
  }
}
