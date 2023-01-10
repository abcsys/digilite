//
//  NetworkDelegate.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 11/26/22.
//

import Foundation
import NetworkExtension
import UIKit


class NetworkDelegate {
    // MARK: - State
    
    private var viewController: ViewController
    private var mqttDelegate: MQTTDelegate
    private var pathMonitorQueue: DispatchQueue
    private var pathMonitor: NWPathMonitor
    private var currentSSID: String?
    private var currentBSSID: String?
    
    // MARK: - Class Methods
    
    init(viewController: ViewController, mqttDelegate: MQTTDelegate) {
        self.viewController = viewController
        self.mqttDelegate = mqttDelegate
        pathMonitorQueue = DispatchQueue(label: "com.jmistri.digilite.network.pathmonitor")
        pathMonitor = NWPathMonitor()
        start()
    }
    
    // MARK: - Helper Methods
    
    func updateNotConnected() {
        // Not connected to wifi
        let data: [String: Any] = [
            "network": []
        ]
        
        mqttDelegate.publishMessage(data: data)
        viewController.updateNetworkLabels(ssid: "None", bssid: "None")
        
        currentSSID = nil;
        currentBSSID = nil;
    }

    func updateConnectedNetwork(network: NEHotspotNetwork?) {
        if let network = network {
            // Using wifi
            let ssid = network.ssid
            let bssid = network.bssid
            
            let data: [String: Any] = [
                "network": [
                    "ssid": ssid,
                    "bssid": bssid
                ]
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: ssid, bssid: bssid)
            
            // Inquire about network quality
            if (ssid != currentSSID || bssid != currentBSSID) {
                queryNetworkQuality();
                currentSSID = ssid;
                currentBSSID = bssid;
            }
        } else {
            // Error finding network information
            let data: [String: Any] = [
                "network": []
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: "ERROR", bssid: "ERROR")
            
            currentSSID = nil;
            currentBSSID = nil;
        }
    }
    
    func queryNetworkQuality() {
        let queryAlertController = UIAlertController(title: "Network Quality", message: "How is the network quality?", preferredStyle: .alert)

        queryAlertController.addAction(UIAlertAction(title: "Good", style: .default, handler: { _ in
            self.publishNetworkQuality(quality: "good")
        }))
        queryAlertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            self.publishNetworkQuality(quality: "okay")
        }))
        queryAlertController.addAction(UIAlertAction(title: "Bad", style: .default, handler: { _ in
            self.publishNetworkQuality(quality: "bad")
        }))

        viewController.present(queryAlertController, animated: true, completion: nil)
    }
    
    func publishNetworkQuality(quality: String) {
        let data: [String: Any] = [
            "userReportedNetworkQuality": [
                "ssid": currentSSID,
                "bssid": currentBSSID,
                "quality": quality
            ]
        ]
        
        mqttDelegate.publishMessage(data: data)
    }
    
    // MARK: - Implementation Methods
    
    func start() {
        pathMonitor.pathUpdateHandler = { path in
            guard path.status != .unsatisfied else { return }
            
            if !path.usesInterfaceType(.wifi) {
                self.updateNotConnected();
            } else {
                NEHotspotNetwork.fetchCurrent(completionHandler: { currentNetwork in
                    self.updateConnectedNetwork(network: currentNetwork);
                })
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
    }
    
    func cancel() {
        pathMonitor.cancel()
    }
}
