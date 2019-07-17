//
//  GalleryScrollViewController.swift
//  Notes
//
//  Created by dyy-mac on 14/07/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class GalleryScrollViewController: UIViewController {

    @IBOutlet weak var photoScrollView: UIScrollView!
    var galleryToShow: [UIImage] = []
    var imageViews: [UIImageView] = []
    var tappedPhotoIndex: Int = 0
    var needAutoDraggingToTarget: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        // create image views
        for image in galleryToShow {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            photoScrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        helpPhotoScrollView()
        if(needAutoDraggingToTarget) {
            needAutoDraggingToTarget = false
            let offset = photoScrollView.frame.width * CGFloat(tappedPhotoIndex)
            photoScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    private func helpPhotoScrollView() {
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = photoScrollView.frame.size
            imageView.frame.origin.x = photoScrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }
        let contentWidth = photoScrollView.frame.width * CGFloat(imageViews.count)
        photoScrollView.contentSize = CGSize(width: contentWidth, height: photoScrollView.frame.height)
    }
}
