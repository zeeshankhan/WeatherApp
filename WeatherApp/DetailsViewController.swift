//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import UIKit


class DetailsViewController: UIViewController {

    var info: WeatherInfo? = nil
    @IBOutlet weak var detailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        detailsTableView.tableFooterView = UIView(frame: .zero)
        addRefreshControl()
    }

    lazy var tableItems: [TableRowItem] = {
        return self.populateTableItems()
    }()

    func populateTableItems() -> [TableRowItem] {

        var items: [TableRowItem] = []

        let imageItem = ImageRowItem(.city, image: .icon)
        items.append(imageItem)

        let timeItem = InfoRowItem(.observationTime)
        items.append(timeItem)

        let humidItem = InfoRowItem(.humidity)
        items.append(humidItem)

        let descItem = InfoRowItem(.weatherDescription)
        items.append(descItem)
        
        return items
    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDetails(_:)), for: .valueChanged)
        detailsTableView.addSubview(refreshControl)
    }

    func refreshDetails(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()

//        guard let city = info?.city else {
//            return
//        }
//
//        do {
//            try WeatherInfo.fetchWeather(forCity: city, completion: { [weak self] (weather) in
//                self?.info = weather
//                self?.detailsTableView.reloadData()
//            })
//        }
//        catch {
//
//        }

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
                let valueItem = rowItem as! ImageRowItem
                cell.cityLabel.text = (info?.tempC)! + "℃ / " + (info?.tempF)! + "℉\n" + valueItem.item.itemValue(info!)
                cell.populateImage(fromPath: valueItem.image.itemValue(info!))
                return cell


            case .info:
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as! InfoTableViewCell
                cell.titleLabel.text = rowItem.item.description
                cell.detailLabel.text = rowItem.item.itemValue(info!)
                return cell

        }
    }
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
    let cellType: CellType = .info
    let item: WeatherItem

    init(_ item: WeatherItem) {
        self.item = item
    }
}

struct ImageRowItem : TableRowItem {
    let cellType: CellType = .image
    let item: WeatherItem
    let image: WeatherItem

    init(_ item: WeatherItem, image: WeatherItem) {
        self.item = item
        self.image = image
    }
    
}


class ImageTableViewCell : UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    func populateImage(fromPath path: String) {

        DispatchQueue.global().async { [weak self] () -> Void in

            guard let url = URL(string: path) else {
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
}

