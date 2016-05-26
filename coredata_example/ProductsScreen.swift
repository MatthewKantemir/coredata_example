/**
 * @file   ProductsScreen.swift
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

class ProductsScreen: UIViewController, UISearchBarDelegate, UITableViewDataSource,
    UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    let loginUserEntity = LoginScreen.loginUserEntity!
    let userEntity = LoginScreen.loginUserEntity
    
    private var searchActive = false
    private var searchText = NSString()
    
    lazy var frcProducts : NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: PRODUCTS_ENTITY_NAME)
        
        let sdCategoryName = NSSortDescriptor(key: "category.categoryName", ascending: true)
        let sdProductName = NSSortDescriptor(key: "productName", ascending: true)
        //let sdProductModel = NSSortDescriptor(key: "productModel", ascending: false)
        
        fetchRequest.sortDescriptors = [sdCategoryName, sdProductName/*, sdProductModel*/]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category.categoryName",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        do {
            try frcProducts.performFetch()
        } catch _ {
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = "Product List"
        
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self,
            action: #selector(ProductsScreen.logoutBarButtonTapped(_:)))
        
        if userEntity!.isAdmin {
            tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add,
                target: self, action: #selector(ProductsScreen.addProductTapped(_:)))
        }
        
        tabBarController?.navigationController?.navigationBarHidden = false
        
        if let userProfileImage = UIImage(data: loginUserEntity.profileImage as NSData) {
            userProfileImageView.image = userProfileImage
        } else {
            userProfileImageView.image = USER_PROFILEIMAGE_DEFAULT
        }
        
        welcomeLabel.text = "Welcome: \(loginUserEntity.email)"
        
        searchBar(searchBar, textDidChange: searchBar.text!)
        resetFetchControllerSearchCriteria()
    }
    
    /* UITableViewDatasource */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frcProducts.sections {
            return sections.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frcProducts.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    /* UITableViewDelegate */
    private func configureCell(cell: ProductTVC, indexPath: NSIndexPath) {
        
        let productEntity = frcProducts.objectAtIndexPath(indexPath) as! ProductsEntity
        
        if let productImage = UIImage(data: productEntity.productImage as NSData) {
            cell.productImageView.image = productImage
        } else {
            cell.productImageView.image = PRODUCT_IMAGE_DEFAULT
        }
        
        cell.productNameLabel.text = productEntity.productName
        cell.productPriceLabel.text = String(format: "$%.02f", productEntity.unitPrice.doubleValue)
        cell.productQuantityLabel.text = String(format: "%d", productEntity.quantity.intValue)
        cell.dateCreatedLabel.text = productEntity.dateCreated.dateStringWithFormat()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! ProductTVC
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = frcProducts.sections {
            return sections[section].name
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! ProductTVC
        performSegueWithIdentifier("goToProductDetails", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return userEntity!.isAdmin
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if userEntity!.isAdmin {
            return UITableViewCellEditingStyle.Delete
        }
        
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            let selProductEntity = frcProducts.objectAtIndexPath(indexPath) as! ProductsEntity
            NSLog("Deleting product \"\(selProductEntity.productName)\" in category: \(selProductEntity.category.categoryName)")
            
            for _purchaseEntity in selProductEntity.purchaseList {
                let purchaseEntity = _purchaseEntity as! PurchaseEntity
                
                NSLog("Deleting related purchase entity for user: \(purchaseEntity.purchaser.userName)")
                managedObjectContext.deleteObject(purchaseEntity)
            }
            
            managedObjectContext.deleteObject(selProductEntity)
            do {
                try managedObjectContext.save()
            } catch _ {
            }
            
        default:
            break
        }
    }
    
    /* NSFetchedResultsControllerDelegate */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            
        switch(type) {
        case .Delete:
            NSLog("Product List: item deleted (section: \(indexPath!.section), row: \(indexPath!.row))")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Insert:
            NSLog("Product List: item inserted (section: \(newIndexPath!.section), row: \(newIndexPath!.row))")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? ProductTVC {
                configureCell(cell, indexPath: indexPath!)
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
            
        switch type {
        case .Insert:
            NSLog("Products section inserted (section: \(sectionInfo.name), index: \(sectionIndex))")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            NSLog("Products section deleted (section: \(sectionInfo.name), index: \(sectionIndex))")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    /*func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        tableView.reloadData()
    }*/
    
    /* UISearchBarDelegate */
    private func resetFetchControllerSearchCriteria() {
        
        if self.searchActive {
            frcProducts.fetchRequest.predicate = NSPredicate(format: "productName CONTAINS[cd] %@", self.searchText)
        } else {
            frcProducts.fetchRequest.predicate = nil
        }
        
        do {
            try frcProducts.performFetch()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToProductDetails" {
            let productDetailsScr = segue.destinationViewController as! ProductDetailsScreen
            let indexPath = tableView.indexPathForSelectedRow!
            
            NSLog("Display product details at section:\(indexPath.section) row:\(indexPath.row)")
            productDetailsScr.productEntity = frcProducts.objectAtIndexPath(indexPath) as? ProductsEntity
            
            searchBar.resignFirstResponder()
            
        } else if segue.identifier == "goToAddProduct" {
            let addProductScr = segue.destinationViewController as! AddProductScreen
            
            NSLog("Adding a new product")
            addProductScr.productEntity = nil
        }
    }
    
    
    @IBAction func addProductTapped(sender: UIBarButtonItem) {
        NSLog("Add product button tapped!")
        
        performSegueWithIdentifier("goToAddProduct", sender: self)
    }

    @IBAction func logoutBarButtonTapped(sender: UIBarButtonItem) {
        NSLog("Logout button tapped!")
        
        tabBarController?.navigationController?.popViewControllerAnimated(true)
    }
    
}
