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
    
    
    var mapItems: [MKMapItem] = []
    var searchResultDataSource:SearchDataSource?
    
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
                break
            }
        }
    }
}
