//
//  MenuController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 24.09.2021.
//

import UIKit

class Section {
    let title: String
    let options: [String]
    var isOpen = true
    
    init(title: String, options: [String], isOpen: Bool = true) {
        self.title = title
        self.options = options
        self.isOpen = isOpen
    }
}

class MenuController: UITableViewController {
    
    public var delegate: MenuControllerDelegate?
    //private var sections = [Section]()
    
    private var image: UIImage = {
       let image = UIImage()
        
        return image
    }()
    
    private let menuItems: [SideMenuItem]
    private let iconItems: [ImageMenuItem]
    private let color = UIColor(red: 217/255.0, green: 217/255.0, blue: 219/255.0, alpha: 1)
    
    init(with menuItems: [SideMenuItem], iconItems: [ImageMenuItem]) {
        self.menuItems = menuItems
        self.iconItems = iconItems
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = color
        view.backgroundColor = color
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
//        sections = [
//            Section(title: "", options: ["Справка"]),
//            Section(title: "Веб", options: ["Торговать", "Регистрация"]),
//            Section(title: "Настройки", options: ["Автообновление", "Фильтр", "О программе"])
//        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
//        let section = sections[section]
//
//        if section.isOpen {
//            return section.options.count + 1
//        } else {
//            return 1
//        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = color
        cell.contentView.backgroundColor = color
        
        
//        if indexPath.row == 0 {
//            cell.textLabel?.text = sections[indexPath.section].title
//            cell.backgroundColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
//            cell.textLabel?.textColor = .white
//
//        } else {
//            cell.textLabel?.text = sections[indexPath.section].options[indexPath.row - 1]
//            cell.contentView.backgroundColor = color
//        }
        //cell.imageView?.image = row[indexPath.row].icon
       // cell.textLabel?.text = customRow[indexPath.row].title
        cell.textLabel?.text = menuItems[indexPath.row].rawValue.localized()
        cell.imageView?.image = UIImage(systemName: iconItems[indexPath.row].rawValue)
        cell.imageView?.tintColor = UIColor(red: 1/255.0, green: 144/255.0, blue: 79/255.0, alpha: 1)
        return cell
        
        
    }
    
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //if indexPath.row == 0 {
            let selectedItem = menuItems[indexPath.row]
            delegate?.didSelectMenuItem(name: selectedItem)
            //sections[indexPath.section].isOpen = !sections[indexPath.section].isOpen
            //tableView.reloadSections([indexPath.section], with: .none)
        //} else {
        //    print("tapped sub cell")
        //}
    }

    
}
