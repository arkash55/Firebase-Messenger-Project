//
//  LocationViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 19/06/2021.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    private var coordinates: CLLocationCoordinate2D?
    
    private let manager = CLLocationManager()
    
    public var isPickable = false
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    
    private let map: MKMapView = {
        let map = MKMapView()
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        navigationController?.navigationBar.prefersLargeTitles = true
//        tabBarController?.tabBar.isHidden = true

        
        if isPickable {
            configureNavigationBar()
            addGestureToMap()
            configureLocationManager()
        } else {
            guard let latitude = coordinates?.latitude,
                  let longitude = coordinates?.longitude else {
                return
            }
            let sentLocation = CLLocation(latitude: latitude, longitude: longitude)
            zoomIn(location: sentLocation)
        }
        

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if isPickable {
//            configureLocationManager()
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send Location",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSendButton))
    }
    
    private func configureLocationManager() {
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else {
            return
        }
//        zoomIn(location: currentLocation)
        
        
    }
    
    private func zoomIn(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                    longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: center,
                                        span: span)
        
        map.setRegion(region, animated: true)
        self.coordinates = center
        addPin(pinCoordinates: center)
    }
    
    private func addGestureToMap() {
        map.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        gesture.addTarget(self, action: #selector(didTapMap(_:)))
        map.addGestureRecognizer(gesture)
    }
    
    private func addPin(pinCoordinates: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        for pin in map.annotations {
            map.removeAnnotation(pin)
        }
        pin.coordinate = pinCoordinates
        map.addAnnotation(pin)
    }
   
    
    //@Objc methods
    @objc private func didTapMap(_ gesture: UITapGestureRecognizer) {
        let tappedLocation = gesture.location(in: map)
        let tappedCoordinates = map.convert(tappedLocation, toCoordinateFrom: map)
        self.coordinates = tappedCoordinates
        addPin(pinCoordinates: tappedCoordinates)
    }
    
    @objc private func didTapSendButton() {
        
        dismiss(animated: true) {
            guard let finalCoordinates = self.coordinates else {
                return
            }
            self.completion?(finalCoordinates)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


