//
//  GalleryViewController.swift
//  Notes
//
//  Created by dyy-mac on 14/07/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    @IBAction func addPhotoBtnTapped(_ sender: UIBarButtonItem) {
        // show image picker here
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var collectionData: [UIImage] = [UIImage(named: "screen_1")!, UIImage(named: "screen_2")!, UIImage(named: "screen_3")!, UIImage(named: "screen_4")!, UIImage(named: "screen_5")!]
    var tappedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        let cellWidth = (view.frame.size.width - 16) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        if let image = cell.viewWithTag(123) as? UIImageView {
            image.image = self.collectionData[indexPath.row]
        }
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tappedIndex = indexPath.row
        performSegue(withIdentifier: "ShowGalleryScrollView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? GalleryScrollViewController, segue.identifier == "ShowGalleryScrollView" {
            controller.galleryToShow = self.collectionData
            controller.tappedPhotoIndex = self.tappedIndex
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.collectionData.append(pickedImage)
            self.collectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
