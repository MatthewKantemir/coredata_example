/**
 * @file   AddProductScreen.swift
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

class AddProductScreen: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,
                        UITextFieldDelegate, UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescTextView: UITextView!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var productModelField: UITextField!
    @IBOutlet weak var productQuantityField: UITextField!
    @IBOutlet weak var productPriceField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    let userEntity = LoginScreen.loginUserEntity!
    var productEntity: ProductsEntity?
    
    lazy var imagePicker:UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
        }()
    
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
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        productNameField.delegate = self
        productModelField.delegate = self
        productQuantityField.delegate = self
        productPriceField.delegate = self
        
        do {
            try frcCategories.performFetch()
        } catch _ {
        }
        
        if productEntity != nil {
            if let productImage = UIImage(data: (productEntity!.productImage as NSData)) {
                productImageView.image = productImage
            } else {
                productImageView.image = PRODUCT_IMAGE_DEFAULT
            }
            
            productNameField.text = productEntity!.productName
            productModelField.text = productEntity!.productModel
            productQuantityField.text = productEntity!.quantity.stringValue
            productPriceField.text = productEntity!.unitPrice.stringValue
            productDescTextView.text = productEntity!.productDesc
            
            let categoryName = productEntity!.category.categoryName
            let categoryList = frcCategories.fetchedObjects as! [ProductCategoriesEntity]
            var row = 0
            
            for cat in categoryList {
                if cat.categoryName == categoryName {
                    break
                }
                
                row += 1
            }
            
            categoryPicker.selectRow(row, inComponent: 0, animated: false)
            
        } else {
            productImageView.image = PRODUCT_IMAGE_DEFAULT
            categoryPicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        productImageView.layer.cornerRadius = productImageView.frame.width / 2
        productImageView.clipsToBounds = true
        productImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = productEntity == nil ? "Add Product" : "Edit Product"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save,
            target: self, action: #selector(AddProductScreen.saveBarButtonAction(_:)))
        
        navigationController?.navigationBarHidden = false
    }
    
    /* UIPickerViewDelegate */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let sections = frcCategories.sections {
            return sections[component].numberOfObjects
        }
        
        return 0
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categoryEntity = frcCategories.fetchedObjects![row] as! ProductCategoriesEntity
        
        return categoryEntity.categoryName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let categoryEntity = frcCategories.fetchedObjects![row] as! ProductCategoriesEntity
        
        NSLog("Category \(categoryEntity.categoryName) (component:\(component), row:\(row)) selected!")
    }
    
    /* UIFetchedResultsContollerDelegate */
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        categoryPicker.reloadAllComponents()
    }
    
    /* UIImagePickerControllerDelegate */
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            productImageView.image = pickerImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveBarButtonAction(sender: UIBarButtonItem) {
        NSLog("Save product item bar button tapped!")
        
        let productName = productNameField.text!.trim()
        let productModel = productModelField.text!.trim()
        let productQuantity = Int(productQuantityField.text!.trim())
        let unitPrice = productPriceField.text!.toNSNumber
        let category = frcCategories.fetchedObjects![categoryPicker.selectedRowInComponent(0)] as! ProductCategoriesEntity
        
        if productName.isEmpty {
            alertWithTitle("Error", message: "Enter a product name", delegate: self, toFocus: productNameField)
            return
        }
        
        if productModel.isEmpty {
            alertWithTitle("Error", message: "Enter a product model", delegate: self, toFocus: productModelField)
            return
        }
        
        if productQuantity == nil {
            alertWithTitle("Error", message: "Enter a valid product quantity", delegate: self, toFocus: productQuantityField)
            return
        }
        
        if unitPrice == nil {
            alertWithTitle("Error", message: "Enter a valid unit price($)", delegate: self, toFocus: productPriceField)
            return
        }
        
        /*if category == nil {
            alertWithTitle("Error", message: "Select a category!", delegate: self, toFocus: nil)
            return
        }*/
        
        if productEntity == nil {
            
            NSLog("Creating a new product item (Category: \(category.categoryName))")
            
            let newProductEntity = NSEntityDescription.insertNewObjectForEntityForName(PRODUCTS_ENTITY_NAME,
                inManagedObjectContext: managedObjectContext) as! ProductsEntity
            
            newProductEntity.productName = productName
            newProductEntity.productModel = productModel
            newProductEntity.quantity = productQuantity!
            newProductEntity.unitPrice = unitPrice!
            newProductEntity.category = category
            newProductEntity.productDesc = productDescTextView.text
            newProductEntity.productImage = NSData(data: UIImageJPEGRepresentation(productImageView.image!, 1.0)!)
            newProductEntity.dateCreated = NSDate()
            
        } else {
            
            NSLog("Updating the existing product item (Category: \(category.categoryName))")
            
            productEntity!.productName = productName
            productEntity!.productModel = productModel
            productEntity!.quantity = productQuantity!
            productEntity!.unitPrice = unitPrice!
            productEntity!.category = category
            productEntity!.productDesc = productDescTextView.text
            productEntity!.productImage = NSData(data: UIImageJPEGRepresentation(productImageView.image!, 1.0)!)
            productEntity!.dateModified = NSDate()
        }
        
        do {
            try managedObjectContext.save()
            NSLog("Product item has been saved")
        } catch let error as NSError {
            alertWithTitle("Error", message: "Unable to save the product item!\n\(error.description)",
                delegate: self, toFocus: nil)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func productImageTapped(sender: UITapGestureRecognizer) {
        NSLog("User profile image tapped!")
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: { self.activityIndicator.stopAnimating() })

    }
    
    @IBAction func addCategoryTapped(sender: AnyObject) {
        NSLog("Add new category button tapped!")
        
        performSegueWithIdentifier("goToCategoryEdit", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToCategoryEdit" {
            if segue.destinationViewController is CategoriesScreen {
                NSLog("Categories screen is launching...")
            }
        }
    }
}
