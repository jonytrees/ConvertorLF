//
//  FilterViewController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 05.10.2021.
//

import UIKit
import JGProgressHUD
import SnapKit

protocol filterViewControllerDelegate: AnyObject {
    func filterVuewControllerDefaults(entryes: [Entry])
}

final class FilterViewController: XMLExtension, Storyboarded {
    
    
    weak var coordinator: MainCoordinator?
    
    private var parseEntryes = [Entry]()
    private var results = [Entry]()
    var spinner = JGProgressHUD(style: .dark)
    private let presenter = ManagerNetwork.shared
    let searchController = UISearchController(searchResultsController: nil)
    let searchBar = UISearchBar()
    weak var delegate: filterViewControllerDelegate?
    //private let mainVC = MainViewController()
    
    private let tableView: UITableView = {
       let table = UITableView()
       
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let imageSelected: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "flag_usd")
        image.backgroundColor = .green
        image.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return image
    }()
    
    private let choiceView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(red: 1/255.0, green: 101/255.0, blue: 56/255.0, alpha: 1)
        return view
    }()
    
    private let defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "По умолчанию".localized()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.addTarget(self, action: #selector(cancelButtonCurrency), for: .touchUpInside)
        return button
    }()
    
    private let checkButton: UIButton = {
       let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(checkButtonCurrency), for: .touchUpInside)
        return button
    }()
    
   
    //MARK: отменяет выбранные валюты
    @objc func cancelButtonCurrency() {
        results.removeAll()
        results.append(parseEntryes[0])
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: выбирает все валюты
    @objc func checkButtonCurrency() {
        results.removeAll()
       results = parseEntryes
    
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильтр".localized()
        view.addSubview(tableView)
        view.addSubview(choiceView)
        choiceView.addSubview(defaultLabel)
        choiceView.addSubview(cancelButton)
        choiceView.addSubview(checkButton)
        view.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        tableView.frame = view.bounds
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance
        
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.setValue("Отмена".localized(), forKey: "cancelButtonText")
        
        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Найти валюту...".localized(), attributes: attributeDict)
            searchTextField?.backgroundColor = UIColor(red: 1/255.0, green: 101/255.0, blue: 56/255.0, alpha: 1)
        }
        
        parseEntryes = UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue)
        results = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
        layoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserProfileCache.save(results, key: KeyUserDefaults.key.rawValue)
        presenter.entryes = results
       // print("filter: \(parseEntryes)")
        //delegate?.filterVuewControllerDefaults(entryes: results)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        layoutSubviews()
    }
    
    //MARK: верстка
    func layoutSubviews() {
        tableView.contentInset.bottom = 80.0
        
        choiceView.snp.makeConstraints { make in
            make.width.equalTo(view.bounds.size.width)
            make.height.equalTo(100)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.bottom.equalTo(view).offset(0)
        }
        
        defaultLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(choiceView).offset(20)
            make.centerX.equalTo(choiceView)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.left.equalTo(view).offset(20)
            make.top.equalTo(choiceView).offset(30)
        }
        
        checkButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(choiceView).offset(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(80)
        }
    }
}



extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseEntryes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        cell.textLabel?.text = parseEntryes[indexPath.row].currency
        let item = parseEntryes[indexPath.row]
        
        
        //MARK: отображает галочку
        if !results.isEmpty {
            results.forEach{
                 if $0.currency == item.currency {
                     cell.accessoryType = .checkmark
               }
             }
        } else {
            //UserProfileCache.get(key: KeyUserDefaults.key.rawValue).forEach{
             //   if $0.currency == item.currency {
             //       cell.accessoryType = .checkmark
             //   }
            //}
        }
      
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //results.removeAll()
        
        //MARK: работа с галочками
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            
            //results = results.filter{$0.currency != parseEntryes[indexPath.row].currency}
            //presenter.entryes = results.filter{$0.currency != parseEntryes[indexPath.row].currency}
            results = results.filter{$0.currency != parseEntryes[indexPath.row].currency}
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
           // results.append(parseEntryes[indexPath.row])
            //presenter.entryes.append(results[indexPath.row])
            results.append(parseEntryes[indexPath.row])
        }
        print("count results: \(results.count)")
    }
}

extension FilterViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.uppercased(), !text.replacingOccurrences(of: "", with: "").isEmpty else {
            return
        }
        
        //parseEntryes.removeAll()
        let searchEntryes = presenter.search(query: text, entryes: UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue))
        
        if searchEntryes.isEmpty {
            
            let alert = UIAlertController(title: "Ничего не найдено", message: "", preferredStyle: .alert)
            
            let alertOK = UIAlertAction(title: "OK".localized(), style: .cancel)
            
            alert.addAction(alertOK)
            
            present(alert, animated: true)
            
            searchBar.text = ""
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            parseEntryes = searchEntryes
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        parseEntryes = UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
