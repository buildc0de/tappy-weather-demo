import MapKit
import UIKit

final class WeatherVC: UIViewController {

    struct Options {
        static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        static let apiKeyUserDefaultsKey = "apiKeyUserDefaultsKey"
    }
    
    // MARK: - @IBOutlets
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Public
    var locationCoordinate: CLLocationCoordinate2D!
    
}

// MARK: - Lifecycle

extension WeatherVC {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        saveAPIKeyIfNeeded() { [unowned self] in
            self.fetchWeatherInfo()
        }
        
    }
    
}

// MARK: - Helpers

fileprivate extension WeatherVC {
    
    func saveAPIKeyIfNeeded(completion: (() -> Void)? = nil) {
        
        if UserDefaults.standard.value(forKey: Options.apiKeyUserDefaultsKey) == nil {
            
            let title = NSLocalizedString("api-key-alert.title" , comment: "")
            let message = NSLocalizedString("api-key-alert.message" , comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField()
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                
                let textField = alert.textFields![0]
                UserDefaults.standard.setValue(textField.text, forKey: Options.apiKeyUserDefaultsKey)
                print("Saved API key")
                
                completion?()
                
            }))
            
            present(alert, animated: true)
            
        } else {
            completion?()
        }
        
    }
    
    func fetchWeatherInfo() {
        
        guard
            let apiKey = UserDefaults.standard.string(forKey: Options.apiKeyUserDefaultsKey)
            else {
                print("Failed to retrieve API key")
                return
        }
        
        let session = URLSession.shared
        let requestURL = URL(string: "\(Options.baseURL)?APPID=\(apiKey)&lat=\(locationCoordinate.latitude)&lon=\(locationCoordinate.longitude)")!
        let request = URLRequest(url: requestURL)
        
        let dataTask = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            guard
                let data = data,
                let _ = response,
                error == nil
                else {
                    print("Failed to receive valid data")
                    return
            }
            
            self?.extractWeatherInfo(from: data)
            
        })
        dataTask.resume()
        
    }
    
    func extractWeatherInfo(from data: Data) {
        
        let decoder = JSONDecoder()
        do {
            
            guard
                let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: AnyHashable],
                let httpStatusCode = jsonData["cod"] as? Int,
                httpStatusCode == 200
                else {
                    print("Failed to receive a valid response")
                    return
            }
            
            let weatherInfo = try decoder.decode(WeatherInfo.self, from: data)
            print(weatherInfo)
            
            DispatchQueue.main.async {
                self.updateView(with: weatherInfo)
            }
            
        } catch {
            fatalError("Can't parse JSON")
        }

    }
    
    func updateView(with weatherInfo: WeatherInfo) {
        
        latitudeLabel.text = "\(weatherInfo.coordinates.latitude)"
        longitudeLabel.text = "\(weatherInfo.coordinates.longitude)"
        conditionLabel.text = weatherInfo.weatherCondition.first?.conditionName
        
        let temperatureInK = weatherInfo.atmosphericInformation.temperatureKelvin
        let temperatureInF = "\(String(format:"%.0f", temperatureInK * (9/5) - 459.67))°F"
        let temperatureInC = "\(String(format:"%.0f", temperatureInK - 273.15))°C"
        temperatureLabel.text = "\(temperatureInF) (\(temperatureInC))"
        
    }
    
}
