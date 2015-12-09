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

protocol PersonPickerDelegate: class {
  func didSelectPerson(person: Person)
}

class PeopleTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var people = [Person]()

  // for person select mode
  weak var pickerDelegate: PersonPickerDelegate?
  var selectedPerson: Person?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "People"

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPerson:")

    reloadData()
  }

  func reloadData() {
    let fetchRequest = NSFetchRequest(entityName: "Person")

    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]

    do {
      if let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Person] {
        people = results
        tableView.reloadData()
      }
    } catch {
      fatalError("There was an error fetching the list of people!")
    }
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath)

    let person = people[indexPath.row]
    cell.textLabel?.text = person.name

    if let selectedPerson = selectedPerson where selectedPerson == person {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let pickerDelegate = pickerDelegate {
      let person = people[indexPath.row]
      selectedPerson = person
      pickerDelegate.didSelectPerson(person)

      tableView.reloadData()
    } else {
      if let devicesTableViewController = storyboard?.instantiateViewControllerWithIdentifier("Devices") as? DevicesTableViewController {
        let person = people[indexPath.row]

        devicesTableViewController.coreDataStack = coreDataStack
        devicesTableViewController.selectedPerson = person
        navigationController?.pushViewController(devicesTableViewController, animated: true)
      }

    }

    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return pickerDelegate == nil
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let person = people[indexPath.row]
      coreDataStack.managedObjectContext.deleteObject(person)

      reloadData()
    }
  }

  func addPerson(sender: AnyObject?) {
    // The overall alert controller
    let alert = UIAlertController(title: "Add a Person", message: "Name?", preferredStyle: .Alert)

    // The Add button: adds a new person
    let addAction = UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
      // If the user entered a non-empty string, add a new Person
      if let textField = alert.textFields?[0],
        personEntity = NSEntityDescription.entityForName("Person", inManagedObjectContext: self.coreDataStack.managedObjectContext),
        text = textField.text where !text.isEmpty {

          let newPerson = Person(entity: personEntity, insertIntoManagedObjectContext: self.coreDataStack.managedObjectContext)
          newPerson.name = text

          do {
            try self.coreDataStack.managedObjectContext.save()
          } catch {
            self.coreDataStack.managedObjectContext.deleteObject(newPerson)

            let alert = UIAlertController(title: "Error", message: "A person's name must be longer than a single character!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
          }

          self.reloadData()
      }
    }

    // The Cancel button: does nothing
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in
    }

    // Need one text field in the alert
    alert.addTextFieldWithConfigurationHandler(nil)

    // Add the two buttons (add and cancel)
    alert.addAction(addAction)
    alert.addAction(cancelAction)

    // Present the alert controller
    presentViewController(alert, animated: true, completion: nil)
  }
}
