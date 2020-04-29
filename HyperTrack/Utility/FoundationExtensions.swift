import Foundation
import UIKit

extension UIDevice {
  static let fullModelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else {
        return identifier
      }
      return mapToDevice(
        identifier: identifier + String(UnicodeScalar(UInt8(value)))
      )
    }

    func mapToDevice(identifier: String) -> String {
      switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,11", "iPad6,12": return "iPad 5"
        case "iPad7,5", "iPad7,6": return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad7,1",
             "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
          return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
          return "iPad Pro (12.9-inch) (3rd generation)"
        case "i386", "x86_64":
          return
            "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
        default: return identifier
      }
    }
    return mapToDevice(identifier: identifier)
  }()
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

extension Double {
  /// Rounds the double to decimal places value
  func rounded(_ places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

extension JSONDecoder {
  static var hyperTrackDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
    return decoder
  }
}

extension JSONEncoder {
  static var hyperTrackEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
    return encoder
  }
}

extension TimeInterval {
  func toMilliseconds() -> Int { return Int(self * 1000) }
}

extension Date {
  static func - (lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeIntervalSinceReferenceDate
      - rhs.timeIntervalSinceReferenceDate
  }
}

extension Array where Element: Any {
  static func != (left: [Element], right: [Element]) -> Bool {
    return !(left == right)
  }

  static func == (left: [Element], right: [Element]) -> Bool {
    if left.count != right.count { return false }
    var right = right
    loop: for leftValue in left {
      for (rightIndex, rightValue) in right.enumerated()
        where isEqual(leftValue, rightValue) {
        right.remove(at: rightIndex)
        continue loop
      }
      return false
    }
    return true
  }
}

extension Dictionary where Value: Any {
  static func != (left: [Key: Value], right: [Key: Value]) -> Bool {
    return !(left == right)
  }

  static func == (left: [Key: Value], right: [Key: Value]) -> Bool {
    if left.count != right.count { return false }
    for element in left {
      guard let rightValue = right[element.key],
        isEqual(rightValue, element.value)
        else { return false }
    }
    return true
  }
}

func isEqual(_ left: Any, _ right: Any) -> Bool {
  if type(of: left) == type(of: right),
    String(describing: left) == String(describing: right)
  { return true }
  if let left = left as? [Any], let right = right as? [Any] {
    return left == right
  }
  if let left = left as? [AnyHashable: Any],
    let right = right as? [AnyHashable: Any]
  { return left == right }
  return false
}

struct AnyCodingKey: CodingKey {
  var stringValue: String
  var intValue: Int?

  init?(stringValue: String) { self.stringValue = stringValue }

  init?(intValue: Int) {
    self.intValue = intValue
    stringValue = String(intValue)
  }
}

extension KeyedDecodingContainer {
  /// Decodes a value of the given type for the given key.
  ///
  /// - parameter type: The type of value to decode.
  /// - parameter key: The key that the decoded value is associated with.
  /// - returns: A value of the requested type, if present for the given key
  ///   and convertible to the requested type.
  /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
  ///   is not convertible to the requested type.
  /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
  ///   for the given key.
  /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
  ///   the given key.
  func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key)
    throws -> [Any] {
    var values = try nestedUnkeyedContainer(forKey: key)
    return try values.decode(type)
  }

  /// Decodes a value of the given type for the given key.
  ///
  /// - parameter type: The type of value to decode.
  /// - parameter key: The key that the decoded value is associated with.
  /// - returns: A value of the requested type, if present for the given key
  ///   and convertible to the requested type.
  /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
  ///   is not convertible to the requested type.
  /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
  ///   for the given key.
  /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
  ///   the given key.
  func decode(
    _ type: [String: Any].Type,
    forKey key: KeyedDecodingContainer<K>.Key
  ) throws -> [String: Any] {
    let values = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
    return try values.decode(type)
  }

  /// Decodes a value of the given type for the given key, if present.
  ///
  /// This method returns `nil` if the container does not have a value
  /// associated with `key`, or if the value is null. The difference between
  /// these states can be distinguished with a `contains(_:)` call.
  ///
  /// - parameter type: The type of value to decode.
  /// - parameter key: The key that the decoded value is associated with.
  /// - returns: A decoded value of the requested type, or `nil` if the
  ///   `Decoder` does not have an entry associated with the given key, or if
  ///   the value is a null value.
  /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
  ///   is not convertible to the requested type.
  func decodeIfPresent(
    _ type: [Any].Type,
    forKey key: KeyedDecodingContainer<K>.Key
  ) throws -> [Any]? {
    guard contains(key), try decodeNil(forKey: key) == false else { return nil }
    return try decode(type, forKey: key)
  }

  /// Decodes a value of the given type for the given key, if present.
  ///
  /// This method returns `nil` if the container does not have a value
  /// associated with `key`, or if the value is null. The difference between
  /// these states can be distinguished with a `contains(_:)` call.
  ///
  /// - parameter type: The type of value to decode.
  /// - parameter key: The key that the decoded value is associated with.
  /// - returns: A decoded value of the requested type, or `nil` if the
  ///   `Decoder` does not have an entry associated with the given key, or if
  ///   the value is a null value.
  /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
  ///   is not convertible to the requested type.
  func decodeIfPresent(
    _ type: [String: Any].Type,
    forKey key: KeyedDecodingContainer<K>.Key
  ) throws -> [String: Any]? {
    guard contains(key), try decodeNil(forKey: key) == false else { return nil }
    return try decode(type, forKey: key)
  }
}

extension KeyedDecodingContainer {
  fileprivate func decode(_: [String: Any].Type) throws -> [String: Any] {
    var dictionary: [String: Any] = [:]
    for key in allKeys {
      if try decodeNil(forKey: key) {
        dictionary[key.stringValue] = NSNull()
      } else if let bool = try? decode(Bool.self, forKey: key) {
        dictionary[key.stringValue] = bool
      } else if let string = try? decode(String.self, forKey: key) {
        dictionary[key.stringValue] = string
      } else if let int = try? decode(Int.self, forKey: key) {
        dictionary[key.stringValue] = int
      } else if let double = try? decode(Double.self, forKey: key) {
        dictionary[key.stringValue] = double
      } else if let dict = try? decode([String: Any].self, forKey: key) {
        dictionary[key.stringValue] = dict
      } else if let array = try? decode([Any].self, forKey: key) {
        dictionary[key.stringValue] = array
      }
    }
    return dictionary
  }
}

extension UnkeyedDecodingContainer {
  fileprivate mutating func decode(_: [Any].Type) throws -> [Any] {
    var elements: [Any] = []
    while !isAtEnd {
      if try decodeNil() {
        elements.append(NSNull())
      } else if let int = try? decode(Int.self) {
        elements.append(int)
      } else if let bool = try? decode(Bool.self) {
        elements.append(bool)
      } else if let double = try? decode(Double.self) {
        elements.append(double)
      } else if let string = try? decode(String.self) {
        elements.append(string)
      } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
        let element = try? values.decode([String: Any].self) {
        elements.append(element)
      } else if var values = try? nestedUnkeyedContainer(),
        let element = try? values.decode([Any].self)
      { elements.append(element) }
    }
    return elements
  }
}

extension KeyedEncodingContainer {
  /// Encodes the given value for the given key.
  ///
  /// - parameter value: The value to encode.
  /// - parameter key: The key to associate the value with.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  mutating func encode(
    _ value: [String: Any],
    forKey key: KeyedEncodingContainer<K>.Key
  ) throws {
    var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
    try container.encode(value)
  }

  /// Encodes the given value for the given key.
  ///
  /// - parameter value: The value to encode.
  /// - parameter key: The key to associate the value with.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  mutating func encode(
    _ value: [Any],
    forKey key: KeyedEncodingContainer<K>.Key
  ) throws {
    var container = nestedUnkeyedContainer(forKey: key)
    try container.encode(value)
  }

  /// Encodes the given value for the given key if it is not `nil`.
  ///
  /// - parameter value: The value to encode.
  /// - parameter key: The key to associate the value with.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  mutating func encodeIfPresent(
    _ value: [String: Any]?,
    forKey key: KeyedEncodingContainer<K>.Key
  ) throws {
    if let value = value {
      var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
      try container.encode(value)
    } else { try encodeNil(forKey: key) }
  }

  /// Encodes the given value for the given key if it is not `nil`.
  ///
  /// - parameter value: The value to encode.
  /// - parameter key: The key to associate the value with.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  mutating func encodeIfPresent(
    _ value: [Any]?,
    forKey key: KeyedEncodingContainer<K>.Key
  ) throws {
    if let value = value {
      var container = nestedUnkeyedContainer(forKey: key)
      try container.encode(value)
    } else { try encodeNil(forKey: key) }
  }
}

extension KeyedEncodingContainer where K == AnyCodingKey {
  fileprivate mutating func encode(_ value: [String: Any]) throws {
    for (k, v) in value {
      let key = AnyCodingKey(stringValue: k)!
      switch v {
        case is NSNull: try encodeNil(forKey: key)
        case let string as String: try encode(string, forKey: key)
        case let int as Int: try encode(int, forKey: key)
        case let bool as Bool: try encode(bool, forKey: key)
        case let double as Double: try encode(double, forKey: key)
        case let dict as [String: Any]: try encode(dict, forKey: key)
        case let array as [Any]: try encode(array, forKey: key)
        default:
          debugPrint("Unsuported type!", v)
          continue
      }
    }
  }
}

extension UnkeyedEncodingContainer {
  /// Encodes the given value.
  ///
  /// - parameter value: The value to encode.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  fileprivate mutating func encode(_ value: [Any]) throws {
    for v in value {
      switch v {
        case is NSNull: try encodeNil()
        case let string as String: try encode(string)
        case let int as Int: try encode(int)
        case let bool as Bool: try encode(bool)
        case let double as Double: try encode(double)
        case let dict as [String: Any]: try encode(dict)
        case let array as [Any]:
          var values = nestedUnkeyedContainer()
          try values.encode(array)
        default: debugPrint("Unsuported type!", v)
      }
    }
  }

  /// Encodes the given value.
  ///
  /// - parameter value: The value to encode.
  /// - throws: `EncodingError.invalidValue` if the given value is invalid in
  ///   the current context for this format.
  fileprivate mutating func encode(_ value: [String: Any]) throws {
    var container = nestedContainer(keyedBy: AnyCodingKey.self)
    try container.encode(value)
  }
}
