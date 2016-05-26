/**
 * @file   MyProfileScreen.swift
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

class MyProfileScreen: UIViewController {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var dateRegisteredLabel: UILabel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let userEntity = LoginScreen.loginUserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = "My Profile"
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self,
            action: #selector(MyProfileScreen.editMyProfileButtonTapped(_:)))
        tabBarController?.navigationController?.navigationBarHidden = false
        
        displayUserEntity()
    }
    
    func displayUserEntity() {
        
        if let userProfileImage = UIImage(data: userEntity.profileImage as NSData) {
            userProfileImageView.image = userProfileImage
        } else {
            userProfileImageView.image = userEntity.isAdmin ? ADMIN_PROFILEIMAGE_DEFAULT : USER_PROFILEIMAGE_DEFAULT
        }
        
        userNameLabel.text = userEntity.userName
        
        if userEntity.isAdmin {
            userTypeLabel.text = "(ADMIN)"
            userTypeLabel.hidden = false
        } else {
            userTypeLabel.hidden = true
        }
        
        userEmailLabel.text = userEntity.email
        dateRegisteredLabel.text = userEntity.dateCreated.dateStringWithFormat()
    }

    func editMyProfileButtonTapped(sender: UIBarButtonItem) {
        NSLog("Edit my profile bar button tapped")
        
        performSegueWithIdentifier("goToEditUserScreen", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToEditUserScreen" {
            let editUserScr = segue.destinationViewController as! RegisterUserScreen
            editUserScr.userEntityToEdit = userEntity
        }
    }
}
