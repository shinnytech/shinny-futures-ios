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
        priceTick.text = DataManager.getInstance().sSearchEntities[DataManager.getInstance().sInstrumentId]?.p_tick
        let margin = (DataManager.getInstance().sSearchEntities[DataManager.getInstance().sInstrumentId]?.margin)!
        if margin == 0{
            openVolume.text = "0"
        }else {
            for (_, account) in DataManager.getInstance().sRtnAcounts {
                let available = account[AccountConstants.available].intValue
                openVolume.text = "\(available / margin)"
            }
        }

        let quote = DataManager.getInstance().sRtnMD[RtnMDConstants.quotes][DataManager.getInstance().sInstrumentId]
        upperLimit.text = quote[QuoteConstants.upper_limit].stringValue
        lowerLimit.text = quote[QuoteConstants.lower_limit].stringValue
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
            output = value - 1
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
        let operand = "1"
        return operand
    }

}
