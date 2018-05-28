import MapKit
import UIKit

// Cześć, Roman! 👋😜 Здраво, Ilija! 👋😜

final class MapVC: UIViewController {
    
    struct Options {
        static let currentLocationRegionDistance: CLLocationDistance = 100_000
    }
    
    enum SegueIdentifier: String {
        case showWeather
    }
    
    // MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Private
    fileprivate var locationManager: CLLocationManager!
    fileprivate var currentLocation: CLLocation?
    fileprivate var selectedLocationCoordinate: CLLocationCoordinate2D?
    
}

// MARK: - Lifecycle

extension MapVC {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureLocationManager()
        configureLocationServices()
        configureDoubleTapGesture()
        configureMapView()
        
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
    
    func configureDoubleTapGesture() {
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDetectDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func configureMapView() {
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
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
    
    @objc func didDetectDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchLocation = sender.location(in: mapView)
        let mapTapLocationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Did detect tap at latitude: \(mapTapLocationCoordinate.latitude), longitude: \(mapTapLocationCoordinate.longitude)")
        
        navigateToWeatherView(locationCoordinate: mapTapLocationCoordinate)
        
    }
    
    func navigateToWeatherView(locationCoordinate: CLLocationCoordinate2D) {
        
        selectedLocationCoordinate = locationCoordinate
        performSegue(withIdentifier: SegueIdentifier.showWeather.rawValue, sender: self)
        
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

// MARK: - UIGestureRecognizerDelegate

extension MapVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - Segues

extension MapVC: SegueHandler {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let identifierCase = segueIdentifierCase(for: segue)
        switch identifierCase {
            
        case .showWeather:
            
            let vc = segue.destination as! WeatherVC
            vc.locationCoordinate = selectedLocationCoordinate!
            
        }
        
    }
    
}
