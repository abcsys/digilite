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
    
    private var viewController: DebugViewController
    private var mqttDelegate: MQTTDelegate
    private var pathMonitorQueue: DispatchQueue
    private var pathMonitor: NWPathMonitor
    private var currentSSID: String?
    private var currentBSSID: String?
    private var currentActiveMeasurementTest: NetworkActiveMeasurementDelegate?
    
    // MARK: - Class Methods
    
    init(viewController: DebugViewController, mqttDelegate: MQTTDelegate) {
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
        
        // If the old network is not nil
        if (currentSSID != nil && currentBSSID != nil) {
            // Cancel any currently running network tests
            cancelCurrentActiveMeasurementTest()
            
            // Query for the old network's quality
            queryNetworkQuality(ssid: currentSSID!, bssid: currentBSSID!)
        }
        
        currentSSID = nil
        currentBSSID = nil
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
            newSSID = nil
            newBSSID = nil
            
            let data: [String: Any] = [
                "network": []
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: "ERROR", bssid: "ERROR")
        }
        
        // If we are on a new network
        if (newSSID != currentSSID || newBSSID != currentBSSID) {
            // If the OLD network is not nil (i.e. we were on a valid wifi network)
            if (currentSSID != nil && currentBSSID != nil) {
                // Query for the old network's quality
                queryNetworkQuality(ssid: currentSSID!, bssid: currentBSSID!)
            }
            
            // If the NEW network is not nil (i.e. we are now currently on a valid wifi network)
            if (newSSID != nil && newBSSID != nil) {
                // Start a new network active measurement test for the new network
                // Garbage collection should cancel any previously running tests automatically
                startNewNetworkActiveMeasurementTest(ssid: newSSID!, bssid: newBSSID!)
            } else {
                // Cancel any currently running network tests
                cancelCurrentActiveMeasurementTest()
            }
        }
        
        // Update the current variables to keep track of the new network
        currentSSID = newSSID
        currentBSSID = newBSSID
    }
    
    func queryNetworkQuality(ssid: String, bssid: String) {
        let queryAlertController = UIAlertController(title: "Network Quality", message: "How was the network quality?", preferredStyle: .alert)

        queryAlertController.addAction(UIAlertAction(title: "Good", style: .default, handler: { _ in
            self.publishUserReportedNetworkQuality(ssid: ssid, bssid: bssid, quality: 1)
        }))
        queryAlertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            self.publishUserReportedNetworkQuality(ssid: ssid, bssid: bssid, quality: 0)
        }))
        queryAlertController.addAction(UIAlertAction(title: "Bad", style: .default, handler: { _ in
            self.publishUserReportedNetworkQuality(ssid: ssid, bssid: bssid, quality: -1)
        }))

        DispatchQueue.main.async {
            self.viewController.present(queryAlertController, animated: true, completion: nil)
        }
    }
    
    func publishUserReportedNetworkQuality(ssid: String, bssid: String, quality: Int) {
        let data: [String: Any] = [
            "userReportedNetworkQuality": [
                "ssid": ssid,
                "bssid": bssid,
                "deviceInfo": [
                    "model": getDeviceModelName(),
                    "os": UIDevice.current.systemVersion,
                ],
                "quality": quality,
            ]
        ]
        
        mqttDelegate.publishMessage(data: data)
    }
    
    func publishNetworkActiveMeasurementResults(ssid: String, bssid: String, download: String, upload: String) {
        guard let downloadJson = download.data(using: .utf8, allowLossyConversion: false) else { return }
        guard let uploadJson = upload.data(using: .utf8, allowLossyConversion: false) else { return }

        let downloadResults: [String: Any] = try! JSONSerialization.jsonObject(with: downloadJson, options: .mutableContainers) as! [String: Any]
        let uploadResults: [String: Any] = try! JSONSerialization.jsonObject(with: uploadJson, options: .mutableContainers) as! [String: Any]
        
        let data: [String: Any] = [
            "activeMeasurement": [
                "ssid": ssid,
                "bssid": bssid,
                "deviceInfo": [
                    "model": getDeviceModelName(),
                    "os": UIDevice.current.systemVersion,
                ],
                "download": downloadResults,
                "upload": uploadResults
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
    
    func startNewNetworkActiveMeasurementTest(ssid: String, bssid: String) {
        currentActiveMeasurementTest = NetworkActiveMeasurementDelegate(viewController: self.viewController, networkDelegate: self, ssid: ssid, bssid: bssid)
        currentActiveMeasurementTest?.startTest()
    }
    
    func cancelCurrentActiveMeasurementTest() {
        guard let currentActiveMeasurementTest = currentActiveMeasurementTest else { return }
        if (currentActiveMeasurementTest.running) {
            currentActiveMeasurementTest.cancelTest()
        }
    }
    
    // MARK: - Implementation Methods
    
    func start() {
        pathMonitor.pathUpdateHandler = { path in
            guard path.status != .unsatisfied else { return }
            
            if !path.usesInterfaceType(.wifi) {
                self.updateNotConnected()
            } else {
                NEHotspotNetwork.fetchCurrent(completionHandler: { currentNetwork in
                    self.updateConnectedNetwork(network: currentNetwork)
                })
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
    }
    
    func cancel() {
        pathMonitor.cancel()
    }
}
