//
//  Extensions.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 05.10.2021.
//

import Foundation
import UIKit

class XMLExtension: UIViewController, XMLParserDelegate {
   
    var currency = String()
    var price = String()
    var date = String()
    var lastPrice = String()
    var elementName: String = String()
    var table = UITableView()
    var entryes = [Entry]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: парсинг данных из XML
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "entry" {
            currency = String()
            price = String()
            date = String()
            lastPrice = String()
        }
        self.elementName = elementName
    }

    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
       
        if elementName == "entry" {
            
            let entry = Entry(currency: currency, price: Double(price)!, date: date, lastPrice: Double(lastPrice)!)
            if entry.currency != "BTC" && entry.currency != "GGP" && entry.currency != "IMP" && entry.currency != "JEP" && entry.currency != "MRU" && entry.currency != "SSP" && entry.currency != "STN" && entry.currency != "VES" && entry.currency != "XAG" && entry.currency != "XAU" && entry.currency != "XDR" && entry.currency != "XPD" && entry.currency != "XPT" {
                ManagerNetwork.shared.entryes.append(entry)
                //ManagerNetwork.shared.doubleEntryes.append(entry)
            }
            
           
        }
  
        UserProfileCache.save(ManagerNetwork.shared.entryes, key: KeyUserDefaults.key.rawValue)
        UserProfileCache.save(ManagerNetwork.shared.doubleEntryes, key: KeyUserDefaults.doubleKey.rawValue)
       
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }

    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
      
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            if self.elementName == "currency" {
                currency += data
            } else if self.elementName == "price" {
                price += data
            } else if self.elementName == "date" {
                date += data
            } else if self.elementName == "last_price" {
                lastPrice += data
            }
        }
    }
}


extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
