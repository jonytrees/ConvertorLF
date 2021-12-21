//
//  MainCoordinator.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 17.11.2021.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let vc = MainViewController.instantiate()
        vc.coordinator = self
        vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Конвертер".localized(), style: .plain, target: nil, action: nil)
        vc.navigationItem.backBarButtonItem?.tintColor = .white
        navigationController.pushViewController(vc, animated: true)
    }
    
    @available(iOS 14.0, *)
    func traderSubscription() {
        let vc = TradeViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func registerSubscrption() {
        let vc = RegistrationViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func filterSubscription(delegate: filterViewControllerDelegate) {
        let vc = FilterViewController.instantiate()
        vc.coordinator = self
        vc.delegate = delegate
        navigationController.pushViewController(vc, animated: true)
    }
    @available(iOS 14.0, *)
    
    func graphicSubscription(url: String) {
        let vc = GraphicViewController.instantiate()
        vc.coordinator = self
        vc.url = url
        navigationController.pushViewController(vc, animated: true)
    }
    
}
