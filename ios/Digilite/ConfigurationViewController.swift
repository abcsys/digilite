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
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        if let host = defaults.string(forKey: "host") {
            hostnameTextField.text = host
        }
        if let port = defaults.string(forKey: "port") {
            portTextField.text = port
        }
        if let digiphoneName = defaults.string(forKey: "digiphoneName") {
            digiphoneNameTextField.text = digiphoneName
        }
    }
    
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
        
        defaults.set(hostname, forKey: "host")
        defaults.set(port, forKey: "port")
        defaults.set(digiphoneName, forKey: "digiphoneName")
            
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
