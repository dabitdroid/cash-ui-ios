//
//  MapViewController.swift
//
//  Created by Giancarlo Pacheco on 5/14/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import MapKit
import CashCore

private let kAtmAnnotationViewReusableIdentifier = "kAtmAnnotationViewReusableIdentifier"
private let kLocationDistance: Double = 1300000
private let kHoustonLocation = CLLocation(latitude: 31.3915, longitude: -99.1707)

// TODO: Localize strings
class MapViewController: UIViewController, ATMListFilter {

    private let mapATMs = MKMapView()

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return _locationManager
    }()

    var atmAnnotations: Array<AtmAnnotation> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupMapView()
        mapATMs.centerToLocation(kHoustonLocation, regionRadius: kLocationDistance)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        addConstraints()
        
        let parent = self.parent as! AtmLocationsViewController
        parent.searchBackgroundView.backgroundColor = .clear
        parent.myLocationButton.isHidden = false
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapATMs.showsUserLocation = true
        }
    }
    
    func addSubviews() {
        view.backgroundColor = .clear
        view.addSubview(mapATMs)
    }

    func addConstraints() {
        let parent = self.parent as! AtmLocationsViewController
        mapATMs.constrain([
            mapATMs.topAnchor.constraint(equalTo: parent.containerView.topAnchor, constant: 0),
            mapATMs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapATMs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapATMs.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])

    }
    
    func setupMapView() {
        mapATMs.isScrollEnabled = true
        mapATMs.isZoomEnabled = true

        mapATMs.showsScale = true
        mapATMs.showsCompass = true
        
        mapATMs.register(AtmAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapATMs.delegate = self
    }
    
    @objc func containerViewTapped(_ sender: Any) {
        view.endEditing(true)
        let parent = self.parent as! AtmLocationsViewController
        parent.searchBar.resignFirstResponder()
    }
    
    public func locationButtonTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: Map Filtering
extension MapViewController {
    func update(_ atms: [AtmMachine]?) {
        self.mapATMs.removeAnnotations(self.atmAnnotations)
        self.atmAnnotations.removeAll()
        
        if let items = atms {
            for atmMachine in items {
                let annotation = AtmAnnotation.init(atm: atmMachine)
                self.atmAnnotations.append(annotation)
            }
        }
        self.mapATMs.addAnnotations(self.atmAnnotations)
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        mapATMs.centerToLocation(manager.location!, regionRadius: kLocationDistance)
        
        let parent = self.parent as! AtmLocationsViewController
        parent.myLocationButton.isSelected = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let parent = self.parent as! AtmLocationsViewController
        parent.myLocationButton.isSelected = false
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapATMs.dequeueReusableAnnotationView(withIdentifier: kAtmAnnotationViewReusableIdentifier)
        let annot = annotation as! AtmAnnotation
        
        if annotationView == nil {
            annotationView = AtmAnnotationView(annotation: annotation, reuseIdentifier: kAtmAnnotationViewReusableIdentifier)
            
            (annotationView as! AtmAnnotationView).atmMarkerAnnotationViewDelegate = self
        } else {
            annotationView!.annotation = annot
        }
        
        if (annot.atm.redemption!.boolValue) {
            annotationView?.image = UIImage(named: "atmWhite")
        }
        else {
            annotationView?.image = UIImage(named: "atmGrey")
        }
        
        return annotationView
    }
    
    func center(on atm: CashCore.AtmMachine, regionRadius: CLLocationDistance? = kLocationDistance, shouldOffset: Bool? = false) {
        guard let latitude = atm.latitude, let longitude = atm.longitude else {
            return
        }
        let lat = Double(latitude)
        let long = Double(longitude)
        let offset: Double = shouldOffset! ? 0.00255 : 0.0
        let location = CLLocation(latitude: lat! - offset, longitude: long!)
        mapATMs.centerToLocation(location, regionRadius: regionRadius!)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotationView = view as! AtmAnnotationView
        guard let atm = annotationView.customCalloutView?.atm else { return }
        center(on: atm)
    }
    
//    func centerAnnotationInRect(annotation: MKAnnotation, rect: CGRect) {
//
//        let visibleCenter = CGPointMake(rect.midX, CGRectGetMidY(rect))
//
//        let annotationCenter = mapATMs.convert(annotation.coordinate, toPointTo: view)
//
//        let distanceX: CGFloat = visibleCenter.x - annotationCenter.x
//        let distanceY = visibleCenter.y - annotationCenter.y

//        mapATMs.scrollWithOffset(CGPoint(x: distanceX, y: distanceY), animated: true)
//    }
}

extension MapViewController: AtmInfoViewDelegate {
    func detailsRequestedForAtm(atm: AtmMachine) {
        center(on: atm, regionRadius: 500, shouldOffset: true)
        let parent = self.parent as! AtmLocationsViewController
        parent.sendVerificationVC?.setAtmInfo(atm)
        parent.verifyCashCodeVC?.atmMachineTitleLabel.text = atm.addressDesc
        parent.sendVerificationVC?.showView()
        parent.searchBar.resignFirstResponder()

        parent.verifyCashCodeVC!.atm = atm
    }
}
