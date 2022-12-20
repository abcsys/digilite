//
//  ViewController.swift
//  DigiPhone Stub
//
//  Created by Jamsheed Mistri on 10/18/22.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet weak var digiphoneNameLabel: UILabel!
    @IBOutlet weak var mqttStatusLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var networkSSIDLabel: UILabel!
    @IBOutlet weak var networkBSSIDLabel: UILabel!
    @IBOutlet weak var networkSignalStrengthLabel: UILabel!
    
    // MARK: - State

    var mqttDelegate: MQTTDelegate?
    var locationDelegate: LocationDelegate?
    var networkDelegate: NetworkDelegate?
    
    // MARK: - Class Methods
    
    override func viewDidAppear(_ animated: Bool) {
        self.queryDigiphoneName()
    }
    
    // MARK: - Helper Methods
    
    func queryDigiphoneName() {
        let queryAlertController = UIAlertController(title: "Digi Name", message: "Input your digiphone's name here", preferredStyle: .alert)

        queryAlertController.addTextField { (textField) in
            textField.placeholder = "digiphone1"
        }

        queryAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [queryAlertController] (_) in
            let digiphoneName = queryAlertController.textFields![0].text!
            
            if (digiphoneName == "") {
                self.displayQueryError()
            } else {
                self.mqttDelegate = MQTTDelegate(viewController: self, digiphoneName: digiphoneName)
                self.locationDelegate = LocationDelegate(viewController: self, mqttDelegate: self.mqttDelegate!)
                self.networkDelegate = NetworkDelegate(viewController: self, mqttDelegate: self.mqttDelegate!)
                DispatchQueue.main.async {
                    self.digiphoneNameLabel.text = "Digiphone Name: \(digiphoneName)"
                }
            }
        }))

        self.present(queryAlertController, animated: true, completion: nil)
    }
    
    func displayQueryError() {
        let errorAlertController = UIAlertController(title: "Error", message: "Digiphone's name must not be blank", preferredStyle: .alert)

        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.queryDigiphoneName()
        }))
        
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    func updateMQTTStatus(status: String) {
        DispatchQueue.main.async {
            self.mqttStatusLabel.text = "MQTT Status: \(status)"
        }
    }
    
    func updateNetworkLabels(ssid: String, bssid: String, signalStrength: String) {
        DispatchQueue.main.async {
            self.networkSSIDLabel.text = "Network SSID: \(ssid)"
            self.networkBSSIDLabel.text = "Network BSSID: \(bssid)"
            self.networkSignalStrengthLabel.text = "Network Signal Strength: \(signalStrength)"
        }
    }
    
    func updateLocationLabels(latitude: String, longitude: String) {
        DispatchQueue.main.async {
            self.latitudeLabel.text = "Latitude: \(latitude)"
            self.longitudeLabel.text = "Longitude: \(longitude)"
        }
    }
}

