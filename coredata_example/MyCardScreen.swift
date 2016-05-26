/**
 * @file   MyCardScreen.swift
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

class MyCardScreen: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                    NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var grossTotalPriceLabel: UILabel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    private var grossTotal: Double = 0.0
    private let userEntity = LoginScreen.loginUserEntity!
    
    private var searchActive = false
    private var searchText = NSString()
    
    lazy var frcPurchase : NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: PURCHASE_ENTITY_NAME)
        
        let sdCategoryName = NSSortDescriptor(key: "product.category.categoryName", ascending: true)
        let sdProductName = NSSortDescriptor(key: "product.productName", ascending: true)
        //let sdProductModel = NSSortDescriptor(key: "product.productModel", ascending: false)
        
        fetchRequest.sortDescriptors = [sdCategoryName, sdProductName/*, sdProductModel*/]
        
        // Add filter for the current user purchases:
        fetchRequest.predicate = NSPredicate(format: "purchaser.userName == %@", self.userEntity.userName)
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "product.category.categoryName",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        do {
            try frcPurchase.performFetch()
        } catch _ {
        }
        calculateGrossTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = "My Card"
        tabBarController?.navigationItem.rightBarButtonItem = nil
        tabBarController?.navigationController?.navigationBarHidden = false
        
        searchBar(searchBar, textDidChange: searchBar.text!)
        resetFetchControllerSearchCriteria()
    }
    
    private func calculateGrossTotal() {
        
        if let purchaseEntityList = frcPurchase.fetchedObjects as? [PurchaseEntity] {
            
            grossTotal = 0.0
            
            for purchaseEntity in purchaseEntityList {
                grossTotal += Double(purchaseEntity.quantity) * purchaseEntity.product.unitPrice.doubleValue
            }
            
            grossTotalPriceLabel.text = String(format: "$%.02f", grossTotal)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frcPurchase.sections {
            return sections.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frcPurchase.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    private func configureCell(cell: PurchaseTVC, indexPath: NSIndexPath) {
        let purchaseEntity = frcPurchase.objectAtIndexPath(indexPath) as! PurchaseEntity
        let productEntity = purchaseEntity.product
        
        if let productImage = UIImage(data: productEntity.productImage as NSData) {
            cell.productImageView.image = productImage
        } else {
            cell.productImageView.image = PRODUCT_IMAGE_DEFAULT
        }
        
        cell.productNameLabel.text = productEntity.productName
        cell.productModelLabel.text = productEntity.productModel
        cell.productPriceLabel.text = String(format: "$%.02f", productEntity.unitPrice.doubleValue)
        cell.productQuantityLabel.text = String(format: "%d", purchaseEntity.quantity.intValue)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("purchaseCell") as! PurchaseTVC
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = frcPurchase.sections {
            return sections[section].name
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            
            let selPurchaseEntity = frcPurchase.objectAtIndexPath(indexPath) as! PurchaseEntity
            let productEntity = selPurchaseEntity.product
            
            NSLog("Deleting purchase entity (product: \"\(productEntity.productName)\", quantity: \(selPurchaseEntity.quantity))")
            
            // Add deleted purchase quantity onto the product quantity:
            productEntity.quantity =  NSNumber(int: productEntity.quantity.intValue + selPurchaseEntity.quantity.intValue)
            
            managedObjectContext.deleteObject(selPurchaseEntity)
            do {
                try managedObjectContext.save()
            } catch _ {
            }
            
        default:
            return
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("goToProductDetails", sender: self)
    }
    
    /* NSFetchedResultsControllerDelegate */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        calculateGrossTotal()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            
        switch(type) {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            calculateGrossTotal()
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            calculateGrossTotal()
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? PurchaseTVC {
                configureCell(cell, indexPath: indexPath!)
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                calculateGrossTotal()
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
            
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    /* UISearchBarDeleagate */
    private func resetFetchControllerSearchCriteria() {
        
        if self.searchActive {
            frcPurchase.fetchRequest.predicate =
                NSPredicate(format: "purchaser.userName == %@ AND product.productName CONTAINS[cd] %@",
                    self.userEntity.userName, self.searchText)
        } else {
            frcPurchase.fetchRequest.predicate = NSPredicate(format: "purchaser.userName == %@",
                self.userEntity.userName)
        }
        
        do {
            try frcPurchase.performFetch()
        } catch _ {
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        resetFetchControllerSearchCriteria()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            self.searchText = searchText.trim()
            searchActive = true
        } else {
            searchActive = false
        }
        
        resetFetchControllerSearchCriteria()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "goToProductDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if frcPurchase.objectAtIndexPath(indexPath) is PurchaseEntity {
                    return true
                }
            }
        }
        
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToProductDetails" {
            let productDetailsScr = segue.destinationViewController as! ProductDetailsScreen
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                NSLog("Display product details at section:\(indexPath.section) row:\(indexPath.row)")
                
                if let selPurchaseEntity = frcPurchase.objectAtIndexPath(indexPath) as? PurchaseEntity {
                    productDetailsScr.productEntity = selPurchaseEntity.product
                }
            }
        }
        
        searchBar.resignFirstResponder()
        
    }

}
