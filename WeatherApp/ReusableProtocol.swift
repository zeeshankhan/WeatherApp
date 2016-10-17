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

