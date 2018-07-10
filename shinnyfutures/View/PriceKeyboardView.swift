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

    var currentOperand: String = PriceType.last.rawValue
    var decimalDigit = 0
    weak var masterView: UITextField!

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

        switch currentOperand {
        case PriceType.lineup.rawValue:
            let quote = DataManager.getInstance().sRtnMD[RtnMDConstants.quotes][DataManager.getInstance().sInstrumentId]
            let bid_price1 = (quote[QuoteConstants.bid_price1].stringValue as NSString).doubleValue
            let ask_price1 = (quote[QuoteConstants.ask_price1].stringValue as NSString).doubleValue
            value = ask_price1 < bid_price1 ? ask_price1 : bid_price1
            currentOperand = formatValue(value)
            return currentOperand
        case PriceType.opponent.rawValue:
            let quote = DataManager.getInstance().sRtnMD[RtnMDConstants.quotes][DataManager.getInstance().sInstrumentId]
            let bid_price1 = (quote[QuoteConstants.bid_price1].stringValue as NSString).doubleValue
            let ask_price1 = (quote[QuoteConstants.ask_price1].stringValue as NSString).doubleValue
            value = ask_price1 < bid_price1 ? bid_price1 : ask_price1
            currentOperand = formatValue(value)
            return currentOperand
        case PriceType.market.rawValue:
            let quote = DataManager.getInstance().sRtnMD[RtnMDConstants.quotes][DataManager.getInstance().sInstrumentId]
            value = (quote[QuoteConstants.last_price].stringValue as NSString).doubleValue
            currentOperand = formatValue(value)
            return currentOperand
        case PriceType.last.rawValue:
            let quote = DataManager.getInstance().sRtnMD[RtnMDConstants.quotes][DataManager.getInstance().sInstrumentId]
            value = (quote[QuoteConstants.last_price].stringValue as NSString).doubleValue
            currentOperand = formatValue(value)
            return currentOperand
        default:
            value = (currentOperand as NSString).doubleValue
        }

        switch tag {
        case PriceKey.subtract.rawValue:
            if masterView.offset(from: masterView.beginningOfDocument, to: (masterView.selectedTextRange?.start)!) == 0{
                output = 0 - value
            }else {
                output = value - 10
            }
        case PriceKey.add.rawValue:
            output = value + 10
        default:
            break
        }
        currentOperand = formatValue(output)
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

    fileprivate func formatValue(_ value: Double) -> String {
        var raw = "\(value)"
        var end = raw.index(before: raw.endIndex)
        var foundDecimal = false
        while end != raw.startIndex && (raw[end] == "0" || isDecimal(raw[end])) && !foundDecimal {
            foundDecimal = isDecimal(raw[end])
            raw.remove(at: end)
            end = raw.index(before: end)
        }
        return raw
    }

    fileprivate func isDecimal(_ char: Character) -> Bool {
        return String(char) == decimalSymbol()
    }
}
