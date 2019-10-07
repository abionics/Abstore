//
//  FullscreenImageViewController.swift
//  Abstore
//
//  Created by Abionics on 8/29/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class FullscreenImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    var drag: DragListener!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        imageView.image = image
        drag = DragListener(controller: self, content: scrollView!)
    }
    
    @IBAction func clickOnScreen(_ sender: UITapGestureRecognizer) {
        print("click")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setupImageView() {
        let imageSize = imageView.image!.size
        let scrollSize = scrollView.bounds.size
        let ratio = min(scrollSize.width / imageSize.width, scrollSize.height / imageSize.height)
        let size = CGSize(width: ratio * imageSize.width, height: ratio * imageSize.height)
        imageView.bounds = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        print(imageSize, scrollSize, imageView.bounds.size, CGSize(width: ratio * imageSize.width, height: ratio * imageSize.height))
    }

    @IBAction func dragUp(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        let dismiss = velocity.y > 1000
        drag.dismiss(state: sender.state, translation: translation, dismiss: dismiss)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let borderUp = UIScreen.main.bounds.height / 7.5
        let translation = scrollView.contentOffset
        let dismiss = velocity.y < -3 && translation.y < -borderUp
        drag.dismiss(state: .ended, translation: .zero, dismiss: dismiss)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
