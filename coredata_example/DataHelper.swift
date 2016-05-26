/**
 * @file   DataHelper.swift
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

import Foundation
import CoreData
import UIKit

public class DataHelper {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        NSLog("DataHelper is loading...")
    }
    
    public func seedDataStore() {
        NSLog("DataHelper: seed all data store...")
        
        seedUsers()
        seedCategories()
        seedProducts()
        seedPurchases()
    }
    
    public func seedUsers() {
        
        NSLog("DataHelper: seed users...")
        
        let users = [
            (userName: "user1", email: "user1@hotmail.com", password: "user1", profileImage: UIImage(named: "user1")),
            (userName: "user2", email: "user2@hotmail.com", password: "user2", profileImage: UIImage(named: "user2")),
            (userName: "user3", email: "user3@hotmail.com", password: "user3", profileImage: UIImage(named: "user3"))
        ]
        
        for user in users {
            let newUser = NSEntityDescription.insertNewObjectForEntityForName(USERS_ENTITY_NAME, inManagedObjectContext: context) as! UsersEntity
            
            newUser.userName = user.userName
            newUser.password = user.password.encryptPassword()
            newUser.email = user.email
            newUser.userType = NSNumber(short: UserType.User.rawValue as Int16)
            newUser.userState = NSNumber(short: UserState.Active.rawValue as Int16)
            newUser.dateCreated = NSDate()
            newUser.profileImage = NSData(data: UIImageJPEGRepresentation(user.profileImage!, 1.0)!)
        }
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    public func seedCategories() {
        
        NSLog("DataHelper: seed categories...")
    
        let categories = [
            (name: "Computers", desc: "Computer category is listed"),
            (name: "Mobile Phones", desc: "Mobile phone category is listed"),
            (name: "Televisions", desc: "Television category is listed"),
        ]
        
        for category in categories {
            let newCat = NSEntityDescription.insertNewObjectForEntityForName(CATEGORY_ENTITY_NAME, inManagedObjectContext: context) as! ProductCategoriesEntity
            
            newCat.categoryName = category.name
            newCat.categoryDesc = category.desc
            newCat.categoryState = NSNumber(short: CategoryState.Active.rawValue as Int16)
            newCat.dateCreated = NSDate()
        }
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    public func seedProducts() {
        
        NSLog("DataHelper: seed products...")
        
        let catFetchRequest = NSFetchRequest(entityName: CATEGORY_ENTITY_NAME)
        let allCategories = (try! context.executeFetchRequest(catFetchRequest)) as! [ProductCategoriesEntity]
        
        let computerCategory = allCategories.filter({ $0.categoryName == "Computers" })[0]
        let phoneCategory = allCategories.filter({ $0.categoryName == "Mobile Phones" })[0]
        let tvCategory = allCategories.filter({ $0.categoryName == "Televisions" })[0]
        
        let products = [
            
            (name: "Computer - 1", model: "CMD0001", desc: "Computer description - 1", quantity: 10, price: 114.67, image: UIImage(named: "computer1"), category: computerCategory),
            (name: "Computer - 2", model: "CMD0002", desc: "Computer description - 2", quantity: 20, price: 140.99, image: UIImage(named: "computer2"), category: computerCategory),
            (name: "Computer - 3", model: "CMD0003", desc: "Computer description - 3", quantity: 30, price: 455.87, image: UIImage(named: "computer3"), category: computerCategory),
            
            (name: "Phone - 1", model: "PMD0001", desc: "Mobile phone description - 1", quantity: 100, price: 155.99, image: UIImage(named: "phone1"), category: phoneCategory),
            (name: "Phone - 2", model: "PMD0002", desc: "Mobile phone description - 2", quantity: 200, price: 255.99, image: UIImage(named: "phone2"), category: phoneCategory),
            (name: "Phone - 3", model: "PMD0003", desc: "Mobile phone description - 3", quantity: 300, price: 355.99, image: UIImage(named: "phone3"), category: phoneCategory),
            
            (name: "TV - 1", model: "TV0001", desc: "Television description - 1", quantity: 5, price: 44.30, image: UIImage(named: "tv1"), category: tvCategory),
            (name: "TV - 2", model: "TV0002", desc: "Television description - 2", quantity: 6, price: 54.30, image: UIImage(named: "tv2"), category: tvCategory),
            (name: "TV - 3", model: "TV0003", desc: "Television description - 3", quantity: 7, price: 64.30, image: UIImage(named: "tv3"), category: tvCategory),
        ]
        
        for prod in products {
            
            let newProd = NSEntityDescription.insertNewObjectForEntityForName(PRODUCTS_ENTITY_NAME, inManagedObjectContext: context) as! ProductsEntity
            
            NSLog("Saving product:(\(prod.name)) in category:(\(prod.category.categoryName))")
            
            newProd.productName = prod.name
            newProd.productModel = prod.model
            newProd.productDesc = prod.desc
            newProd.productState = NSNumber(short: ProductState.Active.rawValue as Int16)
            newProd.quantity = prod.quantity
            newProd.unitPrice = prod.price
            newProd.dateCreated = NSDate()
            newProd.productImage = NSData(data: UIImageJPEGRepresentation(prod.image!, 1.0)!)
            newProd.category = prod.category
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            NSLog("DataHelper: unable to save data in CoreData entities! (\(error.description))")
        }
    }
    
    public func seedPurchases() {
        
        NSLog("DataHelper: seed purchases...")
        
    }
}