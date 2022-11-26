//
//  ViewController.swift
//  DigiPhone Stub
//
//  Created by Jamsheed Mistri on 10/18/22.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mqttDelegate = MQTTDelegate()
        locationDelegate = LocationDelegate(viewController: self, mqttDelegate: mqttDelegate!)
        networkDelegate = NetworkDelegate(viewController: self, mqttDelegate: mqttDelegate!)
    }
    
    // MARK: - Helper Methods
    
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

