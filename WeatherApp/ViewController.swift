//
//  ViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather App"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func showDetailsScreen(forWeatherInfo info: WeatherInfo) {
        let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: DetailsViewController.identifier) as? DetailsViewController
        detailsVC?.info = info
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }

}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let city = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces)

        if (city?.characters.count)! > 0 {

            WeatherInfo.fetchWeather(forCity: city!) { (weatherInfo) in

                guard let info = weatherInfo else {
                    // Show alert
                    return
                }

                self.showDetailsScreen(forWeatherInfo: info)
            }

        }
        else {
            // Show alert
        }

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }

//    func tableView(_varbleView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = "Recent"
        cell.textLabel?.numberOfLines = 0

        return cell
    }
}

