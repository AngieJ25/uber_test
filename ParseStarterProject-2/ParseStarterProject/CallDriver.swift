//
//  CallDriver.swift
//  ParseStarterProject
//
//  Created by Angela Grundy on 01/09/2015.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class CallDriver: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBAction func logoutRider(sender: AnyObject) {
        
       
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "logoutRider") {
            // pass data to next view
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            print("Current User is")
            print(currentUser)
        }
    }
    
    @IBOutlet var callDriverButton: UIButton!
    
    var riderRequestActive = false
    var driverOnTheWay = false
    
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    @IBAction func callDriver(sender: AnyObject) {
        
        if riderRequestActive == false {

        let riderRequest = PFObject(className:"riderRequest")
        riderRequest["username"] = PFUser.currentUser()?.username
        print("username is:")
        print(PFUser.currentUser()?.username)

                riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
            
            print("latitude is:")
            print(latitude)
            print("longitude is:")
            print(longitude)
                    
                riderRequest.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                       self.callDriverButton.setTitle("Cancel Request", forState: UIControlState.Normal)
                    } else {
                        print("Error is:")
                        print(error)
                        let alert = UIAlertController(title: "Could not call Uber", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            riderRequestActive = true
            
            
        } else {
            
            self.callDriverButton.setTitle("Call Driver", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            let query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                   // print("Successfully retrieved \(objects!.count) scores.")
                    
                    
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                } else {
                    
                    print(error)
                }
            }

        }
    }

    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        /*let latitude:CLLocationDegrees = 51.3968760
        let longitude:CLLocationDegrees = -0.3006530
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
*/
    }
    
    
    
    func locationManager(locationmanager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = locationmanager.location!.coordinate
        
       /* let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        */
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        let query = PFQuery(className:"riderRequest")
        query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // print("Successfully retrieved \(objects!.count) scores.")
                
                
                if let objects = objects as? [PFObject] {
                    
                    for object in objects {
                        
                        if let driverUsername = object["driverResponded"] {
                        
                        self.callDriverButton.setTitle("Driver is on the way!", forState: UIControlState.Normal)
                            
                            let query = PFQuery(className:"driverLocation")
                            query.whereKey("username", equalTo:driverUsername)
                            query.findObjectsInBackgroundWithBlock {
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    // print("Successfully retrieved \(objects!.count) scores.")
                                    
                                    
                                    if let objects = objects as? [PFObject] {
                                        
                                        for object in objects {
                                            
                                            if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                print(driverLocation)
                                                let CLDriverLocation:CLLocation
                                                CLDriverLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                print(CLDriverLocation)
                                                
                                                let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let distanceMeters = userCLLocation.distanceFromLocation(CLDriverLocation)
                                                let distanceKM = distanceMeters / 1000
                                                let roundedOneDigitDistance = Double(round(distanceKM * 10) / 10)
                                        
                                                print(roundedOneDigitDistance)
                                                
                                                self.callDriverButton.setTitle("Driver is \(roundedOneDigitDistance) km away", forState: UIControlState.Normal)
                                                
                                                self.driverOnTheWay = true
                                                
                                                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let latDelta = abs(driverLocation.latitude - location.latitude) * 2 + 0.005
                                                
                                                let lonDelta = abs(driverLocation.longitude - location.longitude) * 2 + 0.005
                                                
                                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                
                                                self.mapView.setRegion(region, animated: true)
                                                
                                                self.mapView.removeAnnotations(self.mapView.annotations)
                                                
                                                var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                var objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Your Location"
                                                self.mapView.addAnnotation(objectAnnotation)
                                                
                                                pinLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Driver Location"
                                                self.mapView.addAnnotation(objectAnnotation)


                                                
                                               // self.callDriverButton.setTitle("Driver is on the way!", forState: UIControlState.Normal)
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
            } else {
                
                print(error)
            }
        }

        
        //print("locations = \(location.latitude) \(location.longitude)")
        
        if (driverOnTheWay == false) {
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)

        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your Location"
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(objectAnnotation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
