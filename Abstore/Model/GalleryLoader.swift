//
//  GalleryLoader.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import Photos
import CommonCrypto

class GalleryLoader {
    let manager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    let fetchOptions = PHFetchOptions()
    var stubSize = CGSize.zero
    var previewSize = CGSize.zero
    
    init() {
        stubSize = CGSize(width: Constants.IMAGE_STUB_SIDE, height: Constants.IMAGE_STUB_SIDE)
        previewSize = CGSize(width: Constants.IMAGE_PREVIEW_SIDE, height: Constants.IMAGE_PREVIEW_SIDE)
        
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    }
    
    func load() -> [String: (preview: PreviewImage, asset: PHAsset)] {
        let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let count = fetchResult.count
        if count > 0 {
            var images = [String: (preview: PreviewImage, asset: PHAsset)]()
            for index in 0..<count {
                let asset = fetchResult.object(at: index)
                let name = getImageName(asset: asset)
                let preview = PreviewImage()
                manager.requestImage(for: asset, targetSize: stubSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                    image, error in
                    preview.image = image!
                })
                images[name] = (preview, asset)
            }
            DispatchQueue.global(qos: .background).async {
                let timer = SimpleTimer()
                for index in 0..<count {
                    let asset = fetchResult.object(at: index)
                    let name = self.getImageName(asset: asset)
                    let preview = images[name]!.preview
                    self.manager.requestImage(for: asset, targetSize: self.previewSize, contentMode: .aspectFill, options: self.requestOptions, resultHandler: {
                        image, error in
                        preview.image = image!
                    })
                }
                DispatchQueue.main.async {
                    ViewController.instance?.collectionView.reloadData()
                    print("[Main][Info] Created previews in background in \(timer.stime())")
                }
            }
            return images
        } else {
            return [:]
        }
    }
    
    func getImageName(asset: PHAsset) -> String {
        if let name = asset.filename {
            return name
        } else {
            print("[GalleryLoader][Error] IMAGE DONT HAVE NAME, CALCULATING HASH")
            var name: String = ""
            manager.requestImage(for: asset , targetSize: stubSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                image, error in
                name = image!.sha256()
            })
            return name
        }
    }
}
