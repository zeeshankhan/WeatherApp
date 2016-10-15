//
//  HistoryStore.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/15/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation

struct History {

    private var cities = UserDefaults.standard.array(forKey: "")

    mutating func addToHistory(_ city: String) {
        cities?.insert(city, at: 0)
    }

    func history() -> [Any] {
        return []
    }
}
