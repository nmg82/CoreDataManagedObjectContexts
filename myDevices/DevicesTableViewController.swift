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

class DevicesTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var fetchedResultsController: NSFetchedResultsController!

  var selectedPerson: Person?

  override func viewDidLoad() {
    super.viewDidLoad()

    if let selectedPerson = selectedPerson {
      title = "\(selectedPerson.name)'s Devices"
    } else {
      title = "Devices"
      navigationItem.rightBarButtonItems = [
      UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addDevice:"),
      UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "selectFilter:")
      ]
    }

    let fetchRequest = NSFetchRequest(entityName: "Device")
    fetchRequest.sortDescriptors = [
      NSSortDescriptor(key: "deviceType.name", ascending: true),
      NSSortDescriptor(key: "name", ascending: true)
    ]

    fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: coreDataStack.managedObjectContext,
      sectionNameKeyPath: "deviceType.name", cacheName: nil)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    reloadData()
  }

  func reloadData(predicate: NSPredicate? = nil) {
    if let selectedPerson = selectedPerson {
      fetchedResultsController.fetchRequest.predicate =
        NSPredicate(format: "owner == %@", selectedPerson)
    } else {
      fetchedResultsController.fetchRequest.predicate = predicate
    }

    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("There was an error fetching the list of devices!")
    }

    tableView.reloadData()
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return fetchedResultsController.sections?[section].name
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DeviceCell", forIndexPath: indexPath)

    let device = fetchedResultsController.objectAtIndexPath(indexPath) as! Device

    cell.textLabel?.text = device.deviceDescription

    if let owner = device.owner {
      cell.detailTextLabel?.text = owner.name
    } else {
      cell.detailTextLabel?.text = "No owner"
    }

    return cell
  }

  // MARK: - Actions & Segues

  func selectFilter(sender: AnyObject?) {
    let sheet = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .ActionSheet)

    sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
    }))

    sheet.addAction(UIAlertAction(title: "Show All", style: .Default, handler: { (action) -> Void in
      self.reloadData()
    }))

    sheet.addAction(UIAlertAction(title: "Only Owned Devices", style: .Default, handler: { (action) -> Void in
      self.reloadData(NSPredicate(format: "owner != nil"))
    }))

    sheet.addAction(UIAlertAction(title: "Only Phones", style: .Default, handler: { (action) -> Void in
      self.reloadData(NSPredicate(format: "deviceType.name =[c] 'iphone'"))
    }))

    sheet.addAction(UIAlertAction(title: "Only Watches", style: .Default, handler: { (action) -> Void in
      self.reloadData(NSPredicate(format: "deviceType.name =[c] 'watch'"))
    }))

    presentViewController(sheet, animated: true, completion: nil)
  }

  func addDevice(sender: AnyObject?) {
    performSegueWithIdentifier("deviceDetail", sender: self)
  }

  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if selectedPerson != nil && identifier == "deviceDetail" {
      return false
    }

    return true
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let dest = segue.destinationViewController as? DeviceDetailTableViewController {
      dest.coreDataStack = coreDataStack

      if let selectedIndexPath = tableView.indexPathForSelectedRow {
        let device = fetchedResultsController.objectAtIndexPath(selectedIndexPath) as! Device
        dest.device = device
      }
    }
  }
  
}
