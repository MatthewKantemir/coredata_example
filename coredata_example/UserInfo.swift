/**
 * @file   UserInfo.swift
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
import UIKit

let USERS_ENTITY_NAME = "UsersEntity"

enum UserType: Int16 {
    case Admin = 0
    case User = 1
}

extension UsersEntity {
    var isAdmin: Bool {
        return self.userType.shortValue == UserType.Admin.rawValue
    }
}

enum UserState: Int16 {
    case Active = 0
    case Inactive = 1
    case Deleted = 2
}


let ADMIN_USERNAME_DEFAULT = "admin"  // Administrator user name (case insensitive!)
let ADMIN_EMAIL_DEFAULT = "admin@admin.com" // Administarators e-mail address (case insensitive!)
let ADMIN_PASSWORD_DEFAULT = "admin"  // Unencrypted default admin user password

let USER_PROFILEIMAGE_DEFAULT = UIImage(named: "DefaultUserProfileImage")!
let ADMIN_PROFILEIMAGE_DEFAULT = UIImage(named: "DefaultAdminProfileImage")!