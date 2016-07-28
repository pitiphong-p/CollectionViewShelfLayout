//
//  CollectionViewShelfLayout.swift
//  CollectionViewShelfLayout
//
//  Created by Pitiphong Phongpattranont on 7/26/2016.
//  Copyright © 2016 Pitiphong Phongpattranont. All rights reserved.
//

import UIKit
import CollectionViewShelfLayoutPrivate


private let ShelfElementKindCollectionHeader = "ShelfElementKindCollectionHeader"
private let ShelfElementKindCollectionFooter = "ShelfElementKindCollectionFooter"

/// An element kind of *Section Header*
public let ShelfElementKindSectionHeader = "ShelfElementKindSectionHeader"
/// An element kind of *Section Footer*
public let ShelfElementKindSectionFooter = "ShelfElementKindSectionFooter"


/// A collection view layout mimics the layout of the iOS App Store.
public class CollectionViewShelfLayout: UICollectionViewLayout {
  private var headerViewLayoutAttributes: CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes?
  private var footerViewLayoutAttributes: CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes?
  
  private var sectionsFrame: [CGRect] = []
  private var sectionsCellFrame: [CGRect] = []
  private var cellPanningScrollViews: [TrackingScrollView] = []
  
  private var sectionHeaderViewsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  private var sectionFooterViewsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  private var cellsLayoutAttributes: [[UICollectionViewLayoutAttributes]] = []
  
  /// A height of each section header. Set this value to 0.0 if you don't want section header views. Default is *0.0*
  @IBInspectable public var sectionHeaderHeight: CGFloat = 0.0
  /// A height of each section footer. Set this value to 0.0 if you don't want section footer views. Default is *0.0*
  @IBInspectable public var sectionFooterHeight: CGFloat = 0.0
  /// An inset around the cell area in each section inset from section header and footer view and the collection view's bounds. Default is *zero* on every sides.
  @IBInspectable public var sectionCellInset: UIEdgeInsets = UIEdgeInsetsZero
  /// A size of each cells.
  @IBInspectable public var cellSize: CGSize = CGSize.zero
  /// Horizontal spacing between cells. Default value is *8.0*
  @IBInspectable public var spacing: CGFloat = 8.0
  
  /// A header view of the collection view. Similar to table view's *tableHeaderView*
  @IBOutlet public var headerView: UIView?
  /// A footer view of the collection view. Similar to table view's *tableFooterView*
  @IBOutlet public var footerView: UIView?
  
  /// A boolean indicates that the layout is preparing for cell panning. This will be set to *true* when we invalidate layout by panning cells.
  private var preparingForCellPanning = false
  
  public override init() {
    super.init()
    registerClass(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionHeader)
    registerClass(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionFooter)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerClass(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionHeader)
    registerClass(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionFooter)
  }
  
  public override func prepareLayout() {
    defer {
      super.prepareLayout()
    }
    
    guard let collectionView = collectionView else {
      return
    }

    if preparingForCellPanning {
      self.preparingForCellPanning = false
      
      return
    }
    
    headerViewLayoutAttributes = nil
    footerViewLayoutAttributes = nil
    sectionsFrame = []
    sectionsCellFrame = []
    sectionHeaderViewsLayoutAttributes = []
    sectionFooterViewsLayoutAttributes = []
    cellsLayoutAttributes = []
    cellPanningScrollViews = []
    
    do {
      var currentY = CGFloat(0.0)
      let collectionBounds = collectionView.bounds
      let collectionViewWidth = collectionBounds.width
      if let headerView = headerView {
        headerViewLayoutAttributes = CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes(forDecorationViewOfKind: ShelfElementKindCollectionHeader, withIndexPath: NSIndexPath(index: 0))
        headerViewLayoutAttributes?.view = headerView
        let headerViewSize = headerView.systemLayoutSizeFittingSize(CGSize(width: collectionViewWidth, height: 0.0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        headerViewLayoutAttributes?.size = headerViewSize
        headerViewLayoutAttributes?.frame = CGRect(origin: CGPoint(x: collectionBounds.minX, y: currentY), size: headerViewSize)
        currentY += headerViewSize.height
      }
      
      let numberOfSections = collectionView.numberOfSections()
      for section in 0..<numberOfSections {
        let sectionMinY = currentY
        if sectionHeaderHeight > 0.0 {
          let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ShelfElementKindSectionHeader, withIndexPath: NSIndexPath(index: section))
          sectionHeaderAttributes.frame = CGRect(
            origin: CGPoint(x: collectionBounds.minX, y: currentY),
            size: CGSize(width: collectionBounds.width, height: sectionHeaderHeight)
          )
          sectionHeaderViewsLayoutAttributes.append(sectionHeaderAttributes)
          currentY += sectionHeaderHeight
        }
        
        var currentCellX = collectionBounds.minX + sectionCellInset.left
        
        currentY += sectionCellInset.top
        let topSectionCellMinY = currentY
        var cellInSectionAttributes: [UICollectionViewLayoutAttributes] = []
        for item in 0..<collectionView.numberOfItemsInSection(section) {
          let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: section))
          cellAttributes.frame = CGRect(
            origin: CGPoint(x: currentCellX, y: currentY),
            size: cellSize
          )
          currentCellX += cellSize.width + spacing
          cellInSectionAttributes.append(cellAttributes)
        }
        let sectionCellFrame = CGRect(
          origin: CGPoint(x: 0.0, y: topSectionCellMinY),
          size: CGSize(width: currentCellX - spacing + sectionCellInset.right, height: cellSize.height)
        )
        sectionsCellFrame.append(sectionCellFrame)
        
        cellsLayoutAttributes.append(cellInSectionAttributes)
        currentY += cellSize.height + sectionCellInset.bottom
        
        if sectionFooterHeight > 0.0 {
          let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ShelfElementKindSectionFooter, withIndexPath: NSIndexPath(index: section))
          sectionHeaderAttributes.frame = CGRect(
            origin: CGPoint(x: collectionBounds.minX, y: currentY),
            size: CGSize(width: collectionBounds.width, height: sectionFooterHeight)
          )
          sectionFooterViewsLayoutAttributes.append(sectionHeaderAttributes)
          currentY += sectionFooterHeight
        }
        
        let sectionFrame = CGRect(
          origin: CGPoint(x: 0.0, y: sectionMinY),
          size: CGSize(width: collectionViewWidth, height: currentY - sectionMinY)
        )
        sectionsFrame.append(sectionFrame)
        
        let panningScrollView = TrackingScrollView(frame: CGRect(origin: CGPointZero, size: sectionFrame.size))
        panningScrollView.delegate = self
        panningScrollView.trackingView = collectionView
        panningScrollView.trackingFrame = sectionCellFrame
        cellPanningScrollViews.append(panningScrollView)
      }
      
      if let footerView = footerView {
        footerViewLayoutAttributes = CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes(forDecorationViewOfKind: ShelfElementKindCollectionFooter, withIndexPath: NSIndexPath(index: 0))
        footerViewLayoutAttributes?.view = footerView
        let footerViewSize = footerView.systemLayoutSizeFittingSize(CGSize(width: collectionViewWidth, height: 0.0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        footerViewLayoutAttributes?.size = footerViewSize
        footerViewLayoutAttributes?.frame = CGRect(origin: CGPoint(x: collectionBounds.minX, y: currentY), size: footerViewSize)
        currentY += footerViewSize.height
      }
    }
  }
  
  public override func collectionViewContentSize() -> CGSize {
    guard let collectionView = collectionView else {
      return .zero
    }
    let width = collectionView.bounds.width
    let numberOfSections = CGFloat(collectionView.numberOfSections())
    
    let headerHeight = headerViewLayoutAttributes?.size.height ?? 0.0
    let footerHeight = footerViewLayoutAttributes?.size.height ?? 0.0
    let sectionHeaderHeight = self.sectionHeaderHeight * numberOfSections
    let sectionFooterHeight = self.sectionFooterHeight * numberOfSections
    
    let sectionCellInsetHeight = (sectionCellInset.bottom + sectionCellInset.top) * numberOfSections
    
    return CGSize(
      width: width,
      height: headerHeight + footerHeight + sectionHeaderHeight + sectionFooterHeight + sectionCellInsetHeight + (cellSize.height * numberOfSections)
    )
  }
  
  public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let headerAndFooterAttributes: [UICollectionViewLayoutAttributes] = [ headerViewLayoutAttributes, footerViewLayoutAttributes ].flatMap({ $0 }).filter { (attributes) -> Bool in
      return rect.intersects(attributes.frame)
    }
    
    let visibleSections = sectionsFrame.enumerate().filter({ (index: Int, element: CGRect) -> Bool in
      return rect.intersects(element)
    }).map({ $0.index })
    
    let visibleAttributes = visibleSections.flatMap { (section) -> [UICollectionViewLayoutAttributes] in
      var attributes: [UICollectionViewLayoutAttributes] = []
      if section < self.sectionHeaderViewsLayoutAttributes.count {
        let header = self.sectionHeaderViewsLayoutAttributes[section]
        if rect.intersects(header.frame) {
          attributes.append(header)
        }
      }
      
      let visibleCellAttributes = self.cellsLayoutAttributes[section].filter({ (attributes) -> Bool in
        return rect.intersects(attributes.frame)
      })
      
      attributes += visibleCellAttributes
      
      if section < self.sectionFooterViewsLayoutAttributes.count {
        let footer = self.sectionFooterViewsLayoutAttributes[section]
        if rect.intersects(footer.frame) {
          attributes.append(footer)
        }
      }
      
      return attributes
    }
    
    return visibleAttributes + headerAndFooterAttributes
  }
  
  public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    return cellsLayoutAttributes[indexPath.section][indexPath.row]
  }
  
  public override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    switch elementKind {
    case ShelfElementKindCollectionHeader:
      return headerViewLayoutAttributes
    case ShelfElementKindCollectionFooter:
      return footerViewLayoutAttributes
    default:
      return nil
    }
  }
  
  public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    switch elementKind {
    case ShelfElementKindSectionHeader:
      return sectionHeaderViewsLayoutAttributes[indexPath.section]
    case ShelfElementKindSectionFooter:
      return sectionFooterViewsLayoutAttributes[indexPath.section]
    default:
      return nil
    }
  }
  
  public override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
    if let context = context as? CollectionViewShelfLayoutInvalidationContext,
      let panningInformation = context.panningScrollView,
      let indexOfPanningScrollView = cellPanningScrollViews.indexOf(panningInformation) {
      
      let panningCellsAttributes = cellsLayoutAttributes[indexOfPanningScrollView]
      let minX = panningCellsAttributes.reduce(CGFloat.max, combine: { (currentX, attributes) in
        return min(currentX, attributes.frame.minX)
      }) - sectionCellInset.left
      
      let offset = -panningInformation.contentOffset.x - minX
      
      // UICollectionViewLayout will not guarantee to call prepareLayout on every invalidation.
      // So we do the panning cell translation in the invalidate layout so that we can guarantee that every panning will be accounted.
      panningCellsAttributes.forEach({ (attributes) in
        attributes.frame.offsetInPlace(dx: offset, dy: 0.0)
      })
      
      self.preparingForCellPanning = true
    }
    
    super.invalidateLayoutWithContext(context)
  }
  
  public override class func invalidationContextClass() -> AnyClass {
    return CollectionViewShelfLayoutInvalidationContext.self
  }
}


// MARK: - UIScrollViewDelegate methods

extension CollectionViewShelfLayout: UIScrollViewDelegate {
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    // Because we tell Collection View that it has its width of the content size equals to its width of its frame (and bounds).
    // This means that we can use its pan gesture recognizer to scroll our cells
    // Our hack is to use a scroll view per section, steal that scroll view's pan gesture recognizer and add it to collection view.
    // Uses the scroll view's content offset to tell us how uses scroll our cells
    guard let trackingScrollView = scrollView as? TrackingScrollView else { return }
    
    let context = CollectionViewShelfLayoutInvalidationContext(panningScrollView: trackingScrollView)
    invalidateLayoutWithContext(context)
  }
}


// MARK: - App Store Collection Layout Data Types
private class CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes: UICollectionViewLayoutAttributes {
  var view: UIView!
}

private class CollectionViewShelfLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
  private let panningScrollView: TrackingScrollView?
  
  override private var invalidateEverything: Bool {
    if panningScrollView == nil {
      return super.invalidateEverything
    } else {
      return false
    }
  }
  
  override private var invalidateDataSourceCounts: Bool {
    if panningScrollView == nil {
      return super.invalidateDataSourceCounts
    } else {
      return false
    }
  }
  
  override init() {
    self.panningScrollView = nil
  }
  
  init(panningScrollView: TrackingScrollView) {
    self.panningScrollView = panningScrollView
    
    super.init()
  }
}


// MARK: - Shelf Layout UICollectionReusableView

private class ShelfHeaderFooterView: UICollectionReusableView {
  var view: UIView? {
    willSet {
      view?.removeFromSuperview()
    }
    didSet {
      if let view = view {
        addSubview(view)
        view.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        view.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
      }
    }
  }
  
  private override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    if let layoutAttributes = layoutAttributes as? CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes {
      view = layoutAttributes.view
    }
    super.applyLayoutAttributes(layoutAttributes)
  }
}

private class TrackingScrollView: UIScrollView {
  weak var trackingView: UIView? {
    willSet {
      trackingView?.removeGestureRecognizer(panGestureRecognizer)
    }
    didSet {
      trackingView?.addGestureRecognizer(panGestureRecognizer)
      frame = trackingView?.bounds ?? .zero
    }
  }
  var trackingFrame: CGRect = CGRect.zero {
    didSet {
      contentSize = trackingFrame.size
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.contents = UIImage().CGImage
    panGestureRecognizer.maximumNumberOfTouches = 1
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.contents = UIImage().CGImage
    panGestureRecognizer.maximumNumberOfTouches = 1
  }
  
  @objc private override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer === self.panGestureRecognizer else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    let positionInTrackingView = panGestureRecognizer.locationInView(trackingView)
    return trackingFrame.contains(positionInTrackingView)
  }
  
  @objc private override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer === self.panGestureRecognizer else {
      return false
    }
    guard let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer where otherPanGestureRecognizer.delegate is TrackingScrollView && otherPanGestureRecognizer.view === trackingView else {
      return false
    }
    
    return true
  }
  
  @objc private override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where self.panGestureRecognizer === panGestureRecognizer else {
      return super.gestureRecognizer(gestureRecognizer, shouldReceiveTouch: touch)
    }
    
    let positionInTrackingView = touch.locationInView(trackingView)
    return trackingFrame.contains(positionInTrackingView)
  }
}


