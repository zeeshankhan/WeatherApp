//
//  WeatherInfo.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation
import UIKit

enum WeatherItem : Int {

    case icon
    case observationTime
    case city
    case humidity
    case weatherDescription

    var description : String {
        get {
            switch(self) {
            case .icon: return "Icon"
            case .city: return "City"
            case .observationTime: return "Observation Time"
            case .humidity: return "Humidity"
            case .weatherDescription: return "Weather Description"
            }
        }
    }

    func itemValue(_ info: WeatherInfo) -> String {
        switch(self) {
        case .icon: return info.iconUrl
        case .city: return info.city
        case .observationTime: return info.observationTime
        case .humidity: return info.humidity
        case .weatherDescription: return info.weatherDesc
        }
    }

    static let count: Int = {
        var max: Int = 0
        while let _ = WeatherItem(rawValue: max) { max += 1 }
        return max
    }()
}


struct WeatherInfo {

    let city: String
    let observationTime: String
    let tempC: String
    let tempF: String
    let humidity: String
    let weatherDesc: String
    let iconUrl: String


    static func fetchWeather(forCity city: String, completion: @escaping (WeatherInfo?) -> Void) {

        var urlComponents = URLComponents(string: "https://api.worldweatheronline.com/free/v1/weather.ashx")!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "vzkjnx2j5f88vyn5dhvvqkzc"),
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "format", value: "json")
        ]

//        print("URL: \(urlComponents.debugDescription)")

        guard let url = urlComponents.url else {
            print("Something went wrong with URL formation. \(urlComponents.debugDescription)")
            return
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            let info = WeatherInfo.weatherInfo(fromJsonData: data)
            DispatchQueue.main.async {
                completion(info)
            }
            
        }.resume()
    }

    
    private static func weatherInfo(fromJsonData jsonData: Data?) -> WeatherInfo? {

        // get JSON
        guard let jsonData = jsonData,
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers),
            let jsonItems = json as? Dictionary<String, Any> else {
                return nil
        }


        // get currentCondition
        guard let data = jsonItems["data"] as? Dictionary<String, Any>,
            let currentCondition = data["current_condition"] as? Array<Any>,
            let info = currentCondition.first as? Dictionary<String, Any>
            else { return nil }


        // get info
        guard let time = info["observation_time"] as? String,
            let tempCen = info["temp_C"] as? String,
            let tempFer = info["temp_F"] as? String,
            let humid = info["humidity"] as? String
            else { return nil }


        // get url
        let urls = info["weatherIconUrl"] as? Array<Any>
        let urlDictionary = urls?.first as? Dictionary<String, Any>
        let urlString = urlDictionary?["value"] as? String

        let descs = info["weatherDesc"] as? Array<Any>
        let descDictionary = descs?.first as? Dictionary<String, Any>
        let desc = descDictionary?["value"] as? String

        let request = data["request"] as? Array<Any>
        let requestDictionary = request?.first as? Dictionary<String, Any>
        let query = requestDictionary?["query"] as? String


        return WeatherInfo(city: query!, observationTime: time, tempC: tempCen, tempF: tempFer, humidity: humid, weatherDesc: desc!, iconUrl: urlString!)
    }

}

