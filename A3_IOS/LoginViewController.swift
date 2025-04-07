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
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // Dismiss the keyboard
    @objc private func dismissKeyboard() {
        print("Tapped background")
        view.endEditing(true)
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
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            // Ensure Firebase returns a valid user
            if let user = authResult?.user {
                print("User logged in: \(user.email ?? "Unknown Email")")
                self.showAlert(title: "Success", message: "Welcome back, \(user.email ?? "user")!") {
                    self.navigateToHome()
                }
            } else {
                self.showAlert(title: "Error", message: "Authentication failed. Please try again.")
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
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
               sceneDelegate.window?.rootViewController = tabBarVC
               sceneDelegate.window?.makeKeyAndVisible()
           }
       }
    }
    
}
