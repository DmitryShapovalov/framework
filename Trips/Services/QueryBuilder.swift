import Foundation

class QueryBuilder {
  static func buildGraphQLCreateTripQuery(
    model: TripModel,
    credential: Credential
  ) -> [String: Any?] {
    let coordinateLat = "\(model.destination?.geometry?.coordinates?[0] ?? 0.0)"
    let coordinateLng = "\(model.destination?.geometry?.coordinates?[1] ?? 0.0)"
    let radius = "\(model.destination!.radius ?? 30)"
    let scheduled_at = "\(model.destination!.scheduled_at ?? "")"
    let metadata = model.metadata ?? ""
    var query = [
      "query":
        "mutation createTrip($device_id: String, $publishable_key: String, $destination: DestinationInput){createTrip(device_id: $device_id, publishable_key: $publishable_key, destination: $destination){device_id}}"
    ] as [String: Any]
    var variables = [
      "device_id": credential.device_id, "publishable_key": credential.pk_key,
      "destination": [
        "geometry": [
          "type": "Point", "coordinates": [coordinateLat, coordinateLng]
        ], "radius": radius, "scheduled_at": scheduled_at
      ]
    ] as [String: Any]
    if !metadata.isEmpty {
      variables["metadata"] = metadata
      if var value = query["query"] as? String {
        value.insert(
          contentsOf: ", metadata: $metadata",
          at: value.index(value.endIndex, offsetBy: -13)
        )
        value.insert(
          contentsOf: ", $metadata: AWSJSON",
          at: value.index(value.startIndex, offsetBy: 96)
        )
        query["query"] = value
      }
    }
    query["variables"] = variables
    return query
  }

  static func buildGraphQLGetTripQuery(credential: Credential) -> [
    String: Any?
  ] {
    var query = [
      "query":
        "query Trips($device_id:String $publishable_key:String){getMovementStatus(device_id:$device_id,publishable_key:$publishable_key){trips{trip_id started_at views{share_url embed_url}destination{geometry{type coordinates}radius scheduled_at arrived_at exited_at}estimate{arrive_at route{distance duration remaining_duration start_address end_address polyline{type coordinates}}reroutes_exceeded}metadata}}}"
    ] as [String: Any]
    let variables = [
      "device_id": credential.device_id, "publishable_key": credential.pk_key
    ]
    query["variables"] = variables
    return query
  }
}
