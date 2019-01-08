//
//  VolumeKeyboardView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/18.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

public protocol VolumeKeyboardViewDelegate: class {
    func calculator(_ calculator: VolumeKeyboardView, didChangeValue value: String)
}

enum VolumeKey: Int {
    case zero = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case subtract
    case add
    case clear
    case confirm
    case back
}

open class VolumeKeyboardView: UIView {
    open weak var delegate: VolumeKeyboardViewDelegate?
    var view: UIView!
    fileprivate var processor = VolumeKeyboardViewProcessor()
    @IBOutlet weak var priceTick: UILabel!
    @IBOutlet weak var openVolume: UILabel!
    @IBOutlet weak var upperLimit: UILabel!
    @IBOutlet weak var lowerLimit: UILabel!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func loadXib() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        initData()
    }


    func initData() {
        refreshPrice()
        refreshAccount()
    }

    func refreshPrice() {
        let dataManager = DataManager.getInstance()
        let instrument_id = dataManager.sInstrumentId

        priceTick.text = dataManager.sSearchEntities[instrument_id]?.p_tick

        let decimal = dataManager.getDecimalByPtick(instrumentId: instrument_id)
        guard let quote = dataManager.sRtnMD.quotes[instrument_id] else {return}
        let upper = "\(quote.upper_limit ?? 0.0)"
        let lower = "\(quote.lower_limit ?? 0.0)"
        upperLimit.text = dataManager.saveDecimalByPtick(decimal: decimal, data: upper)
        lowerLimit.text = dataManager.saveDecimalByPtick(decimal: decimal, data: lower)
    }

    func refreshAccount() {
        let dataManager = DataManager.getInstance()
        var instrument_id = dataManager.sInstrumentId

        if instrument_id.contains("KQ"){
            instrument_id = (dataManager.sSearchEntities[instrument_id]?.underlying_symbol)!
        }
        let margin = (dataManager.sSearchEntities[instrument_id]?.margin)!
        if margin == 0{
            openVolume.text = "0"
        }else {
            guard let user = dataManager.sRtnTD.users[dataManager.sUser_id] else {return}
            for (_, account) in user.accounts {
                let available = Int("\(account.available ?? 0)") ?? 0
                openVolume.text = "\(available / margin)"
            }
        }
    }

    func setVolume(volume: String?) {
        if let volume = volume {
            processor.currentOperand = volume
        }
    }

    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "VolumeKeyboardView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch (sender.tag) {
        case (VolumeKey.zero.rawValue)...(VolumeKey.nine.rawValue):
            let output = processor.numberOperand(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case (VolumeKey.subtract.rawValue)...(VolumeKey.add.rawValue):
            let output = processor.computeValue(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case VolumeKey.clear.rawValue:
            let output = processor.clearAll()
            delegate?.calculator(self, didChangeValue: output)
        case VolumeKey.confirm.rawValue:
            (delegate as! TransactionViewController).view.endEditing(true)
        case VolumeKey.back.rawValue:
            let output = processor.deleteLastDigit()
            delegate?.calculator(self, didChangeValue: output)
        default:
            break
        }
    }
}

class VolumeKeyboardViewProcessor {
    var currentOperand: String = "0"

    func numberOperand(_ value: Int) -> String {
        let operand = "\(value)"
        if currentOperand == "0" {
            currentOperand = operand
        } else {
            currentOperand += operand
        }

        return currentOperand
    }

    func computeValue(_ tag: Int) -> String {
        let value = (currentOperand as NSString).integerValue
        var output = 0
        switch tag {
        case VolumeKey.subtract.rawValue:
            if value >= 1{
                output = value - 1
            }
        case VolumeKey.add.rawValue:
            output = value + 1
        default:
            break
        }
        currentOperand = "\(output)"
        return currentOperand
    }

    func clearAll() -> String {
        currentOperand = ""
        return currentOperand
    }

    func deleteLastDigit() -> String {
        if currentOperand.count > 1 {
            currentOperand.remove(at: currentOperand.index(before: currentOperand.endIndex))
        } else {
            currentOperand = resetOperand()
        }

        return currentOperand
    }

    fileprivate func resetOperand() -> String {
        let operand = ""
        return operand
    }

}
