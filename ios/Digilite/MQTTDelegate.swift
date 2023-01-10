//
//  MQTTDelegate.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 11/25/22.
//

import Foundation
import CocoaMQTT

class MQTTDelegate: CocoaMQTT5Delegate {
    // MARK: - Constants
    
    private let EMQX_CLIENT_ID = "DIGI-NAME-STUB"
    private let EMQX_HOST = "4.tcp.ngrok.io"
    private let EMQX_PORT: UInt16 = 14793
    private let MQTT_USERNAME = "username"
    private let MQTT_PASSWORD = "password"
    private let MQTT_KEEPALIVE: UInt16 = 60
    
    // MARK: - State
    
    private var viewController: ViewController
    private var mqtt5: CocoaMQTT5
    private var connected: Bool
    private var digiphoneName: String
    
    // MARK: - Class Methods
    
    init(viewController: ViewController, digiphoneName: String) {
        self.viewController = viewController
        self.mqtt5 = CocoaMQTT5(clientID: EMQX_CLIENT_ID, host: EMQX_HOST, port: EMQX_PORT)
        self.connected = false
        self.digiphoneName = digiphoneName
        
        // MQTT 5.0 connection properties
        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
        
        self.mqtt5.delegate = self
        self.mqtt5.connectProperties = connectProperties
        self.mqtt5.username = MQTT_USERNAME
        self.mqtt5.password = MQTT_PASSWORD
        self.mqtt5.keepAlive = MQTT_KEEPALIVE
        
        viewController.updateMQTTStatus(status: "CONNECTING...")
        
        if (!self.mqtt5.connect()) {
            print("Failed to initialize MQTT connection")
        }
    }
    
    // MARK: - Helper Methods
    
    func reconnect() {
        if (connected) { return }
        
        viewController.updateMQTTStatus(status: "RECONNECTING...")
        print("Reconnecting...")
        
        if (!mqtt5.connect()) {
            viewController.updateMQTTStatus(status: "DISCONNECTED")
            print("Failed to reinitialize MQTT connection")
        }
    }
    
    func publishMessage(data: [String: Any]) {
        if (connected) {
            let json = dictionaryToJSON(dictionary: data)
            guard let json = json else {
                print("Invalid JSON dictionary provided, skipping publish")
                return
            }
            let message = CocoaMQTT5Message.init(topic: digiphoneName, string: json, qos: .qos1) // qos1 is "at least once"
            mqtt5.publish(message, properties: MqttPublishProperties.init())
        }
    }
    
    func dictionaryToJSON(dictionary: [String: Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions()) as NSData
            return NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch _ {
            return nil
        }
    }
    
    // MARK: - Implementation Methods
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        connected = true
        viewController.updateMQTTStatus(status: "CONNECTED")
        print("MQTT connection successful")
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
        connected = false
        print("MQTT disconnected")
        
        // Attempt reconnect
        reconnect()
    }
}
