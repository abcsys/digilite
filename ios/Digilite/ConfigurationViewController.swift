//
//  ConfigurationViewController.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 2/16/23.
//

import UIKit

class ConfigurationViewController: UIViewController {
    
    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var digiphoneNameTextField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hostname = hostnameTextField.text ?? ""
        let port = portTextField.text ?? ""
        let digiphoneName = digiphoneNameTextField.text ?? ""
        
        if (hostname == "" || port == "" || digiphoneName == "") {
            displayInputError(title: "Error", message: "Please fill out all fields")
            return
        } else if (UInt16(port) == nil) {
            displayInputError(title: "Error", message: "Please enter a valid port")
            return
        }
            
        let destinationVC = segue.destination as! DebugViewController
        destinationVC.emqxHost = hostname
        destinationVC.emqxPort = UInt16(port)!
        destinationVC.digiphoneName = digiphoneName
    }
    
    func displayInputError(title: String, message: String) {
        let errorAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        self.present(errorAlertController, animated: true, completion: nil)
    }
}
