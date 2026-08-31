import CoreData
import Foundation

final class CoreDataStack {
    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(name: String = "VibeFinderMobile", inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(
            name: name,
            managedObjectModel: Self.makeManagedObjectModel()
        )

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        if !inMemory {
            storeDescription.url = NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("\(name).sqlite")
        }
        persistentContainer.persistentStoreDescriptions = [storeDescription]

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load CoreData store: \(error.localizedDescription)")
            }
        }

        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeSearchSuggestionEntity()
        ]
        return model
    }

    private static func makeSearchSuggestionEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "SearchSuggestionEntity"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            makeAttribute(name: "id", type: .stringAttributeType, isOptional: false),
            makeAttribute(name: "kind", type: .stringAttributeType, isOptional: false),
            makeAttribute(name: "title", type: .stringAttributeType, isOptional: true),
            makeAttribute(name: "order", type: .integer64AttributeType, isOptional: false)
        ]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }

    private static func makeAttribute(
        name: String,
        type: NSAttributeType,
        isOptional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        return attribute
    }
}
