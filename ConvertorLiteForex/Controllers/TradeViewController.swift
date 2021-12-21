//
//  TradeViewController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 05.10.2021.
//

import UIKit
import WebKit
import JGProgressHUD

class TradeViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    let spinner = JGProgressHUD(style: .dark)
    
    private let webView: WKWebView = {
       let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        } else {
            
        }
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let url = "https://my.litefinance.com/ru/".localized()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Торговать".localized()
        view.addSubview(webView)
        spinner.show(in: view)
        
        guard let urlStrong = URL(string: url) else {
            return
        }
        
        webView.load(URLRequest(url: urlStrong))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.spinner.dismiss(animated: true)
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance // For iPhone small navigation bar in landscape.
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

}
