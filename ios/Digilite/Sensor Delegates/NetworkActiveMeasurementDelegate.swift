//
//  NetworkActiveMeasurementDelegate.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 1/17/23.
//

import Foundation
import NDT7

class NetworkActiveMeasurementDelegate: NDT7TestInteraction {
    // MARK: - State
    
    private var viewController: DebugViewController
    private var networkDelegate: NetworkDelegate
    private var ssid: String
    private var bssid: String
    private var ndt7Test: NDT7Test?
    private var downloadMeasurement: NDT7Measurement?
    private var uploadMeasurement: NDT7Measurement?
    private var currentlyRunningTest: NDT7TestConstants.Kind?
    var running: Bool
    
    // MARK: - Class Methods
    
    init(viewController: DebugViewController, networkDelegate: NetworkDelegate, ssid: String, bssid: String) {
        self.viewController = viewController
        self.networkDelegate = networkDelegate
        self.ssid = ssid
        self.bssid = bssid
        self.ndt7Test = NDT7Test(settings: NDT7Settings())
        self.running = false
        self.ndt7Test?.delegate = self
    }
    
    // MARK: - Helper Methods
    
    func startTest() {
        self.running = true
        ndt7Test?.startTest(download: true, upload: true) { [weak self] (error) in
            guard self != nil else { return }
            
            self?.running = false
            
            if let error = error {
                print("NDT7 speed test failed with error: \(error.localizedDescription)")
            } else {
                print("NDT7 speed test finished")
            }
        }
    }
    
    func cancelTest() {
        ndt7Test?.cancel()
        self.running = false
    }
    
    func displaySpeedInfo(measurement: NDT7Measurement) {
        if (currentlyRunningTest == .download) {
            let downloadSpeed = 8 * Float((measurement.tcpInfo?.bytesAcked)!) / Float((measurement.tcpInfo?.elapsedTime)!)
            self.viewController.updateDownloadSpeedLabel(speed: downloadSpeed)
        } else if (currentlyRunningTest == .upload) {
            let uploadSpeed: Float = 8 * Float((measurement.tcpInfo?.bytesReceived)!) / Float((measurement.tcpInfo?.elapsedTime)!)
            self.viewController.updateUploadSpeedLabel(speed: uploadSpeed)
        }
        
        let ping = Float((measurement.tcpInfo?.minRTT)!) / 1000
        self.viewController.updatePingLabel(ping: ping)
    }
    
    // MARK: - Implementation Methods
    
    // Is called when an upload or download section starts or finishes
    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        print("NDT7 \(kind) test for network \(self.ssid) \(running ? "started" : "finished")")
        if (running) {
            currentlyRunningTest = kind
        }
        
        // Test finished
        if (kind == .upload && !running) {
            currentlyRunningTest = nil
            
            guard let downloadJson = downloadMeasurement?.rawData else { return }
            guard let uploadJson = uploadMeasurement?.rawData else { return }

            networkDelegate.publishNetworkActiveMeasurementResults(ssid: ssid, bssid: bssid, download:downloadJson, upload:uploadJson)
        }
    }
    
    // Is called when a new measurement is received
    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        // We only care about the TCP info
        if (measurement.tcpInfo != nil) {
            if (kind == .download) {
                downloadMeasurement = measurement
            } else if (kind == .upload) {
                uploadMeasurement = measurement
            }
            displaySpeedInfo(measurement: measurement)
        }
    }
    
    // Is called when an error occurs
    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        print("NDT7 speed test \(kind) error: \(error)")
    }
}
