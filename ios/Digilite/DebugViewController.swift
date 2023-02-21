//
//  DebugViewController.swift
//  DigiPhone Stub
//
//  Created by Jamsheed Mistri on 10/18/22.
//

import UIKit

class DebugViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet weak var digiphoneNameLabel: UILabel!
    @IBOutlet weak var mqttStatusLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var networkSSIDLabel: UILabel!
    @IBOutlet weak var networkBSSIDLabel: UILabel!
    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    
    // MARK: - State

    var mqttDelegate: MQTTDelegate?
    var locationDelegate: LocationDelegate?
    var networkDelegate: NetworkDelegate?
    var digiphoneName: String?
    var emqxHost: String?
    var emqxPort: UInt16?
    
    // MARK: - Class Methods
    
    override func viewDidAppear(_ animated: Bool) {
        self.mqttDelegate = MQTTDelegate(viewController: self, digiphoneName: self.digiphoneName!, emqxHost: self.emqxHost!, emqxPort: self.emqxPort!)
        self.locationDelegate = LocationDelegate(viewController: self, mqttDelegate: self.mqttDelegate!)
        self.networkDelegate = NetworkDelegate(viewController: self, mqttDelegate: self.mqttDelegate!)
        
        DispatchQueue.main.async {
            self.digiphoneNameLabel.text = "Digiphone Name: \(self.digiphoneName!)"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.locationDelegate?.cancel()
        self.networkDelegate?.cancelCurrentActiveMeasurementTest()
        self.networkDelegate?.cancel()
        self.mqttDelegate?.shutdown()
    }
    
    // MARK: - Helper Methods
    
    func updateMQTTStatus(status: String) {
        DispatchQueue.main.async {
            self.mqttStatusLabel.text = "MQTT Status: \(status)"
        }
    }
    
    func updateNetworkLabels(ssid: String, bssid: String) {
        DispatchQueue.main.async {
            self.networkSSIDLabel.text = "Network SSID: \(ssid)"
            self.networkBSSIDLabel.text = "Network BSSID: \(bssid)"
        }
    }
    
    func updateLocationLabels(latitude: String, longitude: String) {
        DispatchQueue.main.async {
            self.latitudeLabel.text = "Latitude: \(latitude)"
            self.longitudeLabel.text = "Longitude: \(longitude)"
        }
    }
    
    func updateDownloadSpeedLabel(speed: Float) {
        DispatchQueue.main.async {
            self.downloadSpeedLabel.text = "Download Speed: \(speed) Mbps"
        }
    }
    
    func updateUploadSpeedLabel(speed: Float) {
        DispatchQueue.main.async {
            self.uploadSpeedLabel.text = "Upload Speed: \(speed) Mbps"
        }
    }
    
    func updatePingLabel(ping: Float) {
        DispatchQueue.main.async {
            self.pingLabel.text = "Ping: \(ping) ms"
        }
    }
}

