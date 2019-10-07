//
//  PreviewViewController.swift
//  Abstore
//
//  Created by Abionics on 8/19/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit
import Photos

class PreviewViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagsView: TagsViewController!
    
    var infile: Infile!
    var drag: DragListener!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = SimpleTimer()
        
        imageView.image = infile.preview.image
        DispatchQueue.main.async {
            self.showOriginalImage()
            print("[Main][Info] Opened image \(self.infile.name) in \(timer.stime())")
        }

        tagsView.setup(infiles: [infile])
        drag = DragListener(controller: self, content: imageView!)
        navigationController?.navigationBar.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showOriginalImage() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        var original: UIImage!
        manager.requestImage(for: infile.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
            image, error in
            original = image!
        })
        imageView.image = original
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FullscreenImageViewController {
            let controller = segue.destination as! FullscreenImageViewController
            controller.image = imageView.image
            tagsView.endEditing(true)
        }
    }
    
    @IBAction func dragUp(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        let dismiss = velocity.y > 1000
        drag.dismiss(state: sender.state, translation: translation, dismiss: dismiss)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.height == UIScreen.main.bounds.height {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height - keyboardFrame.height - SuggestionViewController.HEIGHT)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        print("hide")
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.height != UIScreen.main.bounds.height {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height + keyboardFrame.height + SuggestionViewController.HEIGHT)
        }
    }
}
