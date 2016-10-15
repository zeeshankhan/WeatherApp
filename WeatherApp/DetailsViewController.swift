//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import UIKit

enum CellType : Int {

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

    func value(_ info: WeatherInfo) -> String {
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
        while let _ = CellType(rawValue: max) { max += 1 }
        return max
    }()
}

struct RowItem {

    let title: String
    let observationTime: String


}

class DetailsViewController: UIViewController {

    var info: WeatherInfo? = nil

    @IBOutlet weak var detailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        detailsTableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension DetailsViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.count;
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = CellType(rawValue: indexPath.row)?.description
        cell.detailTextLabel?.text = CellType(rawValue: indexPath.row)?.value(info!)
        cell.textLabel?.numberOfLines = 0

        return cell
    }
}


class DetailsTableViewCell : UITableViewCell {}

