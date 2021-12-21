//
//  ManagerNetwork.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 05.10.2021.
//

import Foundation
import UIKit


class ManagerNetwork {
    static let shared = ManagerNetwork()
   
    let userDefault = UserDefaults()
   
    //var entryes = UserProfileCache.get()
    var entryes = [Entry]()
    var checkedEntryPrice: Double = 1.0
    var doubleEntryes = [Entry]()
    var checkedEntryes = [Entry]()
    var filterEntryes = [Entry]()
    
    private init() {}
    
    let urlString = "https://api.clawshorns.com/yahooquotes?token=f984357eab59537962aab2cc190a7fe3"
    
    var urlGraphic = ""
    
    
    //MARK: Парсинг данных
    public func getDataParse(table: UITableView, controller: XMLExtension, completion: @escaping (Result<[Entry], Error>) -> Void) {
         if table.refreshControl?.isRefreshing == true {
             print("refreshing data")
         } else {
             print("parsing data")
         }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let parser = XMLParser(data: data)
                     parser.delegate = controller.self
                    
                    
                    if parser.parse() {
                        print("true")
                    }
                    
                    let encoder = JSONEncoder()
                    
//                    if let encoded = try? encoder.encode(self.entryes) {
//                        UserDefaults.standard.set(encoded, forKey: "save")
//                    }
                    //UserProfileCache.save(self.entryes)
                   
                    completion(.success(UserProfileCache.get(key: KeyUserDefaults.key.rawValue)))
                    
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
        
        DispatchQueue.main.async {
            table.refreshControl?.endRefreshing()
            controller.table.reloadData()
            table.reloadData()
        }
    }
    
    //MARK: поиск по массиву
    func search(query: String, entryes: [Entry]) -> [Entry] {
        var searchEntryes = [Entry]()
        searchEntryes = entryes.filter{ $0.currency == query }
        return searchEntryes
    }
    
    
    
    //MARK: фильтр массива на основе выбранной валюты
    func selectedUpdateTableView(selecter: String, table: UITableView, entryes: [Entry]) -> [Entry] {
        var entryesBasic = [Entry]()
       
        let basic = UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue).filter { item in
            item.currency == selecter
        }
        print("basic: \(basic)")
        
        checkedEntryPrice = basic[0].price
        print("checked: \(checkedEntryPrice)")
           
        let filterEntryes = UserProfileCache.get(key: KeyUserDefaults.key.rawValue)
//        entryesBasic = UserProfileCache.get(key: KeyUserDefaults.doubleKey.rawValue).filter({ item in
//            item.currency != selecter
//        })
        
        entryesBasic = filterEntryes.filter({ item in
            item.currency != selecter
        })
        
       // UserProfileCache.save(entryesBasic, key: KeyUserDefaults.key.rawValue)
        
        DispatchQueue.main.async {
            table.reloadData()
        }
        
        return entryesBasic
   }
    
    
    
}






