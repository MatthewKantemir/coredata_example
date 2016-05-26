/**
 * @file   LoginScreen.swift
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

class LoginScreen: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginImageView: UIImageView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    lazy var frcUsers: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: USERS_ENTITY_NAME)
        let sortDescriptorForUserName = NSSortDescriptor(key: "userName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorForUserName]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    private static var _loginUserEntity: UsersEntity?
    
    /**
     * Gets the user entity object for the current logged in user
     */
    static var loginUserEntity: UsersEntity? {
        return self._loginUserEntity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameField.delegate = self
        userPasswordField.delegate = self
        
        loginImageView.image = UIImage(named: "LoginIcon")
        loginImageView.layer.cornerRadius = loginImageView.frame.width / 2
        loginImageView.clipsToBounds = true
        loginImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        do {
            //userNameField.becomeFirstResponder()
            try frcUsers.performFetch()
        } catch _ {
        }
        
        if !checkForAdminEntity() {
            addAdminUserEntity()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
        
        userNameField.text = ""
        userPasswordField.text = ""
        //userNameField.becomeFirstResponder()
    }
    
    private func checkForAdminEntity() -> Bool {
        
        NSLog("Checking for users entity (\(USERS_ENTITY_NAME)) for admin user")
        
        let userList = frcUsers.fetchedObjects as! [UsersEntity]
        
        let adminEntity = userList.filter({
                (userEntity: UsersEntity) in
                    /*return userEntity.userName == ADMIN_USERNAME_DEFAULT*/
                    return userEntity.isAdmin })
        
        return adminEntity.count > 0
    }
    
    private func addAdminUserEntity() {
        
        NSLog("Inserting admin user into the users entity (\(USERS_ENTITY_NAME))")
        
        let newUser = NSEntityDescription.insertNewObjectForEntityForName(USERS_ENTITY_NAME,
                                inManagedObjectContext: managedObjectContext) as! UsersEntity
    
        newUser.userName = ADMIN_USERNAME_DEFAULT
        newUser.password = ADMIN_PASSWORD_DEFAULT.encryptPassword()
        newUser.userType = NSNumber(short: UserType.Admin.rawValue)
        newUser.userState = NSNumber(short: UserState.Active.rawValue)
        newUser.profileImage = NSData(data: UIImageJPEGRepresentation(ADMIN_PROFILEIMAGE_DEFAULT, 1.0)!)
        newUser.email = ADMIN_EMAIL_DEFAULT
        newUser.dateCreated = NSDate()
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Error: Unable to save default user! (\(error.description))")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        NSLog("\(USERS_ENTITY_NAME) context changed!")
    }
    
    private func checkUserNameFormat(userName: String) -> Bool {
        
        if userName.isEmpty {
            // User name cannot be empty string!
            return false
        }
        
        // TODO: User e-mail address format shall be checked (user@hotmail.com)
        
        return true
    }
    
    private func checkPasswordFormat(password: String) -> Bool {
        
        if password.isEmpty {
            // User password cannot be empty string!
            return false
        }
        
        return true
    }
    
    private func checkUser(userName: String, userPassword: String) -> Bool {
        
        let userName = userNameField.text!.trim().lowercaseString
        let userPassword = userPasswordField.text!
        let isEmail = userName.isValidEmail
        
        if !checkUserNameFormat(userName) {
            alertWithTitle("Error", message: "Enter a valid user name!", delegate: self, toFocus: userNameField)
            return false
        } else if !checkPasswordFormat(userPasswordField.text!) {
            alertWithTitle("Error", message: "Enter a password please!", delegate: self, toFocus: userPasswordField)
            return false
        }

        let userList = frcUsers.fetchedObjects as! [UsersEntity]
        
        for entity in userList {
            let entityUserName = isEmail ? entity.email : entity.userName
            
            if entityUserName == userName {
                NSLog("User name \"\(userName)\" matches in the users entity!")
                
                // Check for encrypted password:
                if userPassword.encryptPassword() == entity.password {
                    NSLog("Password is correct!")
                    LoginScreen._loginUserEntity = entity
                    return true
                } else {
                    NSLog("Password is incorrect!")
                }
            }
        }
        
        alertWithTitle("Error", message: "Either user name or password is invalid!", delegate: self, toFocus: userNameField)

        return false
    }

    @IBAction func loginButtonAction(sender: UIButton) {
        NSLog("Login button tapped!")
        
        if checkUser(userNameField.text!, userPassword: userPasswordField.text!) {
            NSLog("Login is successful (User: \"\(LoginScreen._loginUserEntity!.userName)\")")
            
            // Save last login user name and date:
            NSUserDefaults.standardUserDefaults().setObject(LoginScreen._loginUserEntity?.userName, forKey: "LastLoginUserName")
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "LastLoginDate")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            performSegueWithIdentifier("loginCompleted", sender: self)
        }
    }

    @IBAction func registerButtonAction(sender: UIButton) {
        NSLog("Register new user button tapped!")
        
        performSegueWithIdentifier("goToRegisterUserScreen", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField === userNameField {
            if checkUserNameFormat(userNameField.text!) {
                textField.resignFirstResponder()
                userPasswordField.becomeFirstResponder()
                return true
            }
        } else if textField == userPasswordField {
            if checkUserNameFormat(userNameField.text!) {
                if checkPasswordFormat(userPasswordField.text!) {
                    textField.resignFirstResponder()
                    loginButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    return true
                } else {
                    alertWithTitle("Error", message: "Enter a password please!", delegate: self, toFocus: userPasswordField)
                }
            } else {
                alertWithTitle("Error", message: "Enter a valid user name!", delegate: self, toFocus: userNameField)
            }
        }
        
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToRegisterUserScreen" {
            let regScr = segue.destinationViewController as! RegisterUserScreen
            
            regScr.userEntityList = frcUsers.fetchedObjects as? [UsersEntity]
        } else if segue.identifier == "loginCompleted" {
            
        }
    }
    
    @IBAction func emptyAreaTapped(sender: AnyObject) {
        userNameField.resignFirstResponder()
        userPasswordField.resignFirstResponder()
    }
    
}

