//
//  ViewController.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let recent = Store()
    let hideRecentItems = false
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather App"
        listTableView.tableFooterView = UIView(frame: .zero)
        listTableView.isHidden = hideRecentItems
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
        searchBar.resignFirstResponder()

        WeatherInfo.fetchWeather(forCity: query) { [weak self] (result) in

            switch result {

                case .success(let info):

                    if (self?.recent.add(query))! {
                        self?.listTableView.reloadData()
                    }

                    self?.showDetailsScreen(forWeatherInfo: info!)

                case .failure(let err):

                    switch err {
                        case .notFound(let msg):
                            self?.showAler(message: msg)
                        case .other(let msg):
                            print(msg)
                    }
            }
        }
    }

    func showAler(message: String) {

        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let city = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard (city?.characters.count)! > 0 else {
            showAler(message: "Please enter city name.")
            return
        }
        weather(forCity: city!)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        if recent.all.count > 0 && hideRecentItems {
            listTableView.isHidden = false
            listTableView.alpha = 0.0

            UIView.animate(withDuration: 0.5) {
                self.listTableView.alpha = 1.0
            }
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        if hideRecentItems {
            listTableView.isHidden = false
            listTableView.alpha = 1.0

            UIView.animate(withDuration: 0.5) {
                self.listTableView.alpha = 0.0
            }
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
}


extension ViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Items"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recent.all.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath, cellType: UITableViewCell.self)
        cell.textLabel?.text = recent.all[indexPath.row].city.capitalized
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        weather(forCity: recent.all[indexPath.row].city)
    }
}

