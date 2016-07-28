//
//  ViewController.swift
//  PizzaMap
//
//  Created by Matt Milner on 7/27/16.
//  Copyright © 2016 Matt Milner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationsArray = [PizzaLocation]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        processJSON()
        
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addPizzaStores(){
        
        print("addPizzaStores has received \(locationsArray)")
        
        for location in locationsArray {
        
            print(location.name)
            let storeAnnotation = MKPointAnnotation()
            storeAnnotation.title = location.name
            storeAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            storeAnnotation.accessibilityLabel = location.photoURL
            self.mapView.addAnnotation(storeAnnotation)
        }
        
        
        
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MKUserLocation {
            return nil
        } else {
        
            let currentAnnotation = annotation as! MKPointAnnotation
            
            let currentAnnotationPhoto = currentAnnotation.accessibilityLabel
            
            let photoURL = NSURL(string: currentAnnotationPhoto!)
            
            let imageData = NSData(contentsOfURL: photoURL!)
            
            
            var pizzaStoreAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("PizzaStoreAnnotationView")
            
            if pizzaStoreAnnotationView == nil {
             
                pizzaStoreAnnotationView = PizzaStoreAnnotationView(annotation: annotation, reuseIdentifier: "PizzaStoreAnnotationView")
                
            }
        
            pizzaStoreAnnotationView?.canShowCallout = true
                
                
            let pizzaStoreImageView = UIImageView(image: UIImage(data: imageData!))
            
            pizzaStoreImageView.frame.size = CGSize(width: 50, height: 50)
            
            pizzaStoreAnnotationView!.addSubview(pizzaStoreImageView)
            
//            pizzaStoreAnnotationView?.image = UIImage(data: imageData!)
            
            return pizzaStoreAnnotationView
        }
    }


    
    
    
    // add didAddAnnotationViews method
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        
        if let annotationView = views.first {
            
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 550, 550)
                    self.mapView.setRegion(region, animated: true)
                    
                    
                }
            }
        }
            
    }
    
    
    private func processJSON() {
        
        let pizzaAPI = "https://dl.dropboxusercontent.com/u/20116434/locations.json"
        
        guard let url = NSURL(string: pizzaAPI) else { fatalError("Invalid URL") }
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            guard let jsonResult = NSString(data: data!, encoding: NSUTF8StringEncoding) else {
                fatalError("Unable to format data")
            }
//            print(jsonResult)
            
            let pizzaLocationsArray = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            
            for g in 0...(pizzaLocationsArray.count - 1) {
                
                let pizzaLocationsDictionary = pizzaLocationsArray[g] as! [String:AnyObject]
                
                
                    let pizzaLocation = PizzaLocation()
                
                    pizzaLocation.name = pizzaLocationsDictionary["name"] as! String
                    pizzaLocation.latitude = pizzaLocationsDictionary["latitude"] as! Double
                    pizzaLocation.longitude = pizzaLocationsDictionary["longitude"] as! Double
                    pizzaLocation.photoURL = pizzaLocationsDictionary["photoUrl"] as! String

                    self.locationsArray.append(pizzaLocation)
                
                
            }
            
            self.addPizzaStores()
            
        }.resume()
        
        
    }
    
    
    
    
    
    
    
    


}

