//
//  ViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let history = History()
    @IBOutlet weak var listTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather App"
        listTableView.tableFooterView = UIView(frame: .zero)
        listTableView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showDetailsScreen(forWeatherInfo info: WeatherInfo) {
        let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: DetailsViewController.identifier) as? DetailsViewController
        detailsVC?.info = info
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }

    func weather(forCity query: String) {

        WeatherInfo.fetchWeather(forCity: query) { [weak self] (weatherInfo) in

            guard let info = weatherInfo else {
                // Show alert
                return
            }

            if (self?.history.add(query))! {
                self?.listTableView.reloadData()
            }
            self?.showDetailsScreen(forWeatherInfo: info)
        }
    }
}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let city = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard (city?.characters.count)! > 0 else {
            // Show alert
            return
        }
        weather(forCity: city!)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        listTableView.isHidden = false
        listTableView.alpha = 0.0

        UIView.animate(withDuration: 0.5) {
            self.listTableView.alpha = 1.0
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        listTableView.isHidden = false
        listTableView.alpha = 1.0

        UIView.animate(withDuration: 0.5) {
            self.listTableView.alpha = 0.0
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Items"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.getAll().count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = history.getAll()[indexPath.row].capitalized
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        weather(forCity: history.getAll()[indexPath.row])
    }
}

