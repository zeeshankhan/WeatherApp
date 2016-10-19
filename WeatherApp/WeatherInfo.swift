//
//  WeatherInfo.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation
import SVProgressHUD

enum Result<T, E> {
    case success(T)
    case failure(E)
}


enum WeatherError: Error {
    case notFound(reason: String) // Data issues
    case other(reason: String) // Network, Server etc
}


enum WeatherItem : Int {

    case icon
    case observationTime
    case city
    case humidity
    case weatherDescription

    func itemValue(_ info: WeatherInfo) -> String {
        switch(self) {
        case .icon: return info.iconUrl
        case .city: return info.city.capitalized
        case .observationTime: return info.observationTime
        case .humidity: return info.humidity
        case .weatherDescription: return info.weatherDesc
        }
    }


//    static let count: Int = {
//        var max: Int = 0
//        while let _ = WeatherItem(rawValue: max) { max += 1 }
//        return max
//    }()
}

extension WeatherItem : CustomStringConvertible {

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
}

struct WeatherInfo : StatusBarNetworkActivityIndicator {

    let city: String
    let observationTime: String
    let tempC: String
    let tempF: String
    let humidity: String
    let weatherDesc: String
    let iconUrl: String

    static func fetchWeather(forCity city: String, completion: @escaping (Result<WeatherInfo?, WeatherError>) -> Void) {

        var urlComponents = URLComponents(string: "https://api.worldweatheronline.com/free/v1/weather.ashx")!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "vzkjnx2j5f88vyn5dhvvqkzc"),
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "format", value: "json")
        ]


        guard let url = urlComponents.url else {
            print("Something went wrong with URL formation. \(urlComponents.debugDescription)")
            return completion(.failure(.other(reason: "URL is missing")))
        }

        WeatherInfo.showStatusBarNetworkActivityIndicator = true
        SVProgressHUD.show(withStatus: "Loading...")

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            WeatherInfo.showStatusBarNetworkActivityIndicator = false
            SVProgressHUD.dismiss()

            if error != nil {
                return completion(.failure(.other(reason: error.debugDescription)))
            }

            guard let data = data else {
                return completion(.failure(.other(reason: "Data is nil.")))
            }


            do {
                let info = try WeatherInfo.weatherInfo(fromJsonData: data)
                DispatchQueue.main.async {
                    completion(.success(info))
                }
            }
            catch WeatherError.notFound(let msg) {
                DispatchQueue.main.async {
                    completion(.failure(.notFound(reason: msg)))
                }
            }
            catch WeatherError.other(let msg) {
                DispatchQueue.main.async {
                    completion(.failure(.notFound(reason: msg)))
                }
            }
            catch {}

        }.resume()
    }


    //TODO: try implementing currying here.
    private static func weatherInfo(fromJsonData jsonData: Data) throws -> WeatherInfo? {

        // get JSON data
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers),
            let jsonItems = json as? Dictionary<String, Any>,
            let data = jsonItems["data"] as? Dictionary<String, Any>
            else {
                throw WeatherError.other(reason: "Either JSON is wrong or data is nil.")
        }


        // get currentCondition
        guard let currentCondition = data["current_condition"] as? Array<Any>,
            let info = currentCondition.first as? Dictionary<String, Any>
            else {

                guard let error = data["error"] as? Array<Any>,
                    let msgs = error.first as? Dictionary<String, Any>,
                    let msg = msgs["msg"] as? String
                    else {
                        throw WeatherError.other(reason: "Current condition and Error both are nil.")
                }
                throw WeatherError.notFound(reason: msg)
        }


        // get info
        guard let time = info["observation_time"] as? String,
            let tempCen = info["temp_C"] as? String,
            let tempFer = info["temp_F"] as? String,
            let humid = info["humidity"] as? String
            else {
                throw WeatherError.other(reason: "Info is nil.")
        }


        // get url
        let urls = info["weatherIconUrl"] as? Array<Any>
        let urlDictionary = urls?.first as? Dictionary<String, Any>
        let urlString = urlDictionary?["value"] as? String

        // These are nice :)
        _ = urlString.flatMap { str in URL(string: str) }
        _ = urlString.flatMap { URL(string: $0) }
        _ = urlString.flatMap(URL.init)


        let descs = info["weatherDesc"] as? Array<Any>
        let descDictionary = descs?.first as? Dictionary<String, Any>
        let desc = descDictionary?["value"] as? String

        let request = data["request"] as? Array<Any>
        let requestDictionary = request?.first as? Dictionary<String, Any>
        let query = requestDictionary?["query"] as? String


        return WeatherInfo(city: query!, observationTime: time, tempC: tempCen, tempF: tempFer, humidity: humid, weatherDesc: desc!, iconUrl: urlString!)
    }

}

