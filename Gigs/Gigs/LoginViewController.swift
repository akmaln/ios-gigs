//
//  LoginViewController.swift
//  Gigs
//
//  Created by Akmal Nurmatov on 5/5/20.
//  Copyright © 2020 Akmal Nurmatov. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginSignupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var loginSignupButton: UIButton!
    
    var gigController: GigController?
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginSignupButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
        loginSignupButton.tintColor = .white
        loginSignupButton.layer.cornerRadius = 8.0
        
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if let userName = userNameTextField.text,
            !userName.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty {
            let user = User(username: userName, password: password)
            
            if loginType == .signUp {
                gigController?.signUp(with: user, completion: { result in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign Up Successful!", message: "Now please log in.", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "Ok!", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true) {
                                    self.loginType = .signIn
                                    self.loginSignupSegmentedControl.selectedSegmentIndex = 0
                                    self.loginSignupButton.setTitle("Sign In", for: .normal)
                                }
                            }
                        }
                    } catch {
                        print("error signing up: \(error)")
                    }
                })
            } else if loginType == .signIn  {
                // TODO: call signin method on apiController with above user object
                gigController?.logIn(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        if let error = error as? GigController.NetworkError {
                            switch error {
                            case .failedLogIn:
                                print("sign in failed")
                            case .noData, .noToken:
                                print("no data recieved")
                            default:
                                print("other error occured")
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func signinTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            loginType = .signUp
            loginSignupButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            loginSignupButton.setTitle("Sign In", for: .normal)
        }
    }
    
}
