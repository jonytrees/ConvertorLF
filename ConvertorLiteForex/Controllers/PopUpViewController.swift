//
//  PopUpViewController.swift
//  ConvertorLiteForex
//
//  Created by Евгений Янушкевич on 15.10.2021.
//

import UIKit
import SnapKit

class PopUpViewController: UIViewController {
    
    private var valueCurrency: Double = 0.0
    private var toggle = true
    
    let notify = NotificationCenter.default
    
    
    
    
   
    private let basicView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 250, height: 200)
        return view
    }()
    
    var firstImage: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
     var secondImage: UIImageView = {
       let image = UIImageView()
         image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let labelTitle: UILabel = {
       let title = UILabel()
        title.text = "Конвертировать".localized()
        title.font = .systemFont(ofSize: 22)
        title.textColor = .black
        title.textAlignment = .center
        return title
    }()
    
    private let fieldFirst: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 5.0
        field.layer.borderWidth = 1.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        return field
    }()
    
    private let fieldSecond: UITextField = {
        let field = UITextField()
        field.placeholder = ""
        field.layer.cornerRadius = 5.0
        field.layer.borderWidth = 1.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.textColor = .black
        field.attributedPlaceholder = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        return field
    }()
    
     let currencyFirst: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        return label
    }()
    
     let currencySecond: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        return label
    }()
    
    private let closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "calendar_history_close"), for: .normal)
        button.tintColor = .red
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return button
    }()
    
    private let  calcSwap: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "calc_swap_icon"), for: .normal)
        button.addTarget(self, action: #selector(toggleCurrency), for: .touchUpInside)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        return button
    }()
    
    init(firstImage: String, secondImage: String, valueCurrency: Double) {
        super .init(nibName: nil, bundle: nil)
        self.firstImage.image = UIImage(named: "flag_\(firstImage.lowercased())")
        self.secondImage.image = UIImage(named: "flag_\(secondImage.lowercased())")
        self.currencyFirst.text = firstImage
        self.currencySecond.text = secondImage
        self.valueCurrency = valueCurrency
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeView() {
       self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: смена валют местами
    @objc func toggleCurrency() {
        let image1 = firstImage.image
        let image2 = secondImage.image
        let text1 = currencyFirst.text
        let text2 = currencySecond.text
        
        if firstImage.image == image1 || secondImage.image == image2 || currencyFirst.text == text1 || currencySecond.text == text2 {
            firstImage.image = image2
            secondImage.image = image1
            currencyFirst.text = text2
            currencySecond.text = text1
        }
     
        if toggle {
            toggle = false
        } else {
            toggle = true
        }
    }

    //MARK: подсчет значений в полях
    @objc func countUp() {
        guard let textFirst = fieldFirst.text else {
            return
        }
        
        if toggle {
            if let myNumber = NumberFormatter().number(from: textFirst) {
                let myInt = Double(myNumber.intValue)
                
                let result = ManagerNetwork.shared.checkedEntryPrice / valueCurrency * myInt
                fieldSecond.text = String(format: "%.7f" , result)
            }
        } else {
            if let myNumber = NumberFormatter().number(from: textFirst) {
                let myInt = Double(myNumber.intValue)
                
                let result = valueCurrency * myInt / ManagerNetwork.shared.checkedEntryPrice
                fieldSecond.text = String(format: "%.7f" , result)
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = .clear
        view.addSubview(basicView)
        basicView.addSubview(labelTitle)
        basicView.addSubview(fieldFirst)
        basicView.addSubview(fieldSecond)
        basicView.addSubview(firstImage)
        basicView.addSubview(secondImage)
        basicView.addSubview(currencySecond)
        basicView.addSubview(currencyFirst)
        basicView.addSubview(closeButton)
        basicView.addSubview(calcSwap)
        
        layoutFunc()
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(countUp), userInfo: nil, repeats: true)
        
        notify.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutFunc()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //layoutFunc()
    }
    
    @objc func keyboardShow() {
        basicView.snp.makeConstraints { make in
            make.width.equalTo(view.bounds.width * 0.8)
            make.height.equalTo(200)
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
        }
    }
    
    
    
    //MARK: верстка
    func layoutFunc() {
        basicView.snp.makeConstraints { make in
            make.width.equalTo(view.bounds.width * 0.8)
            make.height.equalTo(200)
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(view.frame.height/4)
        }
        
        labelTitle.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.top.equalTo(basicView).offset(10)
            make.centerX.equalTo(view)
        }
        
        fieldFirst.snp.makeConstraints { make in
            make.right.equalTo(basicView).offset(-20)
            make.top.equalTo(labelTitle).offset(40)
            make.width.equalTo(view.frame.width / 3)
            make.height.equalTo(30)
        }
        
        fieldSecond.snp.makeConstraints { make in
            make.top.equalTo(fieldFirst).offset(80)
            make.right.equalTo(basicView).offset(-20)
            make.width.equalTo(view.frame.width / 3)
            make.height.equalTo(30)
        }
        
        firstImage.snp.makeConstraints { make in
            make.width.equalTo(55)
            make.height.equalTo(42)
            make.top.equalTo(labelTitle).offset(35)
            make.left.equalTo(basicView).offset(20)
        }
        
        secondImage.snp.makeConstraints { make in
            make.width.equalTo(55)
            make.height.equalTo(42)
            make.top.equalTo(firstImage).offset(80)
            make.left.equalTo(basicView).offset(20)
        }
        
        currencyFirst.snp.makeConstraints { make in
            make.bottom.equalTo(labelTitle).offset(40)
            make.right.equalTo(firstImage).offset(70)
        }
        
        currencySecond.snp.makeConstraints { make in
            make.bottom.equalTo(currencyFirst).offset(80)
            make.right.equalTo(secondImage).offset(70)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(35)
            make.top.equalTo(basicView).offset(-10)
            make.right.equalTo(basicView).offset(10)
        }
        
        calcSwap.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(35)
            make.centerX.equalTo(basicView)
            make.top.equalTo(fieldFirst).offset(37)
        }
        
    }

}
