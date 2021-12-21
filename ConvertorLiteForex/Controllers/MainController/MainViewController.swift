//
//  ViewController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 21.09.2021.
//

import UIKit
import SideMenu
import SnapKit
import JGProgressHUD
import BLTNBoard


protocol MenuControllerDelegate {
    func didSelectMenuItem(name: SideMenuItem)
}


final class MainViewController: XMLExtension, MenuControllerDelegate, Storyboarded {
    
    private let refreshControl = UIRefreshControl()
    private var entryesBasic = [Entry]()
    weak var coordinator: MainCoordinator?
    private var parseEntryes = ManagerNetwork.shared.entryes
    private var currencyAlert = [String]()
    private var selectedCurrency = "USD"
    private var sideMenu: SideMenuNavigationController?
    private let offsetItem: CGFloat = 60.0
    private let presenter = ManagerNetwork.shared
    private let spinner = JGProgressHUD(style: .dark)
    //private let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
    //private let filterController = FilterViewController()
    var urlGraphic = ""
   
    private let boardField: UITextField = {
       let field = UITextField()
        return field
    }()
    
    private let labelView: UILabel = {
       let label = UILabel()
        label.text = "Выберите валюту:".localized()
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        return view
    }()
    
    private let imageFlagHeaderView: UIImageView = {
       let image = UIImageView()
        return image
    }()
    
    private let buttonCurrent: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        button.setTitle("USD", for: .normal)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(selectCurrencyFunc), for: .touchUpInside)
        return button
    }()
  
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.indetifier)
        return table
    }()
    
    let pickerView: UIPickerView = {
       let picker = UIPickerView()
        picker.backgroundColor = UIColor(red: 214/255, green: 217/255, blue: 217/255, alpha: 1)
        return picker
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Конвертер валют".localized()
        
        //UserProfileCache.saveSelectedCurrency(currency: "USD", image: "flag_usd")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(replayFunc), for: .valueChanged)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        imageFlagHeaderView.image = UIImage(named: "flag_usd")
        searchController.searchBar.delegate = self
        
        let menu = MenuController(with: SideMenuItem.allCases, iconItems: ImageMenuItem.allCases)
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        if #available(iOS 10, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        refreshControl.removeFromSuperview()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(menuFunc))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "goforward"),
                                                           // style: .done,
                                                           // target: self,
                                                           // action: #selector(replayFunc))
        navigationItem.rightBarButtonItem?.tintColor = .white
       
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationController!.navigationBar.barStyle = .default
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
      
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
        
        
        view.addSubview(tableView)
        view.addSubview(headerView)
        headerView.addSubview(labelView)
        headerView.addSubview(buttonCurrent)
        headerView.addSubview(imageFlagHeaderView)

   
        fetchData()
       
    }
    
    
    @objc func refreshWeatherData() {
        spinner.show(in: view)
        spinner.dismiss(afterDelay: 1.0)
        spinner.dismiss(animated: true)
    }
    
    
    //MARK: запуск парсинга данных
    private func fetchData() {
        
        if UserProfileCache.get(key: KeyUserDefaults.key.rawValue).isEmpty {
            presenter.getDataParse(table: tableView, controller: self) { result in
                switch result {
                case .success(let entry):
                    self.presenter.entryes = entry
                    self.entryesBasic = entry
                    self.presenter.doubleEntryes = entry
                    UserProfileCache.save(entry, key: KeyUserDefaults.key.rawValue)
                    UserProfileCache.save(entry, key: KeyUserDefaults.doubleKey.rawValue)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    //MARK: обновление данных на экране
    @objc func replayFunc() {
        spinner.show(in: self.view)
        fetchData()
        spinner.dismiss(afterDelay: 1.0)
        tableView.reloadData()
    }
    
    
    //MARK: открывает боковое меню
    @objc func menuFunc() {
        present(sideMenu!, animated: true)
    }
    
    
    //MARK: алерт со всеми валютами
    @objc func selectCurrencyFunc() {
        let alertController = UIAlertController(title: "Выберите валюту:".localized(), message: "", preferredStyle: .alert)
        
        let alertOK = UIAlertAction(title: "OK", style: .default) { _ in
            
            self.buttonCurrent.setTitle(self.selectedCurrency, for: .normal)
            
            
            var flagEntry = UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue).filter { item in
                item.currency == self.selectedCurrency
            }
            
            if flagEntry.isEmpty {
                flagEntry = [Entry(currency: "USD", price: 0.0, date: "", lastPrice: 0.0)]
                self.buttonCurrent.setTitle(flagEntry[0].currency, for: .normal)
            }
            
            let flagImage = "flag_\(flagEntry[0].currency.lowercased())"
            self.imageFlagHeaderView.image = UIImage(named: flagImage)
            
           // UserProfileCache.saveSelectedCurrency(currency: self.selectedCurrency, image: flagEntry[0].currency)
            let updateEntryes = self.presenter.selectedUpdateTableView(selecter: flagEntry[0].currency, table: self.tableView, entryes: UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue))
            UserProfileCache.save(updateEntryes, key: KeyUserDefaults.key.rawValue)
            self.presenter.entryes = updateEntryes
        }
        
        let alertCancel = UIAlertAction(title: "Отмена".localized(), style: .cancel)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
        
        alertController.view.addConstraint(height)
        
        for item in 0...UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue).count - 1 {
            currencyAlert.append(UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue)[item].currency)
        }
        
        
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        alertController.view.addSubview(pickerView)
        
        present(alertController, animated: true, completion: {
            self.pickerView.frame = CGRect(x: 0, y: 50, width: alertController.view.frame.size.width, height: alertController.view.frame.size.height - 90)
        })
    }
    
    
    //MARK: верстка
    private func layoutUpdate() {
        tableView.contentInset.top = offsetItem
        
        let height = CGFloat((navigationController?.navigationBar.frame.height)!)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(height).offset(0)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.size.equalTo(CGSize(width: view.frame.size.width, height: 62))
        }
        
        buttonCurrent.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.right.equalTo(headerView).inset(15)
            make.size.equalTo(CGSize(width: view.frame.width / 6, height: 40))
        }
        
        labelView.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.left.equalTo(headerView).offset(20)
            make.size.equalTo(CGSize(width: view.frame.width / 2, height: 30))
        }
        
        imageFlagHeaderView.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.right.equalTo(buttonCurrent.snp_leftMargin).offset(-20)
            make.size.equalTo(CGSize(width: view.frame.width / 6, height: 37))
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
        layoutUpdate()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //entryesBasic = presenter.entryes
        //presenter.entryes = UserProfileCache.get()
        tableView.reloadData()
    }
    
 
    //MARK: переходы между контроллерами
    func didSelectMenuItem(name: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)
        
        switch name {
            
        case .trade:
            if #available(iOS 14.0, *) {
                coordinator?.traderSubscription()
            } else {
                let traderVC = TradeViewController()
                navigationController?.pushViewController(traderVC, animated: true)
            }
            
        case .registration:
            coordinator?.registerSubscrption()
            
        case .filter:
            coordinator?.filterSubscription(delegate: self)
        }
    }
    
}



extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
        return defaults.count
        
        //return entryesBasic.count
    }
    
    @objc func simpleFunc() {
        if #available(iOS 14.0, *) {
            coordinator?.graphicSubscription(url: urlGraphic)
        } else {
           let graphicVC = GraphicViewController(url: urlGraphic)
            navigationController?.pushViewController(graphicVC, animated: true)
        }
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.indetifier, for: indexPath) as! MainTableViewCell
        let defaults = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
      
        cell.basicConfigure(entryes: defaults[indexPath.row], selected: selectedCurrency, selectedPrice: presenter.checkedEntryPrice)
        cell.graphicIcon.addTarget(self, action: #selector(simpleFunc), for: .touchUpInside)
        
        let massEntryes = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)[indexPath.row].currency
        
        urlGraphic = "https://www.tradingview.com/chart/?symbol=FX_IDC%3A\(massEntryes + selectedCurrency)"
        
        if #available(iOS 14.0, *) {
            cell.delegate = self
        } else {
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let getEntryes = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
        let getSelected = UserProfileCache.getSelectedCurrency()
        let vc = PopUpViewController(firstImage: getEntryes[indexPath.row].currency, secondImage: selectedCurrency, valueCurrency: getEntryes[indexPath.row].price)
        present(vc, animated: true, completion: nil)
    }
    
    
}

//MARK: параметры для списка валют в алерте
extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyAlert[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        selectedCurrency = currencyAlert[row] as String
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: currencyAlert[row] as String, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        return attributedString
    }
}


//MARK: поиск валюты
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.uppercased(), !text.replacingOccurrences(of: "", with: "").isEmpty else {
            return
        }
        //let basicEntryes = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
        
        //entryesBasic.removeAll()
        let searchEntryes = presenter.search(query: text, entryes: UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue))
        //print(presenter.doubleEntryes.count)
        if searchEntryes.isEmpty {
            
            let alert = UIAlertController(title: "Ничего не найдено", message: "", preferredStyle: .alert)
            
            let alertOK = UIAlertAction(title: "OK", style: .cancel)
            
            alert.addAction(alertOK)
            
            present(alert, animated: true)
            //entryesBasic = presenter.doubleEntryes
            UserProfileCache.save(self.presenter.entryes, key: KeyUserDefaults.key.rawValue)
            searchBar.text = ""
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            UserProfileCache.save(searchEntryes, key: KeyUserDefaults.key.rawValue)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       // print("entry cancel: \(presenter.entryes.count)")
        UserProfileCache.save(UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue), key: KeyUserDefaults.key.rawValue)
        //print("entry cancel basic: \(entryesBasic.count)")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainViewController: filterViewControllerDelegate {
    func filterVuewControllerDefaults(entryes: [Entry]) {
        //UserProfileCache.save(entryes)
    }
}



extension MainViewController: mainTableViewCellDelegate {
    func graphicCellDelegate(url: String) {
        if #available(iOS 14.0, *) {
            coordinator?.graphicSubscription(url: url)
        } else {
            //let graphicVC = GraphicViewController(url: url)
            //navigationController?.pushViewController(graphicVC, animated: true)
            //present(graphicVC, animated: true)
            print("click")
        }
    }
}


