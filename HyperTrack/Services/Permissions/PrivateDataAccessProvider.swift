import Foundation

// Following code copied from Apple Sample Project PrivacyPrompts

/// `PrivateDataAccessProvider` defines an interface for checking the current access level
/// and requesting access to a user's private data, and regardless of the data type.
typealias PrivateDataAccessProvider = PrivateDataAccessStatusProvider
  & PrivateDataAccessRequestProvider

/// `PrivateDataAccessStatusProvider` defines an interface for checking the current access level to a user's private data,
/// regardless of the data type.
protocol PrivateDataAccessStatusProvider {
  var accessLevel: PrivateDataAccessLevel { get }
}

/// `PrivateDataAccessRequestProvider` defines an interface for
///  requesting access to a user's private data, regardless of the data type.
protocol PrivateDataAccessRequestProvider {
  func requestAccess(
    completionHandler: @escaping (PrivateDataRequestAccessResult) -> Void
  )
}
