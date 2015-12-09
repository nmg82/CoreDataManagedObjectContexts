/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreData

class DebugViewController: UIViewController {
  var coreDataStack: CoreDataStack!

  @IBOutlet weak var exportButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  @IBAction func exportTapped(sender: AnyObject) {
    activityIndicator.startAnimating()
    exportButton.enabled = false

    let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    childContext.parentContext = coreDataStack.managedObjectContext

    let fetchRequest = NSFetchRequest(entityName: "Device")

    childContext.performBlock() {
      do {
        if let results = try childContext.executeFetchRequest(fetchRequest) as? [Device] {
          for device in results {
            print("Device \(device.name) \(device.deviceType?.name)")
          }
        }
      } catch {
        print("Error fetching records for export")
      }

      dispatch_sync(dispatch_get_main_queue()) {
        self.activityIndicator.stopAnimating()
        self.exportButton.enabled = true
      }
    }
  }

  @IBAction func unassignAllTapped(sender: AnyObject) {

    let fetchRequest = NSFetchRequest(entityName: "Device")
    fetchRequest.predicate = NSPredicate(format: "owner != nil")

    do {
      if let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Device] {
        for device in results {
          device.owner = nil
        }

        coreDataStack.saveMainContext()

        let alert = UIAlertController(title: "Batch Update Succeeded", message: "\(results.count) devices unassigned.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
      }
    } catch {
      let alert = UIAlertController(title: "Batch Update Failed", message: "There was an error unassigning the devices.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }

  }

  @IBAction func deleteAllTapped(sender: AnyObject) {
    let deviceTypeFetchRequest = NSFetchRequest(entityName: "DeviceType")
    let deviceTypeDeleteRequest = NSBatchDeleteRequest(fetchRequest: deviceTypeFetchRequest)
    deviceTypeDeleteRequest.resultType = .ResultTypeCount

    let deviceFetchRequest = NSFetchRequest(entityName: "Device")
    let deviceDeleteRequest = NSBatchDeleteRequest(fetchRequest: deviceFetchRequest)
    deviceDeleteRequest.resultType = .ResultTypeCount

    let personFetchRequest = NSFetchRequest(entityName: "Person")
    let personDeleteRequest = NSBatchDeleteRequest(fetchRequest: personFetchRequest)
    personDeleteRequest.resultType = .ResultTypeCount

    do {
      let deviceTypeResult = try coreDataStack.managedObjectContext.executeRequest(deviceTypeDeleteRequest) as! NSBatchDeleteResult
      let personResult = try coreDataStack.managedObjectContext.executeRequest(personDeleteRequest) as! NSBatchDeleteResult
      let deviceResult = try coreDataStack.managedObjectContext.executeRequest(deviceDeleteRequest) as! NSBatchDeleteResult

      let alert = UIAlertController(title: "Batch Delete Succeeded", message: "\(deviceTypeResult.result!) device type records and \(deviceResult.result!) device records and \(personResult.result!) person records deleted.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    } catch {
      let alert = UIAlertController(title: "Batch Delete Failed", message: "There was an error with the batch delete. \(error)", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }
    
  }
  
}
