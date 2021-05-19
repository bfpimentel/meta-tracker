// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command implicit_return
// swiftlint:disable sorted_imports
import CoreData
import Foundation

// swiftlint:disable attributes file_length vertical_whitespace_closing_braces
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - Item

internal class Item: NSManagedObject {
  internal class var entityName: String {
    return "Item"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext)
    -> NSEntityDescription?
  {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(
    *, deprecated, renamed: "makeFetchRequest",
    message:
      "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead."
  )
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<Item> {
    return NSFetchRequest<Item>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<Item> {
    return NSFetchRequest<Item>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var timestamp: Date?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// swiftlint:enable identifier_name line_length type_body_length
