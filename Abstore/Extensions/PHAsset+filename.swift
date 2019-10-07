//
//  PHAsset+filename.swift
//  Abstore
//
//  Created by Abionics on 8/17/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import Photos

extension PHAsset {
    var filename: String? {
        return self.value(forKey: "filename") as? String  // this is an undocumented workaround that works
        //return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}
