//
//  ReusableProtocol.swift
//  WeatherApp
//
//  Created by Zeeshan Khan on 10/14/16.
//  Copyright © 2016 Zeeshan. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableCell: class {
    static var identifier: String { get }
}

extension ReusableCell  { // where Self: UIView
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell : ReusableCell {}

extension UIViewController : ReusableCell {}


protocol StatusBarNetworkActivityIndicator {
    static var showStatusBarNetworkActivityIndicator: Bool { get set }
}

extension StatusBarNetworkActivityIndicator {

    static var showStatusBarNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
}

extension UITableView {

    final func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath, cellType: T.Type = T.self) -> T where T: ReusableCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.identifier) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
}

