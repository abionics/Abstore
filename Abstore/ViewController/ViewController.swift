//
//  ViewController.swift
//  Abstore
//
//  Created by Abionics on 8/15/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit
import Photos
import CommonCrypto

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tagsView: TagsViewController!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var suggestionView: SuggestionViewController!
    @IBOutlet weak var suggestionViewHeight: NSLayoutConstraint!
    
    
    static var instance: ViewController?
    
    var storage: Storage!
    var result = [Infile]()
    
    var action = ActionType.open
    var selected = Set<Infile>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.instance = self
        tagsViewHeight.constant = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchField.delegate = self
        
        suggestionView.setup(field: searchField, view: self.view, height: suggestionViewHeight)
        searchField.addTarget(self, action: #selector(searchFieldEditing), for: .editingDidBegin)
        searchField.addTarget(self, action: #selector(searchFieldEdited), for: .editingChanged)
        
        tagsView.suggestionSetup(view: self.view)
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case PHAuthorizationStatus.authorized:
                DispatchQueue.main.async {
                    self.start()
                }
            case PHAuthorizationStatus.denied, PHAuthorizationStatus.restricted:
                print("[Main][Warning] Access to gallery is denied/restricted by user")
                self.alert(title: "Abstore needs acces to device gallery", message: "Please, go into settings and give the access")
            case PHAuthorizationStatus.notDetermined:
                print("[Main][Error] GALLERY AUTHORIZATION STATUS IS NOT DETERMINED")
                self.viewDidLoad()
            default: break
            }
        }
    }
    
    func start() {
        storage = Storage.instance
        search(expression: "")
    }
    @objc func searchFieldEditing(_ field: UITextField) {
        suggestionView.refresh()
    }
    @objc func searchFieldEdited(_ field: UITextField) {
        suggestionView.suggest(text: field.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = result[indexPath.row].preview.image
        let item = result[indexPath.row]
        selected.contains(item) ? selectCell(cell) : deselectCell(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width / CGFloat(Constants.IMAGES_IN_ROW) - 1
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        searchField.endEditing(true)
        switch action {
        case .open:
            let infile = result[indexPath.row]
            performSegue(withIdentifier: "open infile", sender: infile)
            return false
        case .select:
            let item = result[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath)!
            if selected.contains(item) {
                selected.remove(item)
                deselectCell(cell)
                if (selected.count == 0) {
                    tagsViewHeight.constant = 0
                    layoutAnimated()
                }
            } else {
                selected.insert(item)
                selectCell(cell)
                if (selected.count > 0) {
                    tagsViewHeight.constant = 175
                    layoutAnimated()
                }
            }
            tagsView.setup(infiles: Array(selected))
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.destination is PreviewViewController {
            let controller = segue.destination as! PreviewViewController
            controller.infile = sender as? Infile
        }
        
        if segue.destination is TagsTableViewController {
            let controller = segue.destination as! TagsTableViewController
            controller.keeper = storage.tags
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        search(expression: textField.text!)
        return false
    }
    
    func search(expression: String) {
        result = storage.search(expression: expression)
        self.collectionView.reloadData()
        self.collectionView.scrollToBottom(animated: false)
    }
    
    
    @IBAction func addPress(_ sender: UIButton) {
        searchField.text = searchField.text!.trimAndClean() + " "
    }
    
    @IBAction func selectImages(_ sender: UIButton) {
        searchField.endEditing(true)
        let color = self.view.tintColor
        let size = sender.titleLabel?.font.pointSize
        switch action {
        case .open:
            action = .select
            sender.setTitle("Cancel", for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: size!, weight: .semibold)
        case .select:
            action = .open
            deselectAll()
            tagsView.endEditing(true)
            tagsViewHeight.constant = 0
            layoutAnimated()
            sender.setTitle("Select", for: .normal)
            sender.setTitleColor(color, for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: size!, weight: .medium)
        }
    }
    
    func selectCell(_ cell: UICollectionViewCell) {
        cell.layer.borderWidth = 3.5
        cell.layer.borderColor = view.tintColor.cgColor
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.layer.opacity = 0.7
    }
    
    func deselectCell(_ cell: UICollectionViewCell) {
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = UIColor.white.cgColor
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.layer.opacity = 1.0
    }
    
    func deselectAll() {
        for cell in collectionView.visibleCells {
            deselectCell(cell)
        }
        selected = []
    }
    
    func layoutAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

enum ActionType {
    case open
    case select
}
