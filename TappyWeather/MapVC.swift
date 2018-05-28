import MapKit
import UIKit

final class MapVC: UIViewController {
    
    struct Options {
        static let currentLocationRegionDistance: CLLocationDistance = 100_000
    }
    
    // MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Private
    fileprivate var locationManager: CLLocationManager!
    fileprivate var currentLocation: CLLocation?
    
}

// MARK: - Lifecycle

extension MapVC {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureLocationManager()
        configureLocationServices()
        
    }
    
}

// MARK: - Configuration

fileprivate extension MapVC {
    
    func configureLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func configureLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            presentLocationServicesAlert()
            
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationServices()
            
        }
        
    }
    
}

// MARK: - Helpers

fileprivate extension MapVC {
    
    func startLocationServices() {
        locationManager.startUpdatingLocation()        
    }

    func presentLocationServicesAlert() {
        
        let title = NSLocalizedString("generic-error-alert.title", comment: "")
        let message = NSLocalizedString("map-view.location-services-error.message", comment: "")
        
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .default
        )
        alertVC.addAction(action)
        
        present(alertVC, animated: true)
        
    }
    
    func setMapRegion(from location: CLLocation) {
        
        let region = MKCoordinateRegionMakeWithDistance(
            location.coordinate,
            Options.currentLocationRegionDistance,
            Options.currentLocationRegionDistance
        )
        mapView.setRegion(region, animated: false)

    }

}

// MARK: - CLLocationManagerDelegate

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard
            currentLocation == nil,
            let lastLocation = locations.last
            else { return }
        
        setMapRegion(from: lastLocation)
        currentLocation = locations.last
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted, .denied:
            presentLocationServicesAlert()
            
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationServices()
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
}
