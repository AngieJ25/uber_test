//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var `switch`: UISwitch!
    
    @IBOutlet var riderLabel: UILabel!
    
    @IBOutlet var driverLabel: UILabel!
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var alreadyRegistered: UILabel!
    
    func userAlert (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
    var signUpState = true
    
    
    @IBAction func signUp(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            userAlert("Missing Field(s)",message: "Username and password are required")
          
        }
        else {
            signUpUser()
        }
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func signUpUser() {
       
        if signUpState == true {
            
            var isDriver = false

            let user = PFUser()
            user.username = username.text
            user.password = password.text
        
            isDriver = `switch`.on
            
            user["isDriver"] = isDriver

            user.signUpInBackgroundWithBlock {
                (succeeded, error) -> Void in
                if let error = error
                {
                    if let errorString = error.userInfo["error"] as? String
                    {
                        self.userAlert("Sign Up Failed",message: errorString)
                    }
                    // Show the errorString somewhere and let the user try again.
                }
                else
                {
                    if isDriver {
                        // Driver
                        self.performSegueWithIdentifier("loginDriver", sender: nil)
                    } else
                    {
                        //Rider
                        self.performSegueWithIdentifier("loginRider", sender: nil)
                    }
                }
            }
        } else
        {
            //Login
            PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if let user = user {
                    
                    //let query = PFUser.query()
                    //query?.whereKey("isDriver", equalTo:"true")
                    //let isDriver = query?.findObjects()
                    //print("Is Driver:")
                    //print(isDriver)
                    
                    if user["isDriver"]! as! Bool == true
                    {
                        self.performSegueWithIdentifier("loginDriver", sender: nil)
                    } else
                    {
                        self.performSegueWithIdentifier("loginRider", sender: nil)
                    }
                } else {
                    if let errorString = error?.userInfo["error"] as? String
                    {
                        self.userAlert("Login Failed",message: errorString)
                    }
                    // Show the errorString somewhere and let the user try again.
                }
            }
        }
    }
    
    
    @IBAction func switchtoLogin(sender: AnyObject) {
        if signUpState == true {
            signUpButton.setTitle("Log In", forState:UIControlState.Normal)
            loginButton.setTitle("Switch to Sign Up", forState: UIControlState.Normal)
            alreadyRegistered.text = "Not registered?"
            signUpState = false
            `switch`.alpha = 0
            driverLabel.alpha = 0
            riderLabel.alpha = 0
        } else {
            signUpButton.setTitle("Sign Up", forState:UIControlState.Normal)
            loginButton.setTitle("Switch to Login", forState: UIControlState.Normal)
            signUpState = true
             alreadyRegistered.text = "Already registered?"
            `switch`.alpha = 1
            driverLabel.alpha = 1
            riderLabel.alpha = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.username.delegate = self;
        self.password.delegate = self;
        
      /*  let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success, error) -> Void in
            print("Object has been saved.")
        }*/
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            if PFUser.currentUser()?["isDriver"]! as! Bool == true
            {
                performSegueWithIdentifier("loginDriver", sender: nil)
            } else
            {
                performSegueWithIdentifier("loginRider", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

