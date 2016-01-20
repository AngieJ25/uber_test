//
//  requestListTableViewTableViewController.swift
//  ParseStarterProject
//
//  Created by Angela Grundy on 01/09/2015.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class requestListTableViewTableViewController: UITableViewController, CLLocationManagerDelegate {

    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager:CLLocationManager!
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = locationManager.location!.coordinate
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        //print("locations = \(location.latitude) \(location.longitude)")
        
        let updateDriverLocation = PFQuery(className:"driverLocation")
        updateDriverLocation.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        updateDriverLocation.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                    
                    if objects.count > 0 {
                    
                    for object in objects {
                    
                    let qryLocation = PFQuery(className:"driverLocation")
                    qryLocation.getObjectInBackgroundWithId(object.objectId!) {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil {
                            print(error)
                        } else if let object = object {
                            object["driverLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                            object.save()
                            }
                        }
                        }
                    
                } else {
                        
                        let driverLocation = PFObject(className:"driverLocation")
                        driverLocation["username"] = PFUser.currentUser()?.username
                        print("username is:")
                        print(PFUser.currentUser()?.username)
                        
                        driverLocation["driverLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                        
                        print("latitude is:")
                        print(self.latitude)
                        print("longitude is:")
                        print(self.longitude)
                        
                        driverLocation.saveInBackground()
                }
            }
            }
        }
        
        let query = PFQuery(className:"riderRequest")
        query.whereKey("location", nearGeoPoint:PFGeoPoint(latitude:location.latitude, longitude:location.longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        if object["driverResponded"] == nil {
                        
                            if let username = object["username"] as? String {
                                self.usernames.append(username)
                            }
                            if let riderLocation = object["location"] as? PFGeoPoint {
                                let requestLocation = CLLocationCoordinate2DMake(riderLocation.latitude, riderLocation.longitude)
                                self.locations.append(requestLocation)
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                                let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                                self.distances.append(distance/1000)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
                
            } else {
                
                print(error)
            }

    }
    



      }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "logoutDriver") {
            // pass data to next view
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            print("Current User is")
            print(currentUser)
        } else if segue.identifier == "viewRequests" {
            
            if let destination = segue.destinationViewController as? requestViewController {
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        
       let distanceDouble = Double(round(100*distances[indexPath.row])/100)

        cell.textLabel?.text = usernames[indexPath.row] + " - " + String(distanceDouble) + " km away"

        return cell
    }
}
