//
//  GraphicViewController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 12.11.2021.
//

import UIKit
import WebKit
import JGProgressHUD


class GraphicViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    private let tableView = UITableView()
    let cell = MainTableViewCell()
    private let spinner = JGProgressHUD(style: .dark)
    
    private let webView: WKWebView = {
       let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    var url: String = ""
    
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "График".localized()
        view.addSubview(webView)
        spinner.show(in: self.view)
        guard let urlString = URL(string: url) else {
            return
        }
        
        self.webView.load(URLRequest(url: urlString))
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

}
