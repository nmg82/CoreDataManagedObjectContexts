
import CoreData

class DeviceTypeMigrationV1toV2: NSEntityMigrationPolicy {

  override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {

    try super.createDestinationInstancesForSourceInstance(sInstance, entityMapping: mapping, manager: manager)

    // create or look up the DeviceType
    var deviceTypeInstance: NSManagedObject!

    let deviceTypeName = sInstance.valueForKey("deviceType") as! String

    let fetchRequest = NSFetchRequest(entityName: "DeviceType")
    fetchRequest.predicate = NSPredicate(format: "name == %@", deviceTypeName)
    let results = try manager.destinationContext.executeFetchRequest(fetchRequest)

    if let resultInstance = results.last as? NSManagedObject {
      deviceTypeInstance = resultInstance
    } else {
      let entity = NSEntityDescription.entityForName("DeviceType", inManagedObjectContext: manager.destinationContext)!
      deviceTypeInstance = NSManagedObject(entity: entity, insertIntoManagedObjectContext: manager.destinationContext)
      deviceTypeInstance.setValue(deviceTypeName, forKey: "name")
    }

    // get the destination Device
    let destResults = manager.destinationInstancesForEntityMappingNamed(mapping.name, sourceInstances: [sInstance])
    if let destinationDevice = destResults.last {
      destinationDevice.setValue(deviceTypeInstance, forKey: "deviceType")
    }
  }

}













