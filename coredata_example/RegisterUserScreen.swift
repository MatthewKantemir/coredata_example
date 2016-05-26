/**
 * @file   RegisterUserScreen.swift
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

class RegisterUserScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userEmailField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var userPasswordReenterField: UITextField!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var userEntityList: [UsersEntity]?
    var userEntityToEdit : UsersEntity?
    
    lazy var imagePicker:UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    lazy var frcUsers: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: USERS_ENTITY_NAME)
        let sortDescriptorForUserName = NSSortDescriptor(key: "userName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorForUserName]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        userNameField.delegate = self
        userPasswordField.delegate = self
        userPasswordReenterField.delegate = self
        userEmailField.delegate = self
        
        if userEntityList == nil {
            do {
                try frcUsers.performFetch()
            } catch _ {
            }
            userEntityList = frcUsers.fetchedObjects as? [UsersEntity]
        }

        if userEntityToEdit != nil {
            if let userProfileImage = UIImage(data: userEntityToEdit!.profileImage as NSData) {
                userProfileImageView.image = userProfileImage
            } else {
                userProfileImageView.image = USER_PROFILEIMAGE_DEFAULT
            }
            
            userNameField.text = userEntityToEdit?.userName
            userEmailField.text = userEntityToEdit?.email
            userPasswordField.text = ""
            userPasswordReenterField.text = ""
            
        } else {
            userProfileImageView.image = USER_PROFILEIMAGE_DEFAULT
        }
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        userNameField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if userEntityToEdit != nil {
            navigationItem.title = "New User"
        } else {
            navigationItem.title = "Edit User"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save,
            target: self, action: #selector(RegisterUserScreen.saveButtonAction(_:)))
        
        navigationController?.navigationBarHidden = false
        
        /*
        userNameField.text = ""
        userEmailField.text = ""
        userPasswordField.text = ""
        userPasswordField.text = ""
        */
    }
    
    private func popPreviousScreen() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text!.trim().isEmpty {
            return false
        }
        
        if textField == userNameField {
            userEmailField.becomeFirstResponder()
        } else if textField == userEmailField {
            userPasswordField.becomeFirstResponder()
        } else if textField == userPasswordField {
            userPasswordReenterField.becomeFirstResponder()
        } else if textField == userPasswordReenterField {
            userPasswordReenterField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField == userPasswordReenterField {
            if userPasswordField.text!.isEmpty {
                alertWithTitle("Warning", message: "First enter the password field!", delegate: self, toFocus: userPasswordField)
                return false
            }
        }
        
        return true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userProfileImageView.image = pickerImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonAction(sender: UIBarButtonItem) {
        NSLog("Save user profile button tapped!")
        
        let userName = userNameField.text!.trim().lowercaseString
        let userEmail = userEmailField.text!.trim().lowercaseString
        let userPassword = userPasswordField.text!  // Do not trim password field!
        let userPasswordReenter = userPasswordReenterField.text!  // Do not trim password field!
        
        if userName.isEmpty {
            alertWithTitle("Error", message: "User name cannot be empty!", delegate: self, toFocus: userNameField)
            return
        }
        
        if userName == ADMIN_USERNAME_DEFAULT {
            if userEntityToEdit == nil ||
                (userEntityToEdit != nil && !userEntityToEdit!.isAdmin) {
                alertWithTitle("Error", message: "User name cannot be \"\(ADMIN_USERNAME_DEFAULT)\"", delegate: self, toFocus: userNameField)
                return
            }
        }
        
        if userName == ADMIN_EMAIL_DEFAULT {
            if userEntityToEdit == nil ||
                (userEntityToEdit != nil && !userEntityToEdit!.isAdmin) {
                alertWithTitle("Error", message: "User e-mail cannot be \"\(ADMIN_EMAIL_DEFAULT)\"", delegate: self, toFocus: userEmailField)
                return
            }
        }
        
        if userNameExists(userName) {
            if userEntityToEdit == nil ||
                (userEntityToEdit != nil && userEntityToEdit!.userName != userName) {
                alertWithTitle("Error", message: "User name \"\(userName)\" already exists!", delegate: self, toFocus: userNameField)
                return
            }
        }
        
        if userEmail.isEmpty {
            alertWithTitle("Error", message: "User e-mail address cannot be empty!", delegate: self, toFocus: userEmailField)
            return
        }
        
        if !userEmail.isValidEmail {
            alertWithTitle("Error", message: "User e-mail address is invalid!", delegate: self, toFocus: userEmailField)
            return
        }
        
        if userEmailExists(userEmail) {
            if userEntityToEdit == nil ||
                (userEntityToEdit != nil && userEntityToEdit!.email != userEmail) {
                alertWithTitle("Error", message: "E-mail address \"\(userEmail)\" already exists!", delegate: self, toFocus: userEmailField)
                return
            }
        }
        
        if userPassword.isEmpty {
            alertWithTitle("Error", message: "User password cannot be empty!", delegate: self, toFocus: userPasswordField)
            return
        }
        
        if userPassword != userPasswordReenter {
            alertWithTitle("Error", message: "Passwords does not match!", delegate: self, toFocus: userPasswordReenterField)
            return
        }
    
        
        NSLog("Saving new user into \(USERS_ENTITY_NAME)...")
        
        if userEntityToEdit == nil {
            
            let newUser = NSEntityDescription.insertNewObjectForEntityForName(USERS_ENTITY_NAME,
                inManagedObjectContext: managedObjectContext) as! UsersEntity
            
            newUser.userName = userName
            newUser.email = userEmail
            newUser.password = userPassword.encryptPassword()
            newUser.userType = NSNumber(short: UserType.User.rawValue)
            newUser.userState = NSNumber(short: UserState.Active.rawValue)
            newUser.dateCreated = NSDate()
            
            if userProfileImageView.image != USER_PROFILEIMAGE_DEFAULT {
                NSLog("Saving new user profile image")
                newUser.profileImage = NSData(data: UIImageJPEGRepresentation(userProfileImageView.image!, 1.0)!)
            }
        } else { // Update the current user profile
            userEntityToEdit!.userName = userName
            userEntityToEdit!.email = userEmail
            userEntityToEdit!.password = userPassword.encryptPassword()
            userEntityToEdit!.dateModified = NSDate()
            
            if userProfileImageView.image != USER_PROFILEIMAGE_DEFAULT {
                NSLog("Changing existing user's profile image")
                userEntityToEdit!.profileImage = NSData(data: UIImageJPEGRepresentation(userProfileImageView.image!, 1.0)!)
            }
        }
        
        do {
            try managedObjectContext.save()
            NSLog("New user has been saved into \(USERS_ENTITY_NAME)")
            
            alertWithTitle("Save", message: "User registered:\nUser Name: \(userName)\nE-Mail: \(userEmail)", delegate: self, toFocus: nil,
                completion: { self.popPreviousScreen() })
        } catch let error as NSError {
            
            NSLog("Error: Unable to save new user! (\(error.description))")
            
            alertWithTitle("Error", message: "User registration failed!\nError: \(error.description)", delegate: self, toFocus: nil,
                completion: { self.popPreviousScreen() })
        }        
    }
    
    private func userNameExists(userName: String) -> Bool {
        
        for user in userEntityList! {
            if user.userName == userName {
                return true
            }
        }
        return false
    }
    
    private func userEmailExists(email: String) -> Bool {
        
        for user in userEntityList! {
            if user.email == email {
                return true
            }
        }
        return false
    }
    
    @IBAction func profileImageTapped(sender: AnyObject) {
        NSLog("User profile image tapped!")
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: { self.activityIndicator.stopAnimating() })
        
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        NSLog("Empty area tapped!")
        
        userNameField.resignFirstResponder()
        userPasswordField.resignFirstResponder()
        userPasswordField.resignFirstResponder()
        userPasswordReenterField.resignFirstResponder()
    }
}
