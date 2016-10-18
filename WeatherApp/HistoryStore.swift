//
//  HistoryStore.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/15/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation

private let key = "WeatherAppSearchHistory"
private let cacheCount = 10

@available(*, deprecated, message: "use Recent Store file instead")
class History {

    private var cities = UserDefaults.standard.stringArray(forKey: key)
    private var queue = DispatchQueue(label: "com.zeeshan.weatherapp.DispatchQueue")


    /// Adds the city to history, if not already present
    func add(_ city: String, completion: @escaping (Bool) -> Void) {

        guard city.characters.count > 0 else {
            return completion(false)
        }

        queue.async(flags: .barrier) { [weak self] in

            if self?.cities == nil {
                self?.cities = [String]()
            }

            if (self?.cities?.count)! > 0 && (self?.cities?.contains(city.lowercased()))! {
                return completion(false)
            }

            if (self?.cities?.count)! == cacheCount {
                self?.cities?.remove(at: cacheCount-1)
            }

            self?.cities?.insert(city.lowercased(), at: 0)
            UserDefaults.standard.set(self?.cities, forKey: key)
            return completion(true)
            
        }

    }


    func getAll() -> [String] {
        return cities ?? []
    }

}
