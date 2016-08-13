//
//  LocalSearchModel.swift
//  LocalSearch
//
//  Created by liuzhihui on 16/8/13.
//  Copyright © 2016年 liuzhihui. All rights reserved.
//

import UIKit
import MapKit

struct RouteDisplayInfo {
    var distance: String?
    var time: String?
    var name: String?
}

class LocalSearchModel: NSObject {

    dynamic var mapItems: [MKMapItem] = []
    var annotations: [MKPointAnnotation] = []
    
    dynamic var selectedRoute: MKRoute?
    var routeDisplayInfo:RouteDisplayInfo?
    
    func localSearch(searchText: String?, searchRegion: MKCoordinateRegion) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = searchRegion
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { ( response, error) in
            if let mapItems = response?.mapItems {
                self.mapItemFrom = nil
                self.mapItemTo = nil
                self.mapItems = mapItems
                self.annotations = mapItems.map({ (item) -> MKPointAnnotation in
                    let point = MKPointAnnotation()
                    point.coordinate = item.placemark.coordinate
                    point.title = item.placemark.name
                    point.subtitle = item.phoneNumber
                    return point
                })
            }
        }
    }
    
    func findDirectionsFrom(source: MKMapItem, destination:MKMapItem,  routeIndex:Int) {
        //make an request of route search
        let request = MKDirectionsRequest()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = true
        
        //exectue the route search using MKDirections
        let directions = MKDirections.init(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            if error == nil {
                //get the designation route
                let routeNo = routeIndex % response!.routes.count
                let route = response!.routes[routeNo]
                self.selectedRoute = route
                
                let distanceFormat = MKDistanceFormatter()
                let distance = distanceFormat.stringFromDistance(route.distance)
                let time = String(format: "%.0lf", route.expectedTravelTime/60)
                
                self.routeDisplayInfo = RouteDisplayInfo(distance: distance, time: time, name: route.name)
            }
        }
        
    }
    
    var mapItemFrom: MKMapItem?
    var mapItemTo: MKMapItem?
    var routeIndex: Int = 0
    
    func setSearchMapItem(item:MKMapItem) {
        if mapItemFrom == nil {
            mapItemFrom = item
        } else {
            if mapItemTo == nil {
                mapItemTo = item
            } else {
                if mapItemTo == item {
                    routeIndex += 1
                } else {
                    routeIndex = 0
                    mapItemFrom = self.mapItemTo
                    self.mapItemTo = item
                }
            }
            
            //search the route
            self.findDirectionsFrom(self.mapItemFrom!, destination: self.mapItemTo!, routeIndex: routeIndex)
        }
    }
}
