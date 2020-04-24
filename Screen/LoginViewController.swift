//
//  AutificationViewController.swift
//  Social App
//
//  Created by user on 16.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {


    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var registrationView: AutificationUIView!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var clientOrProvider: UISegmentedControl!
    @IBOutlet weak var headerLabel: UILabel!
    let dataBase = CoreDataManaged.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //HelperDataBase.instance.deleteAll()
        keyboard()
        installUI()
    }
    
    private func installUI() {
        let image = UIImage(named: UIConstants.Image.background)
        self.view.layer.contents = image?.cgImage
                
        if let buttonImage = UIImage(named: UIConstants.Image.next) {
            buttonNext.setImage(buttonImage, for: .normal)
        }
        
        loginTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
    }
    
    private func keyboard() {
        loginTextField.delegate = self
        
        let theTapInSageArea = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        theTapInSageArea.cancelsTouchesInView = false
        view.addGestureRecognizer(theTapInSageArea)
    
    }
    
    @IBAction func tapButtonInside(_ sender: Any) {
        guard let login = loginTextField.text, !login.isEmpty
        else {
            Alert.instance.showAlert(message: "Login field not filled", viewController: self)
            return
        }
        
        switch loginTextField.alpha {
        case 1:
            if let _ = dataBase.checkLogin(login: login) {
                passwordAppear(isHiddenSegmentedControl: true)
            } else {
                passwordAppear(isHiddenSegmentedControl: false)
            }
        case 0:
            guard let password = passwordTextField.text, !password.isEmpty else {
                Alert.instance.showAlert(message: "Password field not filled", viewController: self)
                return
            }
            
            guard headerLabel.text == "Password" else {
                dataBase.createAccount(login: loginTextField.text!, password: passwordTextField.text!, side: clientOrProvider.selectedSegmentIndex == 0 ? UIConstants.Account.provider : UIConstants.Account.client )
                goInProfile(account: check()!)
                return
            }
            
            guard let account = check() else {
                Alert.instance.showAlert(message: "Wrong password!!!", viewController: self)
                return
            }
            
            goInProfile(account: account)
            
        default:
            break
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIConstants.sequeIndificator.provider,
            let navigationVC = segue.destination as? UINavigationController,
            let providerVC = navigationVC.viewControllers[0] as? ProviderTableViewController,
            let account = check() {
            
            providerVC.accountProvider = Provider(name: account.login)
        }
        if segue.identifier == UIConstants.sequeIndificator.client,
            let navigationVC = segue.destination as? UINavigationController,
            let orderVC = navigationVC.viewControllers.first as? OrderClientTableViewController,
            let account = check() {
            
            orderVC.account = Client(name: account.login)
        }
        
    }
    
    
    @IBAction func presentLogin(_ sender: Any) {
        loginTextField.alpha = 0
        iconImageView.alpha = 0
        headerLabel.alpha = 0
        loginTextField.isHidden = false
        iconImageView.image = UIImage(systemName: "person")
        headerLabel.text = "Login"
        headerLabel.font = UIFont(name:  headerLabel.font.fontName, size: 80)
        
        
        UIView.transition(with: registrationView, duration: 1 ,options: .transitionCrossDissolve, animations: {
            self.iconImageView.alpha = 1
            self.loginTextField.alpha = 1
            self.passwordTextField.alpha = 0
            self.clientOrProvider.alpha = 0
            self.headerLabel.alpha = 1
            self.buttonBack.alpha = 0
            self.registrationView.alpha = 1
        })
        
        buttonBack.isHidden = true
        passwordTextField.isHidden = true
        clientOrProvider.isHidden = true
        loginTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func check() -> Account? {
        let account = dataBase.getAccountLogin(login: loginTextField!.text!, password: passwordTextField.text!)
        
        return account
    }
    
    private func goInProfile(account: Account) {
        if dataBase.sideAccount(account: account) == UIConstants.Account.provider {
            performSegue(withIdentifier: UIConstants.sequeIndificator.provider, sender: self)
        } else {
            performSegue(withIdentifier: UIConstants.sequeIndificator.client, sender: self)
        }
    }
    
    private func passwordAppear(isHiddenSegmentedControl: Bool) {
        loginTextField.alpha = 0
        passwordTextField.alpha = 0
        clientOrProvider.alpha = 0
        iconImageView.alpha = 0
        headerLabel.alpha = 0
        self.loginTextField.isHidden = true
        self.passwordTextField.isHidden = false
        self.buttonBack.isHidden = false
        self.clientOrProvider.isHidden = isHiddenSegmentedControl
        iconImageView.image = UIImage(systemName: "lock")
        headerLabel.text = isHiddenSegmentedControl == true ? "Password" :  "Register"
        headerLabel.font = UIFont(name:  headerLabel.font.fontName, size: 50)
        
        
        UIView.transition(with: registrationView, duration: 1 ,options: .transitionCrossDissolve, animations: {
            self.iconImageView.alpha = 1
            self.passwordTextField.alpha = 1
            self.clientOrProvider.alpha = 1
            self.headerLabel.alpha = 1
            self.buttonBack.alpha = 1
        })
    }
    
    @IBAction func comeBackToLogin(_ segue: UIStoryboardSegue){
        presentLogin(self)
        loginTextField.text = ""
        passwordTextField.text = ""
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
