//
//  TagsTableViewCell.swift
//  Abstore
//
//  Created by Abionics on 9/9/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit
import EFColorPicker

class TagsTableViewCell: UITableViewCell, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var textFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorButtonRightConstraint: NSLayoutConstraint!
    
    let BACKGROUND_ALPHA: CGFloat = 0.5
    
    var sender: Tag!
    var type: Type!
    var value: String!
    var color: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
    }
    
    func setup(tag: Tag, type: Type, text: String) {
        self.sender = tag
        self.type = type
        self.value = text
        self.color = tag.color
        setup(text: text, color: tag.color)
    }
    
    private func setup(text: String, color: UIColor) {
        textField.text = text
        textField.placeholder = type.placeholder
        colorButton.backgroundColor = color
        colorButton.isHidden = type.isButtonHidden
        textFieldLeftConstraint.constant = type.paddingLeft
        
        if type.isButtonHidden == false {
            backgroundColor = colorButton.backgroundColor!.withAlphaComponent(BACKGROUND_ALPHA)
        } else {
            backgroundColor = .white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        type.closure(sender, value, textField.text!)
        value = textField.text
        let table = self.superview as! UITableView
        table.reloadData()
        return false
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        let colorPicker = EFColorSelectionViewController()
        colorPicker.delegate = self
        colorPicker.color = colorButton.backgroundColor ?? UIColor.white
        colorPicker.setMode(mode: EFColorSelectionMode.hsb)
        
        let navigation = UINavigationController(rootViewController: colorPicker)
        navigation.navigationBar.backgroundColor = UIColor.white
        navigation.navigationBar.isTranslucent = false
        navigation.modalPresentationStyle = UIModalPresentationStyle.popover
        navigation.popoverPresentationController?.delegate = self
        navigation.popoverPresentationController?.sourceView = self
        navigation.popoverPresentationController?.sourceRect = self.bounds
        navigation.preferredContentSize = colorPicker.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let done: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItem.Style.done,
                target: self,
                action: #selector(colorPickerClose(sender:))
            )
            colorPicker.navigationItem.rightBarButtonItem = done
        }
        ViewController.instance!.present(navigation, animated: true, completion: nil)
    }
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        self.color = color
    }
    
    @objc func colorPickerClose(sender: UIBarButtonItem) {
        ViewController.instance!.dismiss(animated: true) {
            [weak self] in
            if let _ = self {
                self!.colorButton.backgroundColor = self!.color
                self!.backgroundColor = self!.color.withAlphaComponent(self!.BACKGROUND_ALPHA)
                Storage.instance.changeTagColor(tag: self!.sender, color: self!.color)
            }
        }
    }
}

struct Type {
    let placeholder: String
    let isButtonHidden: Bool
    let paddingLeft: CGFloat
    let closure: (Tag, String, String) -> ()
    
    static var name: Type {
        return Type(placeholder: "Input tag title", isButtonHidden: false, paddingLeft: 10, closure: { tag, last, text in
            Storage.instance.changeTagName(tag: tag, name: text)
        })
    }
    static var alias: Type {
        return Type(placeholder: "Input alias title", isButtonHidden: true, paddingLeft: 20, closure: { tag, last, text in
            Storage.instance.removeAlias(tag: tag, alias: last)
            let changed = Storage.instance.addAlias(tag: tag, alias: text)
            if !changed {
                Storage.instance.addAlias(tag: tag, alias: last) //add last value if cannot change to new
            }
        })
    }
    static var new: Type {
        return Type(placeholder: "Input alias title", isButtonHidden: true, paddingLeft: 20, closure: { tag, last, text in
            Storage.instance.addAlias(tag: tag, alias: text)
        })
    }
}
