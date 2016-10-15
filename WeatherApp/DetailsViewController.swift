//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

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

enum CellType {
    case image
    case info

    var height : CGFloat {
        get {
            switch(self) {
                case .image: return 104.0
                case .info: return 60.0
            }
        }
    }

    var identifier : String {
        get {
            switch(self) {
                case .image: return "ImageTableViewCell"
                case .info: return "InfoTableViewCell"
            }
        }
    }

}

protocol TableRowItem {
    var cellType: CellType { get }
    var item: WeatherItem { get }
}

private struct InfoRowItem : TableRowItem {
    let cellType: CellType
    let item: WeatherItem
}

struct ImageRowItem : TableRowItem {
    let cellType: CellType
    let item: WeatherItem
    let image: WeatherItem
}


struct RowItem {
    let cellType: CellType
    let urlString: String
    let title: String
    let desc: String
}


class DetailsViewController: UIViewController {

    var info: WeatherInfo? = nil
    lazy var tableItems: [RowItem] = {
        return self.populateTableItems()
    }()

    func populateTableItems() -> [RowItem] {

        var items: [RowItem] = []

        let imgUrlStrin = WeatherItem.icon.itemValue(info!)
        let imageItem = RowItem(cellType: .image, urlString: imgUrlStrin, title: WeatherItem.icon.description, desc: WeatherItem.city.itemValue(info!))
//        let imageItem = ImageRowItem(cellType: .image, item: .city, image: .icon)

        items.append(imageItem)

        let timeItem = RowItem(cellType: .info, urlString: "", title: WeatherItem.observationTime.description, desc: WeatherItem.observationTime.itemValue(info!))
        items.append(timeItem)

        let humidItem = RowItem(cellType: .info, urlString: "", title: WeatherItem.humidity.description, desc: WeatherItem.humidity.itemValue(info!))
        items.append(humidItem)

        let descItem = RowItem(cellType: .info, urlString: "", title: WeatherItem.weatherDescription.description, desc: WeatherItem.weatherDescription.itemValue(info!))
        items.append(descItem)

        return items
    }

    @IBOutlet weak var detailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        detailsTableView.tableFooterView = UIView(frame: .zero)

        addRefreshControl()
    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDetails(_:)), for: .valueChanged)
        detailsTableView.addSubview(refreshControl)
    }

    func refreshDetails(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension DetailsViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count;
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = tableItems[indexPath.row]
        return item.cellType.height
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let rowItem = tableItems[indexPath.row]

        switch rowItem.cellType {

            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as! ImageTableViewCell
                cell.populateImageCell(forItem: rowItem)
                return cell


            case .info:
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as! InfoTableViewCell
                cell.populateCell(forItem: rowItem)
                return cell

        }
    }
}


class ImageTableViewCell : UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    func populateImageCell(forItem item: RowItem) {

        self.cityLabel.text = item.desc

        DispatchQueue.global().async { [weak self] () -> Void in

            guard let url = URL(string: item.urlString) else {
                print("Icon URL is nil.")
                return
            }

            guard let imgData = try? Data(contentsOf: url) else {
                print("Icon data is nil.")
                return
            }

            DispatchQueue.main.async {
                self?.iconImageView.image = UIImage(data: imgData)
            }
        }
    }
}

class InfoTableViewCell : UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    func populateCell(forItem item: RowItem) {
        self.titleLabel.text = item.title
        self.detailLabel.text = item.desc
    }
}

