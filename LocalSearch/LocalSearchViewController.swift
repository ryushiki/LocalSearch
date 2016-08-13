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
//        self.initMapRegion()
    }
    
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    var mapItems: [MKMapItem] = []
    var searchResultDataSource:SearchDataSource?
    var localSearchModel = LocalSearchModel()
    var currentLocationManager = CurrentLocationManager.sharedInstance
    
    //MARK: - View Controller lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchResultDataSource = SearchDataSource(items: self.mapItems)
        self.tableView.dataSource = searchResultDataSource
        
        self.setGestureOnTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.localSearchModel.addObserver(self, forKeyPath: "mapItems", options: .New, context: nil)
        self.localSearchModel.addObserver(self, forKeyPath: "selectedRoute", options: .New, context: nil)
        
        self.currentLocationManager.addObserver(self, forKeyPath: "currentLocation", options: .New, context: nil)
        self.currentLocationManager.startupGetLocation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.localSearchModel.removeObserver(self, forKeyPath: "mapItems")
        self.localSearchModel.removeObserver(self, forKeyPath: "selectedRoute")
        self.currentLocationManager.removeObserver(self, forKeyPath: "currentLocation")
    }
    
    //MARK: -KVO Observer
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch keyPath! {
        case "mapItems":
            updateMapItems()
        case "selectedRoute":
            updateSelectedRoute()
        case "currentLocation":
            if let currentLocation = self.currentLocationManager.currentLocation {
                initMapRegion(currentLocation)
            }
        default:
            break
        }
    }
    
    func updateMapItems() {
        self.mapItems.removeAll()
        
        self.searchResultDataSource?.items = self.localSearchModel.mapItems
        self.mapItems = self.localSearchModel.mapItems
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.localSearchModel.annotations)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            self.tableView.reloadData()
        })
    }

    func updateSelectedRoute() {
        dispatch_async(dispatch_get_main_queue()){
            //show the route in map
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(self.localSearchModel.selectedRoute!.polyline, level: MKOverlayLevel.AboveRoads)
            
            //display the explain of route in the label
            self.routeInfoLabel.text =
                String(format: "Via %@ %@: about %@ mins",
                       self.localSearchModel.routeDisplayInfo!.name!,
                       self.localSearchModel.routeDisplayInfo!.distance!,
                       self.localSearchModel.routeDisplayInfo!.time!)
        }
    }
    
    //MARK: - Map Job
    func initMapRegion(currentLocation:CLLocation) {
        let center = currentLocation.coordinate
        let span = MKCoordinateSpanMake(0.520984, 0.603312)
        let region = MKCoordinateRegionMake(center, span)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.region = region
        }
    }
    
    //MARK: - Search Job
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        //start local search
        self.localSearchModel.localSearch(searchBar.text, searchRegion: self.mapView.region)
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
    
    //MARK: - TableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.mapItems[indexPath.row]
        let selectedAnnotations =  self.mapView.annotations.filter({ (annotation) -> Bool in
            return  annotation.coordinate.latitude == item.placemark.coordinate.latitude && annotation.coordinate.longitude == item.placemark.coordinate.longitude
        })
        
        if let selectedAnnotation = selectedAnnotations.first {
            self.mapView.selectAnnotation(selectedAnnotation, animated: true)
        }
        
        self.localSearchModel.setSearchMapItem(item)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer.init(overlay: overlay)
        renderer.lineWidth = 5.0
        renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
        
        return renderer
    }
    
    func setGestureOnTableView() {
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:
            #selector(exectueNavi))
        
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func exectueNavi() {
        self.performSegueWithIdentifier("showNaviPage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNaviPage" {
            if let nextViewController = segue.destinationViewController as? NaviViewController {
                nextViewController.selectedRoute = localSearchModel.selectedRoute
            }
        }
    }
}
