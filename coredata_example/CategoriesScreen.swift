/**
 * @file   CategoriesScreen.swift
 * @author Matthew Kantemir <matthew.kantemir@gmail.com
 * @date   2016-04-11
 *
 * This file is part of coredata_example.
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import CoreData

class CategoriesScreen: UITableViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    lazy var frcCategories : NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: CATEGORY_ENTITY_NAME)
        
        let sdCategoryName = NSSortDescriptor(key: "categoryName", ascending: true)
        
        fetchRequest.sortDescriptors = [sdCategoryName]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
                                                                 target: self, action: #selector(CategoriesScreen.addCategoryButtonTapped(_:)))
        do {
            try frcCategories.performFetch()
        } catch _ {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCategoryButtonTapped(sender: UIBarButtonItem) {
        NSLog("Add new category button tapped")
        
        performSegueWithIdentifier("goToAddCategory", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frcCategories.sections {
            return sections.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frcCategories.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    func configureCell(cell:UITableViewCell, indexPath: NSIndexPath) {
        if let categoryEntity = frcCategories.objectAtIndexPath(indexPath) as? ProductCategoriesEntity {
            cell.textLabel!.text = categoryEntity.categoryName
            cell.detailTextLabel!.text = categoryEntity.dateCreated.dateStringWithFormat()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) 

        configureCell(cell, indexPath: indexPath)

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            if let categoryEntity = frcCategories.objectAtIndexPath(indexPath) as? ProductCategoriesEntity {
                NSLog("Deleting the category: \(categoryEntity.categoryName)")
                
                // Delete all products under this category:
                for _productEntity in categoryEntity.productList {
                    let productEntity = _productEntity as! ProductsEntity
                    
                    NSLog("Deleting the product: \(productEntity.productName)")
                    
                    for _purchaseEntity in productEntity.purchaseList {
                        let purchaseEntity = _purchaseEntity as! PurchaseEntity
                        
                        NSLog("Deleting purchase entity for user \(purchaseEntity.purchaser.userName)")
                        managedObjectContext.deleteObject(purchaseEntity)
                    }
                    
                    managedObjectContext.deleteObject(productEntity)
                }
                
                managedObjectContext.deleteObject(categoryEntity)
                do {
                    try managedObjectContext.save()
                } catch _ {
                }
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            NSLog("Inserting new category")
        }    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("goToEditCategory", sender: self)
    }
    
    /* NSFetchedResultsControllerDelegate */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    /*func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)*/
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            
            switch(type) {
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Update:
                if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                    configureCell(cell, indexPath: indexPath!)
                    tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                }
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToEditCategory" {
            NSLog("Editing the existing category")
            if let editCategoryScr = segue.destinationViewController as? AddCategoryScreen {
                if let indexPath = tableView.indexPathForSelectedRow {
                    editCategoryScr.categoryEntity = frcCategories.objectAtIndexPath(indexPath) as? ProductCategoriesEntity
                    editCategoryScr.categoryList = frcCategories.fetchedObjects as? [ProductCategoriesEntity]
                }
            }
        } else if segue.identifier == "goToAddCategory" {
            NSLog("Adding new category")
            
            if let addCategoryScr = segue.destinationViewController as? AddCategoryScreen {
                addCategoryScr.categoryEntity = nil
                addCategoryScr.categoryList = frcCategories.fetchedObjects as? [ProductCategoriesEntity]
            }
        }
    }

}
