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
    
    let COUNT = 3
    static var HEIGHT: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SuggestionView", owner: self, options: nil)
        addSubview(contentView)
        SuggestionViewController.HEIGHT = contentView.bounds.height
        
        viewWithTag(0)
        // Do any additional setup after loading the view.
    }
    
    func setup(field textField: UITextField, tags: TagsKeeper) {
        textField.addTarget(nil, action: #selector(edited), for: UIControl.Event.valueChanged)
    }
    
    @objc func edited(textField: UITextField) {
        print("edited")
    }
    
    @IBAction func choose(_ sender: UIButton) {
        let index = sender.tag
        print("choose", index)
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
