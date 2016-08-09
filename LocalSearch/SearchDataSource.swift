//
//  SearchDataSource.swift
//  LocalSearch
//
//  Created by ryushiki on 2016/08/09.
//  Copyright © 2016年 liuzhihui. All rights reserved.
//

import UIKit
import MapKit

class SearchDataSource: NSObject, UITableViewDataSource {
    
    var items: [MKMapItem] = []
    
    init(items: [MKMapItem]) {
        self.items = items
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.placemark.title
        return cell
    }
    
}
