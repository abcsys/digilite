//
//  NetworkDelegate.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 11/26/22.
//

import Foundation
import NetworkExtension


class NetworkDelegate {
    // MARK: - State
    
    private var viewController: ViewController
    private var mqttDelegate: MQTTDelegate
    private var pathMonitorQueue: DispatchQueue
    private var pathMonitor: NWPathMonitor
    
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
        viewController.updateNetworkLabels(ssid: "None", bssid: "None", signalStrength: "None")
    }

    func updateConnectedNetwork(network: NEHotspotNetwork?) {
        if let network = network {
            // Using wifi
            let ssid = network.ssid
            let bssid = network.bssid
            let signalStrength = String(network.signalStrength)
            
            let data: [String: Any] = [
                "network": [
                    "ssid": ssid,
                    "bssid": bssid,
                    "signalStrength": signalStrength
                ]
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: ssid, bssid: bssid, signalStrength: signalStrength)
        } else {
            // Error finding network information
            let data: [String: Any] = [
                "network": []
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateNetworkLabels(ssid: "ERROR", bssid: "ERROR", signalStrength: "ERROR")
        }
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
