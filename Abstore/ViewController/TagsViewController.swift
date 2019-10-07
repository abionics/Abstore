//
//  TagsView.swift
//  Abstore
//
//  Created by Abionics on 8/21/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class TagsViewController: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    let BACKGROUND_ALPHA: CGFloat = 0.5
    
    var infiles: [Infile]!
    var buttons: [UIButton]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TagsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 9
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        
        textField.delegate = self
        textField.autocorrectionType = .no
        
        setup(infiles: [])
    }
    
    func setup(infiles: [Infile]) {
        self.infiles = infiles
        setup()
    }
    
    private func setup() {
        buttons = []
        guard infiles.count > 0 else {
            collectionView.reloadData()
            return
        }
        
        let first = infiles.first!.getTags()
        var commonTags = first
        var allTags = first
        for infile in infiles {
            let tags = infile.getTags()
            commonTags = commonTags.intersection(tags)
            allTags = allTags.union(tags)
        }
        
        allTags.remove(Storage.instance.basetag)
        allTags.remove(Storage.instance.untagged)
        
        let sortedAllTags = TagsKeeper.sort(tags: allTags)
        
        for tag in sortedAllTags {
            let button = UIButton(type: .system)
            button.setTitle(tag.name, for: .normal) //todo ×
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = tag.color
            if (!commonTags.contains(tag)) {
                button.alpha = BACKGROUND_ALPHA
            } else {
                let size = button.titleLabel?.font.pointSize
                button.titleLabel?.font = UIFont.systemFont(ofSize: size!, weight: .medium)
            }
            button.layer.cornerRadius = 9
            button.on(.touchUpInside) { (sender, event) in
                self.removeTag(tag: tag)
            }
            button.sizeToFit()
            button.frame.size = CGSize(width: button.frame.width + 15, height: button.frame.height)
            buttons.append(button)
        }
        collectionView.reloadData()
    }
    
    @IBAction func addTag(_ sender: UITextField) {
        let name = sender.text!
        for infile in infiles {
            Storage.instance.addTag(infile: infile, tag: name)
        }
        sender.text = ""
        setup()
    }
    
    func removeTag(tag: Tag) {
        for infile in infiles {
            Storage.instance.removeTag(infile: infile, tag: tag)
        }
        setup()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath)
        cell.subviews.forEach {$0.removeFromSuperview()}
        cell.addSubview(buttons[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return buttons[indexPath.row].frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("text return")
        endEditing(true)
        return false
    }
}
