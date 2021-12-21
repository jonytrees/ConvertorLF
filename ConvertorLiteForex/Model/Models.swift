//
//  Models.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 12.10.2021.
//

import Foundation
import CoreText


enum SideMenuItem: String, CaseIterable {
    case trade = "Торговать"
    case registration = "Регистрация"
    case filter = "Фильтр"
   
}

enum ImageMenuItem: String, CaseIterable {
    case tradeIcon = "dollarsign.circle"
    case registrationIcon = "person.crop.circle"
    case filterIcon = "slider.horizontal.below.rectangle"
}

struct Entry: Codable {
    var currency: String
    var price: Double
    var date: String
    var lastPrice: Double
}

enum KeyUserDefaults: String {
    case key = "key"
    case doubleKey = "doublekey"
    case currency = "currency"
    case imageCurrency = "image"
}


struct UserProfileCache {
    static let key = "userProfileCache"
    static let doubleKey = "doubleEntryes"
    static let keyCurrency = "currencySelected"
    static let imageCurrency = "imageSelected"
    
    static func save(_ value: [Entry]!, key: String) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
        
    }
   
    
    static func saveSelectedCurrency(currency: String, image: String) {
        UserDefaults.standard.set(currency, forKey: keyCurrency)
        UserDefaults.standard.set(image, forKey: imageCurrency)
    }
    
    static func get(key: String) -> [Entry] {
        var userData = [Entry]()
        
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try! PropertyListDecoder().decode([Entry].self, from: data)
            return userData
        } else {
            return userData
        }
        
//        if let saved = UserDefaults.standard.object(forKey: key) as? Data {
//            let decoder = JSONDecoder()
//
//            if let loaded = try? decoder.decode([Entry].self, from: saved) {
//                userData = loaded
//            }
//        }
        //return userData
    }
    
    static func getSelectedCurrency() -> String {
        //return UserDefaults.standard.value(forKey: keyCurrency) as! String
        return "cur"
    }
    
    static func getSelectedImage() -> String {
       // return UserDefaults.standard.value(forKey: imageCurrency) as! String
        return "img"
    }
    
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
