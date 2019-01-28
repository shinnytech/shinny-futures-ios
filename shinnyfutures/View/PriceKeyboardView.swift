//
//  PriceKeyboardView.swift
//  shinnyfutures
//
//  Created by chenli on 2018/5/18.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import UIKit

public protocol PriceKeyboardViewDelegate: class {
    func calculator(_ calculator: PriceKeyboardView, didChangeValue value: String)
}

enum PriceKey: Int {
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
    case decimal
    case lineup
    case opponent
    case market
    case last
    case subtract
    case add
    case clear
    case confirm
    case back
}

open class PriceKeyboardView: UIView {
    open weak var delegate: PriceKeyboardViewDelegate?
    var view: UIView!
    var processor = PriceKeyboardViewProcessor()
    @IBOutlet weak var priceTick: UILabel!
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
    }

    func switchQuote() {
        processor.refreshCurrentOperand()
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

    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PriceKeyboardView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch (sender.tag) {
        case (PriceKey.zero.rawValue)...(PriceKey.nine.rawValue):
            let output = processor.numberOperand(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case PriceKey.decimal.rawValue:
            let output = processor.addDecimal()
            delegate?.calculator(self, didChangeValue: output)
        case (PriceKey.lineup.rawValue)...(PriceKey.last.rawValue):
            let output = processor.priceOperand(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case (PriceKey.subtract.rawValue)...(PriceKey.add.rawValue):
            let output = processor.computeValue(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case PriceKey.clear.rawValue:
            let output = processor.clearAll()
            delegate?.calculator(self, didChangeValue: output)
        case PriceKey.confirm.rawValue:
            (delegate as! TransactionViewController).view.endEditing(true)
        case PriceKey.back.rawValue:
            let output = processor.deleteLastDigit()
            delegate?.calculator(self, didChangeValue: output)
        default:
            break
        }
    }
}

class PriceKeyboardViewProcessor {
    enum PriceType: String {
        case lineup = "排队价"
        case opponent = "对手价"
        case market = "市价"
        case last = "最新价"
    }

    var currentOperand: String = {
        if CommonConstants.USER_PRICE.elementsEqual(DataManager.getInstance().sPriceType) {return CommonConstants.COUNTERPARTY_PRICE}
        else {return DataManager.getInstance().sPriceType}
    }()
    weak var masterView: UITextField!

    func refreshCurrentOperand() {
        if CommonConstants.USER_PRICE.elementsEqual(DataManager.getInstance().sPriceType) {
            currentOperand = CommonConstants.COUNTERPARTY_PRICE
        }else {
            currentOperand = DataManager.getInstance().sPriceType
        }
    }

    func numberOperand(_ value: Int) -> String {
        let operand = "\(value)"
        switch currentOperand {
        case "0", PriceType.last.rawValue, PriceType.market.rawValue, PriceType.opponent.rawValue, PriceType.lineup.rawValue:
            currentOperand = operand
        default:
            currentOperand += operand
        }
        return currentOperand
    }

    func addDecimal() -> String {
        if currentOperand.range(of: decimalSymbol()) == nil {
            currentOperand += decimalSymbol()
        }
        return currentOperand
    }

    func priceOperand(_ value: Int) -> String {
        switch value {
        case PriceKey.lineup.rawValue:
            currentOperand = PriceType.lineup.rawValue
        case PriceKey.opponent.rawValue:
            currentOperand = PriceType.opponent.rawValue
        case PriceKey.market.rawValue:
            currentOperand = PriceType.market.rawValue
        case PriceKey.last.rawValue:
            currentOperand = PriceType.last.rawValue
        default:
            break
        }

        return currentOperand
    }

    func computeValue(_ tag: Int) -> String {
        var value = 0.0
        var output = 0.0
        let dataManager = DataManager.getInstance()
        let decimal = dataManager.getDecimalByPtick(instrumentId: dataManager.sInstrumentId)

        switch currentOperand {
        case PriceType.lineup.rawValue:
            guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {break}
            let bid_price1 = Double("\(quote.bid_price1 ?? 0.0)") ?? 0.0
            let ask_price1 = Double("\(quote.ask_price1 ?? 0.0)") ?? 0.0
            value = ask_price1 < bid_price1 ? ask_price1 : bid_price1
            currentOperand = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
            return currentOperand
        case PriceType.opponent.rawValue:
            guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {break}
            let bid_price1 = Double("\(quote.bid_price1 ?? 0.0)") ?? 0.0
            let ask_price1 = Double("\(quote.ask_price1 ?? 0.0)") ?? 0.0
            value = ask_price1 < bid_price1 ? bid_price1 : ask_price1
            currentOperand = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
            return currentOperand
        case PriceType.market.rawValue:
            guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {break}
            value = Double("\(quote.last_price ?? 0.0)") ?? 0.0
            currentOperand = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
            return currentOperand
        case PriceType.last.rawValue:
            guard let quote = dataManager.sRtnMD.quotes[dataManager.sInstrumentId] else {break}
            value = Double("\(quote.last_price ?? 0.0)") ?? 0.0
            currentOperand = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(value)")
            return currentOperand
        default:
            value = (currentOperand as NSString).doubleValue
        }

        switch tag {
        case PriceKey.subtract.rawValue:
            guard let p_tick = dataManager.sSearchEntities[dataManager.sInstrumentId]?.p_tick else{break}
            if p_tick.isEmpty {break}
            guard let p_tick_int = Double(p_tick) else{break}
            if masterView.offset(from: masterView.beginningOfDocument, to: (masterView.selectedTextRange?.start)!) == 0{
                output = 0 - value
            }else {
                output = value - p_tick_int
            }
        case PriceKey.add.rawValue:
            guard let p_tick = dataManager.sSearchEntities[dataManager.sInstrumentId]?.p_tick else{break}
            if p_tick.isEmpty {break}
            guard let p_tick_int = Double(p_tick) else{break}
            output = value + p_tick_int
        default:
            break
        }
        currentOperand = dataManager.saveDecimalByPtick(decimal: decimal, data: "\(output)")
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

    func clearAll() -> String {
        currentOperand = resetOperand()
        return currentOperand
    }

    fileprivate func decimalSymbol() -> String {
        return "."
    }

    fileprivate func resetOperand() -> String {
        let operand = "0"
        return operand
    }

}
