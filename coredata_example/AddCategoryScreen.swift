/**
 * @file   AddCategoryScreen.swift
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

class AddCategoryScreen: UIViewController {

    @IBOutlet weak var categoryNameLabel: UITextField!
    @IBOutlet weak var categoryDescLabel: UITextView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var categoryEntity: ProductCategoriesEntity?
    var categoryList: [ProductCategoriesEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if categoryEntity != nil {
            categoryNameLabel.text = categoryEntity!.categoryName
            categoryDescLabel.text = categoryEntity!.categoryDesc
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = categoryEntity == nil ? "Add Category" : "Edit Category"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save,
            target: self, action: #selector(AddCategoryScreen.SaveCategoryButtonTapped(_:)))
        navigationController?.navigationBarHidden = false
    }

    func SaveCategoryButtonTapped(sender: UIBarButtonItem) {
        
        NSLog("Save category button tapped")
        
        let categoryName = categoryNameLabel.text!.trim()
        
        if categoryEntity == nil {
            
            NSLog("Creating new category")
            
            if categoryList!.filter({$0.categoryName == categoryName}).count > 0 {
                alertWithTitle("Warning", message: "Category item '\(categoryName)' already exist!", delegate: self, toFocus: categoryNameLabel)
                return
            }
            
            let newCategoryEntity = NSEntityDescription.insertNewObjectForEntityForName(CATEGORY_ENTITY_NAME,
                inManagedObjectContext: managedObjectContext) as! ProductCategoriesEntity
            
            newCategoryEntity.categoryName = categoryName
            newCategoryEntity.categoryDesc = categoryDescLabel.text
            newCategoryEntity.categoryState = NSNumber(short: CategoryState.Active.rawValue)
            newCategoryEntity.dateCreated = NSDate()
            //newCategoryEntity.productList = NSSet()
            
        } else {
            
            NSLog("Updating existing category")
            
            if categoryName != categoryEntity!.categoryName &&
                categoryList!.filter({$0.categoryName == categoryName}).count > 0 {
                alertWithTitle("Warning", message: "Category item '\(categoryName)' already exists!", delegate: self, toFocus: categoryNameLabel)
                return
            }
            
            categoryEntity!.categoryName = categoryName
            categoryEntity!.categoryDesc = categoryDescLabel.text
            categoryEntity!.dateModified = NSDate()
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            alertWithTitle("Category Save Error", message: "Category cannot be saved!\n\(error.description)", delegate: self, toFocus: nil)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }

}
