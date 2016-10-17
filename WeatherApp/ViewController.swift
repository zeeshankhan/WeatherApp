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
    let hideRecentItems = false
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather App"
        listTableView.tableFooterView = UIView(frame: .zero)
        listTableView.isHidden = hideRecentItems
        showHUD(false)
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
        showHUD(true);
        WeatherInfo.fetchWeather(forCity: query) { [weak self] (result) in

           self?.showHUD(false);

            switch result {

                case .success(let info):

                    self?.history.add(query, completion: { result in
                        if result == true {
                            self?.listTableView.reloadData()
                        }
                    })

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

    func showHUD(_ shouldShow: Bool) {
        msgLabel.isHidden = !shouldShow
        indicator.isHidden = !shouldShow
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

        if history.getAll().count > 0 && hideRecentItems {
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
        return history.getAll().count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = history.getAll()[indexPath.row].capitalized
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        weather(forCity: history.getAll()[indexPath.row])
    }
}

