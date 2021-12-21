//
//  Coordinator.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 17.11.2021.
//

import Foundation
import UIKit


protocol Coordinator {
    var childCoordinators: [Coordinator] {get set}
    var navigationController: UINavigationController {get set}
    
    func start()
}
