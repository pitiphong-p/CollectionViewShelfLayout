//
//  AppStoreCollectionViewLayoutDemoViewController.swift
//  AppStoreCollectionViewLayout
//
//  Created by Pitiphong Phongpattranont on 7/26/2559 BE.
//  Copyright © 2559 Pitiphong Phongpattranont. All rights reserved.
//

import UIKit
import CollectionViewShelfLayout
import StoreKit

private let reuseIdentifier = "Cell"


protocol AppStoreCollectionSectionHeaderViewDelegate: class {
  func sectionHeaderViewDidTappedButton(view: AppStoreCollectionSectionHeaderView)
}

class AppStoreCollectionSectionHeaderView: UICollectionReusableView {
  let label: UILabel = UILabel()
  let button: UIButton = UIButton()
  var indexPath: NSIndexPath?
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    
    self.indexPath = layoutAttributes.indexPath
  }
  
  weak var delegate: AppStoreCollectionSectionHeaderViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    userInteractionEnabled = true
    
    backgroundColor = UIColor.whiteColor()
    label.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    addSubview(button)
    
    label.leadingAnchor.constraintEqualToAnchor(layoutMarginsGuide.leadingAnchor).active = true
    label.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    
    button.trailingAnchor.constraintEqualToAnchor(layoutMarginsGuide.trailingAnchor).active = true
    button.lastBaselineAnchor.constraintEqualToAnchor(label.lastBaselineAnchor).active = true
    
    button.leadingAnchor.constraintGreaterThanOrEqualToAnchor(label.trailingAnchor, constant: 8.0).active = true
    
    button.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
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
    let bundle = NSBundle(forClass: AppStoreCollectionViewLayoutDemoViewController.self)
    let appDataPListURL = bundle.URLForResource("Apps", withExtension: "plist")!
    let appDataPList = NSDictionary(contentsOfURL: appDataPListURL)! as! [String: [[String: AnyObject]]]
    
    var appData = [Section: [AppDetail]]()
    for (sectionName, apps) in appDataPList {
      let appDetails: [AppDetail]
      appDetails = apps.flatMap(AppDetail.init(plistData:))
      let section = Section(rawValue: sectionName)!
      appData[section] = appDetails
    }
    
    return appData
  }()
  
  subscript (appDetail indexPath: NSIndexPath) -> AppDetail {
    return appData[sections[indexPath.section]]![indexPath.row]
  }

  var sections: [Section] {
    return appData.keys.sort({ (firstSection, secondSection) in
      return firstSection.rawValue < secondSection.rawValue
    })
  }
  
  @IBOutlet var headerView: UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let layout = collectionView?.collectionViewLayout as? CollectionViewShelfLayout {
      layout.sectionCellInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
      
      headerView.translatesAutoresizingMaskIntoConstraints = false
      
      collectionView?.registerClass(AppStoreCollectionSectionHeaderView.self, forSupplementaryViewOfKind: ShelfElementKindSectionHeader, withReuseIdentifier: "Header")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return sections.count
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return appData[sections[section]]?.count ?? 0
  }
  
  let priceFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.currencyCode = "USD"
    formatter.numberStyle = NSNumberFormatterStyle.CurrencyAccountingStyle
    return formatter
  }()

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AppStoreCollectionViewCell
    let appDetail = self[appDetail: indexPath]
    cell.appNameLabel.text = appDetail.name
    cell.appPriceLabel.text = priceFormatter.stringFromNumber(appDetail.price)
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { 
      let iconData = NSData(contentsOfURL: appDetail.iconURL)
      
      if let iconData = iconData, let currentIndexPath = collectionView.indexPathForCell(cell) where currentIndexPath == indexPath {
        let icon = UIImage(data: iconData)
        dispatch_async(dispatch_get_main_queue(), { 
          cell.appIconImageView.image = icon
        })
      }
    }
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
    if let view = view as? AppStoreCollectionSectionHeaderView {
      view.label.text = sections[indexPath.section].rawValue
      view.button.setTitle("See All >", forState: .Normal)
      view.button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
      view.delegate = self
    }
    return view
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let appData = self[appDetail: indexPath]
    print(appData.name)
    
    let appStoreViewerController = SKStoreProductViewController()
    appStoreViewerController.delegate = self
    appStoreViewerController.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier : appData.id], completionBlock: { (result, error) in
      print(result, error)
    })
    presentViewController(appStoreViewerController, animated: true, completion: nil)
  }
}

extension AppStoreCollectionViewLayoutDemoViewController: SKStoreProductViewControllerDelegate {
  func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension AppStoreCollectionViewLayoutDemoViewController: AppStoreCollectionSectionHeaderViewDelegate {
  func sectionHeaderViewDidTappedButton(view: AppStoreCollectionSectionHeaderView) {
    guard let indexPath = view.indexPath else {
      return
    }
    let section = sections[indexPath.section]
    let alertController = UIAlertController(title: section.rawValue, message: "You tapped the \(section.rawValue) section.", preferredStyle: .Alert)
    
    alertController.addAction(
      UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    )
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}

struct AppDetail {
  let id: Int
  let name: String
  let iconURL: NSURL
  let price: Double
  
  init?(plistData: [String: AnyObject]) {
    guard let id = plistData["id"] as? Int, name = plistData["name"] as? String,
      iconURL = (plistData["iconURL"] as? String).flatMap(NSURL.init(string:)), price = plistData["price"] as? Double else {
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

