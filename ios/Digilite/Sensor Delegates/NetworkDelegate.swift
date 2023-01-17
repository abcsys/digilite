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
        
        // If the old network is not nil, then query for the old network's quality
        if (currentSSID != nil && currentBSSID != nil) {
            queryNetworkQuality(ssid: currentSSID!, bssid: currentBSSID!);
        }
        
        currentSSID = nil;
        currentBSSID = nil;
    }

    func updateConnectedNetwork(network: NEHotspotNetwork?) {
        var newSSID: String?
        var newBSSID: String?
        
        if let network = network {
            // Using wifi
            newSSID = network.ssid
            newBSSID = network.bssid
            
            let data: [String: Any] = [
                "network": [
                    "ssid": newSSID,
                    "bssid": newBSSID
                ]
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: newSSID!, bssid: newBSSID!)
        } else {
            // Error finding network information
            newSSID = nil;
            newBSSID = nil;
            
            let data: [String: Any] = [
                "network": []
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: "ERROR", bssid: "ERROR")
        }
        
        // If we are on a new network, and the old network is not nil, then query for the old network's quality
        if ((newSSID != currentSSID || newBSSID != currentBSSID) && currentSSID != nil && currentBSSID != nil) {
            queryNetworkQuality(ssid: currentSSID!, bssid: currentBSSID!);
        }
        
        // Update the current variables to keep track of the new network
        currentSSID = newSSID;
        currentBSSID = newBSSID;
    }
    
    func queryNetworkQuality(ssid: String, bssid: String) {
        let queryAlertController = UIAlertController(title: "Network Quality", message: "How was the network quality?", preferredStyle: .alert)

        queryAlertController.addAction(UIAlertAction(title: "Good", style: .default, handler: { _ in
            self.publishNetworkQuality(ssid: ssid, bssid: bssid, quality: 1)
        }))
        queryAlertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            self.publishNetworkQuality(ssid: ssid, bssid: bssid, quality: 0)
        }))
        queryAlertController.addAction(UIAlertAction(title: "Bad", style: .default, handler: { _ in
            self.publishNetworkQuality(ssid: ssid, bssid: bssid, quality: -1)
        }))

        DispatchQueue.main.async {
            self.viewController.present(queryAlertController, animated: true, completion: nil)
        }
    }
    
    func publishNetworkQuality(ssid: String, bssid: String, quality: Int) {
        let data: [String: Any] = [
            "userReportedNetworkQuality": [
                "ssid": ssid,
                "bssid": bssid,
                "quality": quality,
                "deviceInfo": [
                    "model": getDeviceModelName(),
                    "os": UIDevice.current.systemVersion,
                ]
            ]
        ]
        
        mqttDelegate.publishMessage(data: data)
    }
    
    // Credit: https://stackoverflow.com/a/26962452
    func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
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
