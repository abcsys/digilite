//
//  LocationDelegate.swift
//  Digilite
//
//  Created by Jamsheed Mistri on 11/26/22.
//

import Foundation
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    // MARK: - State
    
    private var viewController: ViewController
    private var mqttDelegate: MQTTDelegate
    private var locationManager: CLLocationManager
    
    // MARK: - Class Methods
    
    init(viewController: ViewController, mqttDelegate: MQTTDelegate) {
        self.viewController = viewController
        self.mqttDelegate = mqttDelegate
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Handle each case of location permissions
        switch locationManager.authorizationStatus {
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
                updateLocation(location: locationManager.location)
                break
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                updateLocation(location: locationManager.location)
                locationManager.requestAlwaysAuthorization()
                break
            default:
                locationManager.requestAlwaysAuthorization()
                break
        }
    }
    
    // MARK: - Helper Methods
    
    func updateLocation(location: CLLocation?) {
        if let location = location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let data: [String: Any] = [
                "location": [
                    "latitude": latitude,
                    "longitude": longitude
                ]
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateLocationLabels(latitude: String(latitude), longitude: String(longitude))
        } else {
            let data: [String: Any] = [
                "location": []
            ]
            
            mqttDelegate.publishMessage(data: data)
            viewController.updateLocationLabels(latitude: "ERROR", longitude: "ERROR")
        }
    }
    
    // MARK: - Implementation Methods
    
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
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        updateLocation(location: nil)
    }
}
