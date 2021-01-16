//
//  UIViewController.swift
//  FilmMakers
//
//  Created by Adrian Tineo on 10.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var isOnScreen: Bool {
        return isViewLoaded && view.window != nil
    }
}
