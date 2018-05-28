import Foundation

public struct WeatherInfo: Codable {
    
    struct Coordinates: Codable {
        
        var latitude: Double
        var longitude: Double
        
        enum CodingKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "lon"
        }
        
    }
    
    struct WeatherCondition: Codable {
        
        var identifier: Int
        var conditionName: String
        var conditionDescription: String
        var conditionIconCode: String

        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case conditionName = "main"
            case conditionDescription = "description"
            case conditionIconCode = "icon"
        }
    }

    struct AtmosphericInformation: Codable {
        
        var temperatureKelvin: Double
        var pressurePsi: Double
        var humidity: Double

        enum CodingKeys: String, CodingKey {
            case temperatureKelvin = "temp"
            case pressurePsi = "pressure"
            case humidity
        }
        
    }
    
    var coordinates: Coordinates
    var weatherCondition: [WeatherCondition]
    var atmosphericInformation: AtmosphericInformation

    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case weatherCondition = "weather"
        case atmosphericInformation = "main"
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.coordinates = try values.decode(Coordinates.self, forKey: .coordinates)
        self.weatherCondition = try values.decode([WeatherCondition].self, forKey: .weatherCondition)
        self.atmosphericInformation = try values.decode(AtmosphericInformation.self, forKey: .atmosphericInformation)

    }
    
}
