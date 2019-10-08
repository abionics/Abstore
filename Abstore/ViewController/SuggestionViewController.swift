//
//  SuggestionViewViewController.swift
//  Abstore
//
//  Created by Abionics on 10/6/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class SuggestionViewController: UIView {
    @IBOutlet var contentView: UIView!
    
    static var HEIGHT: CGFloat = 0
    let COUNT = 3
    
    var field: UITextField!
    var view: UIView!
    var suggestion: Suggestion!
    var result = [(value: String, from: Int)]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        print("init")
        Bundle.main.loadNibNamed("SuggestionView", owner: self, options: nil)
        addSubview(contentView)
        SuggestionViewController.HEIGHT = contentView.bounds.height
        
        for i in 0...COUNT - 1 {
            let button = contentView.viewWithTag(i) as! UIButton
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.minimumScaleFactor = 0.1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.lineBreakMode = .byClipping
        }
    }
    
    func setup(field: UITextField, controller: UIViewController) {
        self.field = field
        self.view = controller.view
        field.autocorrectionType = .no
        isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        suggestion = Suggestion()
        print("setupped")
    }
    
    func refresh() {
        suggestion.setup()
    }
    
    func suggest(text: String) {
        result = suggestion.suggest(text: text)
        
        if result.count == 0 && field.autocorrectionType != .yes {
            field.autocorrectionType = .yes
            field.reloadInputViews()
            return
        } else if result.count != 0 && field.autocorrectionType != .no {
            field.autocorrectionType = .no
            field.reloadInputViews()
        }
        
        result.append(contentsOf: Array(repeating: ("", text.count - 1), count: max(COUNT - result.count, 0)))
        for i in 0...COUNT - 1 {
            let button = contentView.viewWithTag(i) as! UIButton
            button.setTitle(result[i].value, for: .normal)
            print(i, result[i])
        }
    }
    
    @IBAction func choose(_ sender: UIButton) {
        let index = sender.tag
        print("choose", index)
        let value = result[index].value
        let from = result[index].from
        let text = field.text!
        field.text = text.dropLast(text.count - from) + value
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        print("SUGGEST")
        isHidden = false
//        self.frame.size = CGSize(width: self.frame.size.width, height: SuggestionViewController.HEIGHT)
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.height == UIScreen.main.bounds.height {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height - keyboardFrame.height)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        isHidden = true
//        self.frame.size = CGSize(width: self.frame.size.width, height: 0)
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.height != UIScreen.main.bounds.height {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height + keyboardFrame.height)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
