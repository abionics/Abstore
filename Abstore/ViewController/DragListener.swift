//
//  DragListener.swift
//  Abstore
//
//  Created by Abionics on 9/2/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class DragListener {
    let controller: UIViewController
    let background: UIImageView
    let screenshot: UIImageView
    let content: UIView
    
    let original: CGPoint
    let padding: CGPoint
    let backgroundColor: UIColor?
    
    init(controller: UIViewController, content: UIView) {
        self.controller = controller
        self.content = content
        original = content.center
        padding = content.frame.origin
        backgroundColor = controller.view.backgroundColor
        
        // create UIImageView with controller background color
        let color = controller.view.backgroundColor ?? .black
        background = UIImageView(image: color.image())
        
        // render parent view in a UIImage
        UIGraphicsBeginImageContext(controller.view.bounds.size);
        controller.parent?.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        screenshot = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        controller.view.insertSubview(screenshot, at: 0)
        controller.view.insertSubview(background, at: 1)
        controller.view.backgroundColor = .clear
    }
    
    func dismiss(state: UIGestureRecognizer.State, translation: CGPoint, dismiss: Bool) {
        if state == .changed {
            content.frame.origin = CGPoint(
                x: translation.x + padding.x,
                y: translation.y + padding.y
            )
            let height = UIScreen.main.bounds.height
            background.alpha = 1 - translation.y / height
        } else if state == .ended {
            if dismiss {
                UIView.animate(withDuration: 0.2, animations: {
                    self.content.frame.origin = CGPoint(
                        x: self.content.frame.origin.x + self.padding.x,
                        y: self.content.frame.size.height + self.padding.y
                    )
                }, completion: { (completed) in
                    if completed {
                        if self.controller.parent == nil {
                            self.controller.dismiss(animated: false, completion: nil)
                        } else {
                            self.controller.navigationController?.popViewController(animated: false)
                        }
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.content.frame.origin = CGPoint(
                        x: self.padding.x,
                        y: self.padding.y
                    )
                    self.background.alpha = 1
                })
            }
        }
    }
}
