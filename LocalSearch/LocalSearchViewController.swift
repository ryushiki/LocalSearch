//
//  LocalSearchViewController.swift
//  LocalSearch
//
//  Created by liuzhihui on 16/8/7.
//  Copyright © 2016年 liuzhihui. All rights reserved.
//

import UIKit
import MapKit

class LocalSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
        }
    }
    
    @IBAction func initButtonPressed(sender: UIButton) {
        self.initMapRegion()
    }
    
    
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    var mapItems: [MKMapItem] = []
    var searchResultDataSource:SearchDataSource?
    var mapItemFrom: MKMapItem?
    var mapItemTo: MKMapItem?
    var routeIndex: Int = 0
    var response: MKDirectionsResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initMapRegion()
        self.searchResultDataSource = SearchDataSource(items: self.mapItems)
        self.tableView.dataSource = searchResultDataSource
    }

    //MARK: - Search Job
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (let response , let error) in
            self.mapItems.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            if let mapItems = response?.mapItems {
                for item in mapItems {
                    let point = MKPointAnnotation()
                    point.coordinate = item.placemark.coordinate
                    point.title = item.placemark.name
                    point.subtitle = item.phoneNumber
                    self.mapView.addAnnotation(point)
                    self.mapItems.append(item)
                }
                
                self.searchResultDataSource?.items = self.mapItems
                self.mapItemFrom = nil
                self.mapItemTo = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    //MARK: - Map Job
    
    func initMapRegion() {
        let center = CLLocationCoordinate2DMake(21.500352, -157.959694)
        let span = MKCoordinateSpanMake(0.520984, 0.603312)
        let region = MKCoordinateRegionMake(center, span)
        
        self.mapView.region = region
    }
    
    //MARK: - TableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.mapItems[indexPath.row]
        
        for annotation in mapView.annotations {
            if annotation.coordinate.latitude == item.placemark.coordinate.latitude && annotation.coordinate.longitude == item.placemark.coordinate.longitude{
                self.mapView.selectAnnotation(annotation, animated: true)
                
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
                break
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer.init(overlay: overlay)
        renderer.lineWidth = 5.0
        renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
        
        return renderer
    }
    
    //MARK -Route Job
    
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
                self.response = response
                print(response?.routes.count)
                
                //get the designation route
                let routeNo = routeIndex % response!.routes.count
                let route = response!.routes[routeNo]
                
                let distanceFormat = MKDistanceFormatter()
                let distance = distanceFormat.stringFromDistance(route.distance)
                let time = String(format: "%.0lf", route.expectedTravelTime/60)
                
                //show the route in map
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                
                //display the explain of route in the label
                self.routeInfoLabel.text = String(format: "%@経由で%@:約%@分で到着", route.name, distance, time)
            }
        }
        
    }
}
