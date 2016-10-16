//
//  HistoryStore.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/15/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation

private let key = "WeatherAppSearchHistory"

class History {

    let cacheCount = 10
    private var cities = UserDefaults.standard.stringArray(forKey: key)

    
    @discardableResult func add(_ city: String) -> Bool {

        if cities == nil {
            cities = [String]()
        }

        if (cities?.count)! > 0 && (cities?.contains(city.lowercased()))! {
            return false
        }

        if cities?.count == cacheCount {
            cities?.remove(at: cacheCount-1)
        }

        cities?.insert(city.lowercased(), at: 0)
        UserDefaults.standard.set(cities, forKey: key)
        return true
    }

    func getAll() -> [String] {
        if cities == nil {
            cities = [String]()
        }
        return cities! 
    }
}
