//
//  NaviViewController.swift
//  LocalSearch
//
//  Created by liuzhihui on 16/8/11.
//  Copyright © 2016年 liuzhihui. All rights reserved.
//

import UIKit
import MapKit

class NaviViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedRoute: MKRoute?
    var stepPoint: CLLocationCoordinate2D?
    
    
    @IBAction func backButtonTap(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.showsBuildings = true
        self.mapView.showsPointsOfInterest = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let step = self.selectedRoute!.steps[0]
        self.moveMapCameraTo(step)
    }
    
    //MARK: - Tableview Job
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedRoute!.steps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NaviCell", forIndexPath: indexPath)
        
        let step = selectedRoute!.steps[indexPath.row]
        cell.textLabel?.text = step.instructions
        cell.detailTextLabel?.text = step.notice
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let step = self.selectedRoute!.steps[indexPath.row]
        self.moveMapCameraTo(step)
    }
    
    //MARK: - Map Job 
    
    func moveMapCameraTo(step: MKRouteStep) {
        var ground: CLLocationCoordinate2D?
        var eye: CLLocationCoordinate2D?
        if self.tableView.indexPathForSelectedRow == nil {
            ground = step.polyline.coordinate
            eye = ground
        } else {
            ground = step.polyline.coordinate
            eye = stepPoint
        }
        
        let myCamera = MKMapCamera.init(lookingAtCenterCoordinate: ground!, fromEyeCoordinate: eye!, eyeAltitude: 100)
        self.mapView.setCamera(myCamera, animated: true)
        
        self.stepPoint = ground
        
        let distanceFormat = MKDistanceFormatter()
        let distance = distanceFormat.stringFromDistance(step.distance)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = ground!
        annotation.title = distance
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
    }

}
