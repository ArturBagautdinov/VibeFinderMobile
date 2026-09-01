import CoreData
import Foundation

final class CoreDataSearchSuggestionsStore: SearchSuggestionsStoreProtocol {
    private enum Field {
        static let id = "id"
        static let kind = "kind"
        static let title = "title"
        static let order = "order"
    }

    private enum Entity {
        static let searchSuggestion = "SearchSuggestionEntity"
    }

    private enum SeedMarker {
        static let id = "__search_suggestions_seeded__"
        static let kind = "seedMarker"
        static let order = Int64.max
    }

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func loadSuggestions() -> [SearchSuggestion] {
        let context = coreDataStack.viewContext
        ensureSeeded(in: context)

        do {
            return try fetchSuggestionObjects(in: context).compactMap(makeSuggestion)
        } catch {
            assertionFailure("Failed to load search suggestions: \(error.localizedDescription)")
            return SearchSuggestion.defaults
        }
    }

    func saveSuggestions(_ suggestions: [SearchSuggestion]) {
        let context = coreDataStack.viewContext

        do {
            try fetchSuggestionObjects(in: context)
                .filter { ($0.value(forKey: Field.id) as? String) != SeedMarker.id }
                .forEach(context.delete)
            suggestions.enumerated().forEach { index, suggestion in
                insert(suggestion, order: index, in: context)
            }
            ensureSeedMarker(in: context)
            try saveIfNeeded(context)
        } catch {
            assertionFailure("Failed to save search suggestions: \(error.localizedDescription)")
        }
    }

    func restoreDefaultSuggestions() -> [SearchSuggestion] {
        let currentSuggestions = loadSuggestions()
        let currentIDs = Set(currentSuggestions.map(\.id))
        let missingDefaultSuggestions = SearchSuggestion.defaults.filter {
            !currentIDs.contains($0.id)
        }
        let suggestions = currentSuggestions + missingDefaultSuggestions
        saveSuggestions(suggestions)
        return suggestions
    }

    private func ensureSeeded(in context: NSManagedObjectContext) {
        do {
            let existingObjects = try fetchSuggestionObjects(in: context)
            let isSeeded = existingObjects.contains {
                ($0.value(forKey: Field.id) as? String) == SeedMarker.id
            }
            guard !isSeeded else {
                return
            }

            if existingObjects.isEmpty {
                saveSuggestions(SearchSuggestion.defaults)
            } else {
                ensureSeedMarker(in: context)
                try saveIfNeeded(context)
            }
        } catch {
            assertionFailure("Failed to seed search suggestions: \(error.localizedDescription)")
        }
    }

    private func ensureSeedMarker(in context: NSManagedObjectContext) {
        do {
            guard try fetchSuggestionObjects(in: context).contains(where: {
                ($0.value(forKey: Field.id) as? String) == SeedMarker.id
            }) == false else {
                return
            }

            insertSeedMarker(in: context)
        } catch {
            assertionFailure("Failed to create search suggestions seed marker: \(error.localizedDescription)")
        }
    }

    private func insertSeedMarker(in context: NSManagedObjectContext) {
        let object = NSManagedObject(
            entity: NSEntityDescription.entity(
                forEntityName: Entity.searchSuggestion,
                in: context
            )!,
            insertInto: context
        )
        object.setValue(SeedMarker.id, forKey: Field.id)
        object.setValue(SeedMarker.kind, forKey: Field.kind)
        object.setValue(nil, forKey: Field.title)
        object.setValue(SeedMarker.order, forKey: Field.order)
    }

    private func fetchSuggestionObjects(in context: NSManagedObjectContext) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.searchSuggestion)
        request.sortDescriptors = [
            NSSortDescriptor(key: Field.order, ascending: true)
        ]
        return try context.fetch(request)
    }

    private func makeSuggestion(from object: NSManagedObject) -> SearchSuggestion? {
        guard
            let id = object.value(forKey: Field.id) as? String,
            let kindValue = object.value(forKey: Field.kind) as? String,
            let kind = SearchSuggestion.Kind(rawValue: kindValue)
        else {
            return nil
        }

        return SearchSuggestion(
            id: id,
            kind: kind,
            title: object.value(forKey: Field.title) as? String
        )
    }

    private func insert(
        _ suggestion: SearchSuggestion,
        order: Int,
        in context: NSManagedObjectContext
    ) {
        let object = NSManagedObject(
            entity: NSEntityDescription.entity(
                forEntityName: Entity.searchSuggestion,
                in: context
            )!,
            insertInto: context
        )
        object.setValue(suggestion.id, forKey: Field.id)
        object.setValue(suggestion.kind.rawValue, forKey: Field.kind)
        object.setValue(suggestion.title, forKey: Field.title)
        object.setValue(Int64(order), forKey: Field.order)
    }

    private func saveIfNeeded(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else {
            return
        }
        try context.save()
    }
}
