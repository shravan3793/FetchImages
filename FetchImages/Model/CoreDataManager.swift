import Foundation
import CoreData

class CoreDataManager{
    static let shared = CoreDataManager()
    private init(){}
    
    lazy var presistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError{
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context:NSManagedObjectContext{
        return presistentContainer.viewContext
    }
    
    
    func saveContext(){
        if context.hasChanges{
            do{
                try context.save()
            }catch{
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func printDatabasePath() {
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last {
            let sqlitePath = url.appendingPathComponent("Database.sqlite").path
            print("Core Data SQLite file path: \(sqlitePath)")
        }
    }
    // MARK: - Fetch Request
    func fetch(_ objectType: DogImage.Type) -> [DogImage] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<DogImage>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            print("Failed to fetch objects: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Object
    func deleteAllDogImages() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DogImage.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            print("All DogImage items deleted successfully.")
        } catch let error as NSError {
            print("Could not delete DogImage items. \(error), \(error.userInfo)")
        }
    }
}
