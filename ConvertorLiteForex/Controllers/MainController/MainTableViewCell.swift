//
//  MainTableViewCell.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 21.09.2021.
//

import UIKit
import SnapKit

protocol mainTableViewCellDelegate: AnyObject {
    func graphicCellDelegate(url: String)
}

class MainTableViewCell: UITableViewCell {
    static let indetifier = "MainTableviewCell"
    private let presenter = ManagerNetwork.shared
    
    var segueGraphic: (() -> Void)?
    
    weak var delegate: mainTableViewCellDelegate?
    
    var imageFlag: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    var calcImage: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "calc")
        return image
    }()
    
    var labelPrice: UILabel = {
       var number = UILabel()
        number.adjustsFontSizeToFitWidth = true
        number.adjustsFontForContentSizeCategory = true
        number.font = .systemFont(ofSize: 15)
        number.font = .boldSystemFont(ofSize: 15)
        return number
    }()
    
    var labelPriceUnder: UILabel = {
       var number = UILabel()
        number.adjustsFontSizeToFitWidth = true
        number.adjustsFontForContentSizeCategory = true
        number.font = .systemFont(ofSize: 13)
        return number
    }()
    
    var labelCurrency: UILabel = {
       let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    var secondaryCurrency: UILabel = {
       let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.font = .systemFont(ofSize: 16)
        label.layer.opacity = 0.5
        return label
    }()
    
    var arrowView: UIImageView = {
       let arrow = UIImageView()
        return arrow
    }()
    
    var arrowViewSecond: UIImageView = {
       let arrow = UIImageView()
        return arrow
    }()
    
    var graphicIcon: UIButton = {
       let icon = UIButton()
        icon.setImage(UIImage(named: "graph_icon"), for: .normal)
        //icon.addTarget(self, action: #selector(graphicDates), for: .touchUpInside)
        return icon
    }()
   

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(imageFlag)
        addSubview(labelCurrency)
        addSubview(labelPrice)
        addSubview(labelPriceUnder)
        addSubview(secondaryCurrency)
        addSubview(calcImage)
        addSubview(arrowView)
        addSubview(arrowViewSecond)
        addSubview(graphicIcon)
        layoutViewCell()
    }
    
    //MARK: формируется ссылка на график
   @objc func graphicDates() {
        let word1 = labelCurrency.text?.replacingOccurrences(of: " ", with: "")
        let word2 = secondaryCurrency.text?.replacingOccurrences(of: " / ", with: "")
        let url = "https://www.tradingview.com/chart/?symbol=FX_IDC%3A\(word1! + word2!)"
       print("click-click")
       if #available(iOS 14, *) {
           self.delegate?.graphicCellDelegate(url: url)
       } else {
           print("cu-cu")
       }
       
    }
   
    //MARK: конфигурация ячейки
    func basicConfigure(entryes: Entry, selected: String, selectedPrice: Double) {
        
        labelPrice.text = String(format: "%.4f", selectedPrice / entryes.price)
        labelPriceUnder.text = String(format: "%.4f", entryes.price / selectedPrice)
        
        imageFlag.image = UIImage(named: "flag_\(entryes.currency.lowercased())")
        labelCurrency.text = entryes.currency
        secondaryCurrency.text = " / " + selected
        let lastPriceInt = entryes.lastPrice
        let priceInt =  entryes.price
       
        
        //MARK: установка зеленой/красной стрелочки
        if lastPriceInt > priceInt {
            arrowView.image = UIImage(named: "currency_down")
        } else {
            arrowView.image = UIImage(named: "currency_up")
        }
    }
    
    //MARK: верстка
    private func layoutViewCell() {
        contentView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        imageFlag.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(contentView.frame.height * 0.8)
        }
    
        labelCurrency.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(imageFlag.snp_rightMargin).offset(20)
        }
        
        labelPrice.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.right.equalTo(calcImage.snp_leftMargin).offset(-60)
        }
        
        labelPriceUnder.snp.makeConstraints { make in
            make.top.equalTo(labelPrice.snp_bottomMargin).offset(10)
            make.right.equalTo(calcImage.snp_leftMargin).offset(-60)
        }
        
        secondaryCurrency.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(25)
            make.left.equalTo(labelCurrency.snp_rightMargin).offset(8)
        }
        
        calcImage.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        arrowView.snp.makeConstraints { make in
            make.width.equalTo(13)
            make.height.equalTo(9)
            make.top.equalTo(labelPrice).offset(4)
            make.right.equalTo(calcImage.snp_leftMargin).offset(-140)
        }
        
        arrowViewSecond.snp.makeConstraints { make in
            make.width.equalTo(13)
            make.height.equalTo(9)
            make.top.equalTo(arrowView).offset(21)
            make.right.equalTo(calcImage.snp_leftMargin).offset(-140)
        }
        
        graphicIcon.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(calcImage.snp_leftMargin).offset(-18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }

}
