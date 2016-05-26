/**
 * @file   utils.swift
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
import CoreData

//let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

/**
 * General purpose alert message popup utility function.
 */
func alertWithTitle(title: String!, message: String, delegate: UIViewController, toFocus: UIControl?) {
    let alert = UIAlertController(title: title!, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { _ in
        toFocus?.becomeFirstResponder() })
    alert.addAction(okAction)
    delegate.presentViewController(alert, animated: true, completion: nil)
    
    NSLog("Alert(title: \"\(title)\", message: \"\(message)\")")
}

func alertWithTitle(title: String!, message: String, delegate: UIViewController, toFocus: UIControl?, completion: (() -> Void)?) {
    let alert = UIAlertController(title: title!, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { _ in
        toFocus?.becomeFirstResponder()
        completion?()})
    alert.addAction(okAction)
    delegate.presentViewController(alert, animated: true, completion: nil)
    
    NSLog("Alert(title: \"\(title)\", message: \"\(message)\")")
}

func checkEmailFormat(email: String) -> Bool {
    
    if email.isEmpty {
        return false
    }
    
    return true
}

extension String {
    
    /**
     * Trims a string
     */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    /**
     * Validates an e-mail address string.
     */
    var isValidEmail: Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
            options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    /**
     * Password encryption function
     */
    func encryptPassword() -> String {
        let encPassword = self
        
        // TODO: Password encryption shall be done here!
        
        return encPassword
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    var toNSNumber: NSNumber? {
        return NSNumberFormatter().numberFromString(self)
    }
}

extension UIApplication {
    
    static private var _launchInitialized: Bool = false
    static private var _lastLaunchCount: Int = 0
    static private var _lastLaunchDate = NSDate()
    static private let _currentLaunchDate = NSDate()
    
    class func initLaunchInfo() {
        
        if !_launchInitialized {
            
            _lastLaunchCount = NSUserDefaults.standardUserDefaults().integerForKey("lastLaunchCount")
            
            if let date = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunchDate") as? NSDate {
                _lastLaunchDate = date
            }
            
            NSLog("lastLaunchCount=\(_lastLaunchCount), lastLaunchDate=\(_lastLaunchDate.dateStringWithFormat())")
            
            NSUserDefaults.standardUserDefaults().setInteger(_lastLaunchCount + 1, forKey: "lastLaunchCount")
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunchDate")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            _launchInitialized = true
        }
    }
    
    class func isFirstLaunch() -> Bool {
        return _lastLaunchCount == 0
    }
    
    class func getLastLaunchCount() -> Int {
        return _lastLaunchCount
    }
    
    class func getLastLaunchDate() -> NSDate {
        return _lastLaunchDate
    }
    
    class func getCurrentLaunchDate() -> NSDate {
        return _currentLaunchDate
    }
}

extension NSDate {
    
    func dateStringWithFormat(format: String = "yyyy/MM/dd - hh:mm:ss") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
}


