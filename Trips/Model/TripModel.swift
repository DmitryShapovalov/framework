import CoreLocation
import UIKit

struct AWSGraphQLDataCreateTrip: Codable { let data: AWSCreateTrip }

struct AWSCreateTrip: Codable { let createTrip: TripModel }

struct AWSGraphQLData: Codable { let data: AWSMovementStatus }

struct AWSMovementStatus: Codable { let getMovementStatus: AWSTrips }

struct AWSTrips: Codable { let trips: [TripModel] }

struct TripModel: Codable {
  let trip_id: String?
  let device_id: String?
  let started_at: String?
  let destination: Destination?
  let estimate: Estimate?
  let views: Views?
  let metadata: String?
}

struct Views: Codable {
  let share_url: String
  let embed_url: String
}

struct Destination: Codable {
  let geometry: Geometry?
  let radius: Int?
  let scheduled_at: String?
}

struct Geometry: Codable {
  let type: String?
  let coordinates: [Double]?
}

struct Estimate: Codable {
  let arrive_at: String?
  let route: Route?
  let reroutes_exceeded: Bool?
}

struct Route: Codable {
  let distance: Int?
  let duration: Int?
  let start_address: String?
  let end_address: String?
  let polyline: LineStringGeometry?
}

struct LineStringGeometry: Codable {
  let type: String?
  let coordinates: [[Float]]?
}

func prepareForCreatingTrip(
  coord: CLLocationCoordinate2D,
  radius: Int,
  scheduled_at: String,
  metadata: String
) -> TripModel {
  let geometry = Geometry(
    type: "Point",
    coordinates: [coord.longitude, coord.latitude]
  )
  let destination = Destination(
    geometry: geometry,
    radius: radius,
    scheduled_at: scheduled_at
  )
  return TripModel(
    trip_id: nil,
    device_id: nil,
    started_at: nil,
    destination: destination,
    estimate: nil,
    views: nil,
    metadata: metadata
  )
}
