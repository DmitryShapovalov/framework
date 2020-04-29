import Foundation

/// Log subsystems:
///
/// Interface
/// Auth
/// ErrorHandler
/// Service
///   Location
///   Health
///   Activity
/// Network
/// Pipeline
///   Initialization
///   Collection
///   Transmission
/// Notification
/// Dispatch
/// Store
///   Database
///   Defaults

let logger = logFor(subsystem: "com.hypertrack.sdk")

let logGeneral = logger("General")
let logAuth = logger("Auth")
let logInterface = logger("Interface")
let logNetwork = logger("Network")
let logSettings = logger("DeviceSettings")
let logRequest = logger("NetworkAPIRequest")
let logResponse = logger("NetworkAPIResponse")
let logDatabase = logger("DatabaseStorage")
let logFile = logger("FileStorage")
let logDefaults = logger("DefaultsStorage")
let logNotification = logger("ServiceNotification")
let logPipeline = logger("Pipeline")
let logInitialization = logger("PipelineInitialization")
let logCollection = logger("PipelineCollection")
let logTransmission = logger("PipelineTransmission")
let logTracking = logger("PipelineTracking")
let locationTrackingMode = logger("LocationTrackingMode")
let logActivity = logger("ServiceActivity")
let logDispatch = logger("Dispatch")
let logHealth = logger("ServiceHealth")
let logLocation = logger("ServiceLocation")
let logService = logger("Service")
let logLifecycle = logger("ServiceHealthLifecycle")
let logErrorHandler = logger("ErrorHandler")
let logTrackingState = logger("StateMachineTracking")

func prettyPrintResponse(_ response: Response) -> String {
  let responseData: String
  if let data = response.data {
    if let prettyData = prettyPrintJSONData(data) {
      responseData = prettyData
    } else { responseData = "Can't parse data to JSON" }
  } else { responseData = "No data" }

  return """

  Data
  \(responseData)

  Status code: \(response.statusCode)

  Response metadata:
  \(prettyPrintHTTPURLResponse(response.response))

  Error: \(prettyPrintSDKError(response.error))

  Result:
  \(response.result)

  """
}

func prettyPrintAbstractServiceData(_ serviceData: AbstractServiceData)
  -> String {
    return """

    Created: \(serviceData.getRecordedAt())
    Event ID: \(serviceData.getId())
    Event Type: \(serviceData.getType())
    Event Data:
    \(prettyPrintJSONData(Data(serviceData.getJSONdata().utf8)) ?? "Empty data")

    """
}

func prettyPrintSDKError(_ error: SDKError?) -> String {
  guard let error = error else { return prettyPrintedOptionalNone }

  return """

  Code: \(error.errorCode)
  Message: \(error.type.toString())

  """
}
