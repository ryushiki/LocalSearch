//
//  CurrentLocation.swift
//  LocalSearch
//
//  Created by liuzhihui on 16/8/13.
//  Copyright © 2016年 liuzhihui. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationManager: NSObject,CLLocationManagerDelegate {
    
    dynamic var currentLocation: CLLocation?
    var updateCount = 0
    
    private var locationManager: CLLocationManager!;
    
    static let sharedInstance = CurrentLocationManager()
    private override init() {
        locationManager = CLLocationManager()
    }
    
    func startupGetLocation() {
        //get permission of using Location Service
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if updateCount == 5 {
            updateCount = 0
            self.currentLocation = newLocation
            self.locationManager.stopUpdatingLocation()
        } else {
            updateCount += 1
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
}
