//
//  UICollectionView+ scrollToBottom.swift
//  Abstore
//
//  Created by Abionics on 8/18/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

extension UICollectionView {
    func scrollToBottom(animated: Bool) {
        guard numberOfSections > 0 else { return }
        
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else { return }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
    }
}
