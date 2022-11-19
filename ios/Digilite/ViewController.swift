//
//  ViewController.swift
//  DigiPhone Stub
//
//  Created by Jamsheed Mistri on 10/18/22.
//

import UIKit
import CoreLocation
import NetworkExtension
import CocoaMQTT

class ViewController: UIViewController, CLLocationManagerDelegate, CocoaMQTT5Delegate {
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        print("MQTT connection successful")
        connected = true
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], UnsubAckData: MqttDecodeUnsubAck?) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        return
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        return
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        return
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        return
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: Error?) {
        return
    }
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var networkSSIDLabel: UILabel!
    @IBOutlet weak var networkBSSIDLabel: UILabel!
    @IBOutlet weak var networkSignalStrengthLabel: UILabel!
    
    let manager = CLLocationManager()
    let mqtt5 = CocoaMQTT5(clientID: "CocoaMQTT-" + String(ProcessInfo().processIdentifier), host: "broker.emqx.io", port: 1883)
    var connected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate setup
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Handle each case of location permissions
        switch manager.authorizationStatus {
            case .authorizedAlways:
                manager.startUpdatingLocation()
                updateLocation(location: manager.location)
                break
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                updateLocation(location: manager.location)
                manager.requestAlwaysAuthorization()
                break
            default:
                manager.requestAlwaysAuthorization()
                break
        }
        
        // MQTT 5.0
        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
        mqtt5.connectProperties = connectProperties

        mqtt5.username = "test"
        mqtt5.password = "public"
        mqtt5.keepAlive = 60
        mqtt5.delegate = self
        mqtt5.connect()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // Handle changes of location permissions
        manager.startUpdatingLocation()
        updateLocation(location: manager.location)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // Handles update of location
        self.updateLocation(location: locations.last)
        
        NEHotspotNetwork.fetchCurrent(completionHandler: { currentNetwork in
            self.updateNetwork(network: currentNetwork);
        })
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        latitudeLabel.text = "Latitude: ERROR"
        latitudeLabel.text = "Longitude: ERROR"
    }
    
    func updateLocation(location: CLLocation?) {
        if let location = location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            // Handle location update
            latitudeLabel.text = "Latitude: \(latitude)"
            longitudeLabel.text = "Longitude: \(longitude)"
            if (connected) {
                mqtt5.publish(CocoaMQTT5Message.init(topic: "digilite/location", string: "{latitude:\(latitude),longitude:\(longitude)}"), properties: MqttPublishProperties.init())
            }
        }
    }
    
    func updateNetwork(network: NEHotspotNetwork?) {
        if let network = network {
            networkSSIDLabel.text = "Network SSID: \(network.ssid)"
            networkBSSIDLabel.text = "Network BSSID: \(network.bssid)"
            networkSignalStrengthLabel.text = "Network Signal Strength: \(network.signalStrength)"
            if (connected) {
                mqtt5.publish(CocoaMQTT5Message.init(topic: "digilite/network", string: "{ssid:\"\(network.ssid)\",bssid:\"\(network.bssid)\",strength:\(network.signalStrength)}"), properties: MqttPublishProperties.init())
            }
        } else {
            networkSSIDLabel.text = "Network SSID: None"
            networkBSSIDLabel.text = "Network BSSID: None"
            networkSignalStrengthLabel.text = "Network Signal Strength: None"
        }
    }
}

