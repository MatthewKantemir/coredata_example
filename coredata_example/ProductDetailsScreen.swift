/**
 * @file   ProductDetailsScreen.swift
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

class ProductDetailsScreen: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productModelLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productDescTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var productEntity: ProductsEntity!
    let userEntity = LoginScreen.loginUserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Details"
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self, action: #selector(ProductDetailsScreen.addBarButtonAction(_:)))
        
        navigationItem.rightBarButtonItems = [addBarButton]
        
        if userEntity.isAdmin {
            let editBarButton = UIBarButtonItem(barButtonSystemItem: .Edit,
                target: self, action: #selector(ProductDetailsScreen.editBarButtonAction(_:)))
            navigationItem.rightBarButtonItems?.append(editBarButton)
        }

        productImageView.layer.cornerRadius = productImageView.frame.width / 2
        productImageView.clipsToBounds = true
        productImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    private func displayProduct() {
        productNameLabel.text  = productEntity!.productName
        productDescTextView.text = productEntity!.productDesc
        productModelLabel.text = productEntity!.productModel
        productPriceLabel.text = String(format: "$%.02f", productEntity!.unitPrice.doubleValue)
        productQuantityLabel.text = String(productEntity!.quantity.intValue)
        categoryLabel.text = productEntity!.category.categoryName
        
        if let productImage = UIImage(data: productEntity!.productImage as NSData) {
            productImageView.image = productImage
        } else {
            productImageView.image = PRODUCT_IMAGE_DEFAULT
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayProduct()
        navigationController?.navigationBarHidden = false
    }
    
    func addBarButtonAction(sender: UIBarButtonItem) {
        NSLog("Add product item bar button tapped!")
        
        let productQuantity = productEntity!.quantity.intValue
        
        if productQuantity <= 0 {
            alertWithTitle("Warning", message: "Product is not available right now!", delegate: self, toFocus: nil)
            return
        }
        
        let purchaseList = userEntity.purchaseList.allObjects as! [PurchaseEntity]
        let oldPurchase = purchaseList.filter(
            { (pe: PurchaseEntity) -> Bool in
                return pe.product as ProductsEntity == self.productEntity })
        
        if oldPurchase.count > 0 {
            NSLog("user has purchased this before!")
            oldPurchase[0].quantity = NSNumber(int: oldPurchase[0].quantity.intValue + 1) // increment quantity by one
            oldPurchase[0].dateModified = NSDate()
        } else {
            let newPurchase = NSEntityDescription.insertNewObjectForEntityForName(PURCHASE_ENTITY_NAME,
                inManagedObjectContext: managedObjectContext) as! PurchaseEntity
            
            newPurchase.quantity = 1
            newPurchase.purchaser = LoginScreen.loginUserEntity!
            newPurchase.product = productEntity!
            newPurchase.dateCreated = NSDate()
        }
        
        /* Update Product Entity:
         * ======================
         *    1. Decrement the product quantity by one
         *    2. Set dateModified to the current date
         */
        productEntity!.quantity = NSNumber(int: productQuantity - 1)
        productEntity!.dateModified = NSDate()
        
        do {
            try managedObjectContext.save()
            NSLog("Product item \"\(productEntity!.productName)\" added into purchase list of user \(LoginScreen.loginUserEntity!.userName)")
        } catch let error as NSError {
            alertWithTitle("Error", message: "Unable to add product item in to purchase list!\n\(error.description)",
                delegate: self, toFocus: nil)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func editBarButtonAction(sender: UIBarButtonItem) {
        NSLog("Edit product item bar button tapped!")
        
        performSegueWithIdentifier("goToAddProduct", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToAddProduct" {
            let addProductScr = segue.destinationViewController as! AddProductScreen
            
            addProductScr.productEntity = productEntity
        }
    }
    
}
