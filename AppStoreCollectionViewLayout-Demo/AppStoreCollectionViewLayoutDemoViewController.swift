//
//  AppStoreCollectionViewLayoutDemoViewController.swift
//  AppStoreCollectionViewLayout
//
//  Created by Pitiphong Phongpattranont on 7/26/2016.
//  Copyright © 2016 Pitiphong Phongpattranont. All rights reserved.
//

import UIKit
import CollectionViewShelfLayout
import StoreKit

private let reuseIdentifier = "Cell"


protocol AppStoreCollectionSectionHeaderViewDelegate: class {
  func sectionHeaderViewDidTappedButton(_ view: AppStoreCollectionSectionHeaderView)
}

class AppStoreCollectionSectionHeaderView: UICollectionReusableView {
  let label: UILabel = UILabel()
  let button: UIButton = UIButton()
  var indexPath: IndexPath?
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    
    self.indexPath = layoutAttributes.indexPath
  }
  
  weak var delegate: AppStoreCollectionSectionHeaderViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    isUserInteractionEnabled = true
    
    backgroundColor = UIColor.white
    label.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    addSubview(button)
    
    label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    button.lastBaselineAnchor.constraint(equalTo: label.lastBaselineAnchor).isActive = true
    
    button.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 8.0).isActive = true
    
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
  }
  
  @objc func buttonTapped() {
    delegate?.sectionHeaderViewDidTappedButton(self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class AppStoreCollectionViewLayoutDemoViewController: UICollectionViewController {
  
  enum Section: String {
    case Messaging
    case Internet
    case Productivity
    case Utility
  }
  
  let appData: [Section: [AppDetail]] = {
    let bundle = Bundle(for: AppStoreCollectionViewLayoutDemoViewController.self)
    let appDataPListURL = bundle.url(forResource: "Apps", withExtension: "plist")!
    let appDataPList = NSDictionary(contentsOf: appDataPListURL)! as! [String: [[String: AnyObject]]]
    
    var appData = [Section: [AppDetail]]()
    for (sectionName, apps) in appDataPList {
      let appDetails: [AppDetail]
      appDetails = apps.flatMap(AppDetail.init(plistData:))
      let section = Section(rawValue: sectionName)!
      appData[section] = appDetails
    }
    
    return appData
  }()
  
  subscript (appDetail indexPath: IndexPath) -> AppDetail {
    return appData[sections[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
  }

  var sections: [Section] {
    return appData.keys.sorted(by: { (firstSection, secondSection) in
      return firstSection.rawValue < secondSection.rawValue
    })
  }
  
  @IBOutlet var headerView: UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let layout = collectionView?.collectionViewLayout as? CollectionViewShelfLayout {
      layout.sectionCellInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
      
      headerView.translatesAutoresizingMaskIntoConstraints = false
      
      collectionView?.register(AppStoreCollectionSectionHeaderView.self, forSupplementaryViewOfKind: ShelfElementKindSectionHeader, withReuseIdentifier: "Header")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return appData[sections[section]]?.count ?? 0
  }
  
  let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.currencyCode = "USD"
    formatter.numberStyle = NumberFormatter.Style.currencyAccounting
    return formatter
  }()

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AppStoreCollectionViewCell
    let appDetail = self[appDetail: indexPath]
    cell.appNameLabel.text = appDetail.name
    cell.appPriceLabel.text = priceFormatter.string(from: NSNumber(value: appDetail.price))
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { 
      let iconData = try? Data(contentsOf: appDetail.iconURL)
      
      if let iconData = iconData, let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
        let icon = UIImage(data: iconData)
        DispatchQueue.main.async(execute: { 
          cell.appIconImageView.image = icon
        })
      }
    }
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    if let view = view as? AppStoreCollectionSectionHeaderView {
      view.label.text = sections[(indexPath as NSIndexPath).section].rawValue
      view.button.setTitle("See All >", for: UIControlState())
      view.button.setTitleColor(UIColor.darkGray, for: UIControlState())
      view.delegate = self
    }
    return view
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let appData = self[appDetail: indexPath]
    print(appData.name)
    
    let appStoreViewerController = SKStoreProductViewController()
    appStoreViewerController.delegate = self
    appStoreViewerController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : appData.id], completionBlock: { (result, error) in
      print(result, error)
    })
    present(appStoreViewerController, animated: true, completion: nil)
  }
}

extension AppStoreCollectionViewLayoutDemoViewController: SKStoreProductViewControllerDelegate {
  func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    dismiss(animated: true, completion: nil)
  }
}

extension AppStoreCollectionViewLayoutDemoViewController: AppStoreCollectionSectionHeaderViewDelegate {
  func sectionHeaderViewDidTappedButton(_ view: AppStoreCollectionSectionHeaderView) {
    guard let indexPath = view.indexPath else {
      return
    }
    let section = sections[(indexPath as NSIndexPath).section]
    let alertController = UIAlertController(title: section.rawValue, message: "You tapped the \(section.rawValue) section.", preferredStyle: .alert)
    
    alertController.addAction(
      UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    )
    
    present(alertController, animated: true, completion: nil)
  }
}

struct AppDetail {
  let id: Int
  let name: String
  let iconURL: URL
  let price: Double
  
  init?(plistData: [String: AnyObject]) {
    guard let id = plistData["id"] as? Int, let name = plistData["name"] as? String,
      let iconURL = (plistData["iconURL"] as? String).flatMap(URL.init(string:)), let price = plistData["price"] as? Double else {
      return nil
    }
    
    self.id = id
    self.name = name
    self.iconURL = iconURL
    self.price = price
  }
}

class AppStoreCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var appIconImageView: UIImageView!
  @IBOutlet weak var appNameLabel: UILabel!
  @IBOutlet weak var appPriceLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    appIconImageView.layer.cornerRadius = 16.0
    appIconImageView.layer.masksToBounds = true
  }
}

