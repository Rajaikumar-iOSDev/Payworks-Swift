//
//  ViewController.swift
//  PaySwift
//
//  Created by Rajai on 22/10/19.
//  Copyright © 2019 Rajai. All rights reserved.
//

import UIKit
import mpos_ui

class ViewController: UIViewController {
    
    @IBOutlet weak var amountText: UITextField!
    var originalsizes: CGRect!
    var modifiedsizes: CGRect!
    var isYChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setTapGestute()
        setKeyboardWorkObjects()
    }
    ///Set objects related to make keyboard work
    fileprivate func setKeyboardWorkObjects() {
        originalsizes = CGRect(
            origin: CGPoint(x: self.view.frame.origin.x, y: view.frame.origin.y),
            size: view.frame.size
        )
        modifiedsizes = CGRect(
            origin: CGPoint(x: self.view.frame.origin.x, y: view.frame.origin.y - 40),
            size: view.frame.size
        )
    }
    ///Set tap Gesture for the view to dismiss the keyboard
    fileprivate func setTapGestute() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    ///Dismiss the keyboard
    @objc func dismissKeyboard() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.originalsizes
            self.view.endEditing(true)
            self.isYChanged = false})
    }
    
    ///Amount pay action
    @IBAction func payAmount(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.originalsizes
            self.view.endEditing(true)
            self.isYChanged = false})
        if amountText.text?.count != 0{
            
            var variable = ""
            if let text = amountText.text, !text.isEmpty
            {
                variable = text
            }else {
                variable = "5.00"
            }
            
            let mPosUi = MPUMposUi.initialize(with: .LIVE,
                                              merchantIdentifier:"ID",
                                              merchantSecret:"secret")
            
            // When using Verifone readers via WiFi or Ethernet, use the following parameters:
            let accessoryParameters = MPAccessoryParameters.tcpAccessoryParameters(with: .verifoneVIPA,
                                                                                   remote:"192.168.254.123",
                                                                                   port:16107,
                                                                                   optionals:nil)
            
            //When using the Bluetooth Miura, use the following parameters:
//            let accessoryParameters = MPAccessoryParameters.externalAccessoryParameters(with: .miuraMPI, protocol: "com.miura.shuttle", optionals: nil)
           // let accessoryParameters = MPAccessoryParameters.mock()
            
            let transactionParameters = MPTransactionParameters.charge(withAmount: NSDecimalNumber(string: variable),
                                                                       currency:MPCurrency.USD,
                                                                       optionals:{ (optionals:MPTransactionParametersOptionals!) in
                                                                        optionals.subject = "Medical Treatment"
                                                                        optionals.customIdentifier = "yourReferenceForTheTransaction"
            })
            mPosUi.configuration.appearance.navigationBarTint = #colorLiteral(red: 0.05154533684, green: 0.1255731881, blue: 0.2839779854, alpha: 1)
            mPosUi.configuration.appearance.navigationBarTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            mPosUi.configuration.terminalParameters = accessoryParameters
            mPosUi.configuration.summaryFeatures = MPUMposUiConfigurationSummaryFeature.sendReceiptViaEmail
            
            let viewController:UIViewController! = mPosUi.createTransactionViewController(with: transactionParameters,
                                                                                          completed:{ (controller:UIViewController,result:MPUTransactionResult,transaction:MPTransaction?)
                                                                                            in
                                                                                            self.dismiss(animated: true, completion:nil)
                                                                                            
                                                                                            let alert = UIAlertController(title: "Result", message: "", preferredStyle: .alert)
                                                                                            
                                                                                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                                                            
                                                                                            alert.addAction(alertAction)
                                                                                            
                                                                                            if result == MPUTransactionResult.approved {
                                                                                                
                                                                                                alert.message = "Payment was approved!"
                                                                                            } else {
                                                                                                
                                                                                                alert.message = "Payment was declined/aborted!"
                                                                                            }
                                                                                            
                                                                                            self.present(alert, animated: true, completion: nil)
            })
            
            let modalNav = UINavigationController(rootViewController: viewController)
            
            modalNav.navigationBar.barStyle = .black
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone{
                
                modalNav.modalPresentationStyle = .fullScreen
                
            }else{
                
                modalNav.modalPresentationStyle = .formSheet
            }
            
            self.present(modalNav, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Alert!", message: "Please provide an valid amount.", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

/// Handle UITextFieldDelegate methods

extension ViewController:UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.originalsizes
            self.view.endEditing(true)
            self.isYChanged = false})
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if isYChanged == false{
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = self.modifiedsizes
                
                self.isYChanged = true
                
            })
            
        }
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
}
