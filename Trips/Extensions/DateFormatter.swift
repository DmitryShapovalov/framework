import Foundation

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  static func convertStringDateToLocalTime(time: String) -> String {
    let calendar = Calendar.current
    guard let isoDate = DateFormatter.iso8601Full.date(from: time) else {
      return ""
    }
    let components = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: isoDate
    )
    guard let time = calendar.date(from: components) else { return "" }
    return time.toString()
  }

  static func stringToDate(stringDate: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter.date(from: stringDate)
  }
}

extension Date {
  func toString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    return formatter.string(from: self)
  }

  func dateToString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.string(from: self)
  }

  func timeToString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }

  static func combineDateWithTime(date: Date, time: Date) -> Date {
    let calendar = NSCalendar.current
    let dateComponents = calendar.dateComponents(
      [.year, .month, .day],
      from: date
    )
    let timeComponents = calendar.dateComponents(
      [.hour, .minute, .second],
      from: time
    )
    var mergedComponments = DateComponents()
    mergedComponments.year = dateComponents.year
    mergedComponments.month = dateComponents.month
    mergedComponments.day = dateComponents.day
    mergedComponments.hour = timeComponents.hour
    mergedComponments.minute = timeComponents.minute
    mergedComponments.second = timeComponents.second
    return calendar.date(from: mergedComponments) ?? Date()
  }
}
