//
//  InputTableViewCell.swift
//  AnimatedMergeSort
//
//  Created by Yury Pogrebnyak on 5/16/17.
//  Copyright © 2017 KEYPR. All rights reserved.
//

import UIKit

protocol InputTableViewCellDelegate {
    func inputCompleted(cell: InputTableViewCell)
    func inputChanged(cell: InputTableViewCell)
}

class InputTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var inputTextField: UITextField!
    
    var delegate: InputTableViewCellDelegate?
    var nextBarButton: UIBarButtonItem!

    override func awakeFromNib() {
        super.awakeFromNib()
        addDoneButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Accessory buttons for keyboard
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        nextBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(completeInput))
        keyboardToolbar.items = [flexBarButton, nextBarButton]
        inputTextField.inputAccessoryView = keyboardToolbar
    }
    
    func completeInput() {
        delegate?.inputCompleted(cell: self)
    }
    
    // MARK: - First responder methods
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return inputTextField.becomeFirstResponder()
    }
    
    // MARK: - IBAction
    @IBAction func inputTextFieldChanged(_ sender: Any) {
        let text = inputTextField.text ?? ""
        nextBarButton.isEnabled = !text.isEmpty
        delegate?.inputChanged(cell: self)
    }
    

}
