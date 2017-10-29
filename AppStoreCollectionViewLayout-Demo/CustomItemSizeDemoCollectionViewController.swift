//
//  CustomItemSizeDemoCollectionViewController.swift
//  AppStoreCollectionViewLayout-Demo
//
//  Created by Pitiphong Phongpattranont on 29/10/2017.
//  Copyright © 2017 Pitiphong Phongpattranont. All rights reserved.
//

import UIKit
import CollectionViewShelfLayout


private let reuseIdentifier = "Cell"

class ImageCollectionViewCell: UICollectionViewCell {
  @IBOutlet var imageView: UIImageView!
}

class CustomItemSizeDemoCollectionViewController: UICollectionViewController, CollectionViewDelegateShelfLayout {
  
  var imageSizes = [[CGSize]]()
  var imageCache = [[UIImage?]]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    if #available(iOS 10.0, *) {
      collectionView?.refreshControl = refreshControl
    }
    
    if let layout = collectionView?.collectionViewLayout as? CollectionViewShelfLayout {
      layout.sectionCellInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    }
    
    refresh()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 5
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 8
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
    if imageCache[indexPath.section][indexPath.item] == nil {
      let size = imageSizes[indexPath.section][indexPath.item]
      var urlComponents = URLComponents(string: "https://dummyimage.com/3:2x\(size.height * collectionView.traitCollection.displayScale)")!
      urlComponents.queryItems = [ URLQueryItem(name: "text", value: "\(Int(size.width))x\(Int(size.height))")]
      
      let request = URLRequest.init(url: urlComponents.url!)
      let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
        if let data = data, let image = UIImage(data: data) {
          self?.imageCache[indexPath.section][indexPath.item] = image
          DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
              cell.imageView.image = image
            }
          }
        }
      })
      task.resume()
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let cell = cell as! ImageCollectionViewCell
    cell.imageView.image = imageCache[indexPath.section][indexPath.item]
  }
  
  @objc func refresh() {
    // Generate image size randomly with aspect ratio of 3:2 and the height is between 120 - 240 points with stepping of 20.0 points
    imageSizes = (0..<5).map({ _ in
      (0..<8).map({ _ in
        let height = (CGFloat(arc4random_uniform(6)) * 20.0) + 120.0
        let width = height * 3 / 2
        return CGSize(width: width, height: height)
      })
    })
    
    imageCache = (0..<5).map({ _ in
      Array(repeating: nil, count: 8)
    })
    
    collectionView?.reloadData()
    if #available(iOS 10.0, *) {
      collectionView?.refreshControl?.endRefreshing()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return imageSizes[indexPath.section][indexPath.item]
  }
  
}
