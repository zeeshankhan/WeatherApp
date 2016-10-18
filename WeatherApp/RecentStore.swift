//
//  RecentStore.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/17/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    dynamic var city = ""
}

protocol Recent {
    func add(_ city: String) -> Bool;
    var all: [Item]  { get }
}

struct Store : Recent {

    let cacheCount = 3
    let realm = try! Realm()
    var all: [Item] {
        get {
            return realm.objects(Item.self).map({ $0 })
        }
    }

    @discardableResult func add(_ city: String) -> Bool {

        guard city.characters.count > 0 else {
            return false
        }

        let predicate = NSPredicate(format: "city = %@", city)
        let items = realm.objects(Item.self).filter(predicate)
        guard items.count == 0 else {
            return false
        }

        let allCities = all
        if allCities.count == cacheCount {
            let item = allCities[cacheCount-1]

            try! realm.write {
                realm.delete(item)
            }
        }

        try! realm.write {
            let item = Item()
            item.city = city
            realm.add(item)
        }
        return true;
    }


}
