/**
 * @file   ProductsEntity.swift
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

class ProductsEntity: ItemBaseEntity {

    @NSManaged var productDesc: String
    @NSManaged var productImage: NSData
    @NSManaged var productModel: String
    @NSManaged var productName: String
    @NSManaged var productState: NSNumber
    @NSManaged var quantity: NSNumber
    @NSManaged var unitPrice: NSNumber
    @NSManaged var category: ProductCategoriesEntity
    @NSManaged var purchaseList: NSSet

}
