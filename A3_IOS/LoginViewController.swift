//
//  LoginViewController.swift
//  A3_IOS
//
//  Created by Rhea Shah on 4/2/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password.")
            return
        }

        authenticateUser(email: email, password: password)
    }
    
    //Firebase Authentication
    private func authenticateUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Success", message: "Logged in successfully!") {
                    self?.navigateToHome()
                }
            }
        }
    }

    //Helper Functions
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true, completion: nil)
    }

    private func navigateToHome() {
        // Example: Dismiss the login screen and go to the home page
        dismiss(animated: true, completion: nil)
    }
    
}
