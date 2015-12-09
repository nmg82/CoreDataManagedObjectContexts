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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    let fetchRequest = NSFetchRequest(entityName: "Device")
    do {
      let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)
      if results.count == 0 {
        addTestData()
      }
    } catch {
      fatalError("Error fetching data!")
    }

    if let tab = window?.rootViewController as? UITabBarController {
      for child in tab.viewControllers ?? [] {
        if let child = child as? UINavigationController, top = child.topViewController {
          if top.respondsToSelector("setCoreDataStack:") {
            top.performSelector("setCoreDataStack:", withObject: coreDataStack)
          }
        }
      }
    }

    return true
  }

  func addTestData() {
    guard let entity = NSEntityDescription.entityForName("Device", inManagedObjectContext: coreDataStack.managedObjectContext), personEntity = NSEntityDescription.entityForName("Person", inManagedObjectContext: coreDataStack.managedObjectContext), deviceTypeEntity = NSEntityDescription.entityForName("DeviceType", inManagedObjectContext: coreDataStack.managedObjectContext) else {
      fatalError("Could not find entity descriptions!")
    }

    let phoneDeviceType = DeviceType(entity: deviceTypeEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
    phoneDeviceType.name = "iPhone"
    let watchDeviceType = DeviceType(entity: deviceTypeEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
    watchDeviceType.name = "Watch"

    for i in 1...50000 {
      let device = Device(entity: entity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)

      device.name = "Some Device #\(i)"
      device.deviceType = i % 3 == 0 ? watchDeviceType : phoneDeviceType
    }

    let bob = Person(entity: personEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
    bob.name = "Bob"
    let jane = Person(entity: personEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
    jane.name = "Jane"

    coreDataStack.saveMainContext()
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    coreDataStack.saveMainContext()
  }

}

