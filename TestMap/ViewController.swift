//
//  ViewController.swift
//  TestMap
//
//  Created by user on 5/28/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import MapKit

//еще один способ задавать точки

class Pin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(pinTitle: String, pincoord: CLLocationCoordinate2D) {
        self.coordinate = pincoord
        self.title = pinTitle
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var MapView: MKMapView!
    
    let manager: CLLocationManager = {
        let locatiomanager = CLLocationManager()
        locatiomanager.activityType = .fitness
        locatiomanager.desiredAccuracy = kCLLocationAccuracyBest
        locatiomanager.distanceFilter = 1
        locatiomanager.showsBackgroundLocationIndicator = true
        locatiomanager.pausesLocationUpdatesAutomatically = true
        return locatiomanager
    } ()
    
    var itemMapFirst: MKMapItem!
    var itemmapTwo: MKMapItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapView.delegate = self
        manager.delegate = self
        authorization()
        manager.startUpdatingLocation()
        pointsOnMap() //Заполнение карты точками через массив
        let touch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(recong:))) //nagatie
        MapView.addGestureRecognizer(touch)
    }
    //для функции построения линий
    @objc func addPin(recong: UIGestureRecognizer) {
        let newlocation = recong.location(in: MapView)
        let newCoordinate = MapView.convert(newlocation, toCoordinateFrom: MapView)
        itemmapTwo = MKMapItem(placemark: MKPlacemark(coordinate: newCoordinate))
        let pin = Pin(pinTitle: "Конечный пункт", pincoord: newCoordinate)
        MapView.addAnnotation(pin)
    }
    
    // Заполнение карты точками через массив
   func pointsOnMap() {
       let arrayLat = [56.81, 54.81, 55.31]
       let arrayLon = [37.49, 38.00, 36.91]
       if arrayLat.count == arrayLon.count {
        for i in 0..<arrayLat.count {
           let point = MKPointAnnotation ()
            point.title = ""
            point.coordinate = CLLocationCoordinate2D(latitude: arrayLat[i], longitude: arrayLon[i])
           self.MapView.addAnnotation(point)
           calculateRow()
        }
 }
}
    
    func  authorization() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            MapView.showsUserLocation = true
        } else {
            manager.requestWhenInUseAuthorization()
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print(location.coordinate)
            itemMapFirst = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        }
    }
    
    // функция построения линий
    func calculateRow() {
        
        let request = MKDirections.Request()
        request.source = itemMapFirst!
        request.destination = itemmapTwo!
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        direction.calculate { (responce, error) in
            guard let directionResponce = responce else {
               print("Oshibka")
                return
            }
            let route = directionResponce.routes[0]
            self.MapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.lineWidth = 4
       render.strokeColor = .red
        return render
    }
    }
}
