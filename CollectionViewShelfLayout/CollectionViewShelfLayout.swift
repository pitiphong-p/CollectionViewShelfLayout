//
//  CollectionViewShelfLayout.swift
//  CollectionViewShelfLayout
//
//  Created by Pitiphong Phongpattranont on 7/26/2016.
//  Copyright © 2016 Pitiphong Phongpattranont. All rights reserved.
//

import UIKit


private let ShelfElementKindCollectionHeader = "ShelfElementKindCollectionHeader"
private let ShelfElementKindCollectionFooter = "ShelfElementKindCollectionFooter"

/// An element kind of *Section Header*
public let ShelfElementKindSectionHeader = "ShelfElementKindSectionHeader"
/// An element kind of *Section Footer*
public let ShelfElementKindSectionFooter = "ShelfElementKindSectionFooter"


/// A collection view layout mimics the layout of the iOS App Store.
open class CollectionViewShelfLayout: UICollectionViewLayout {
  fileprivate var headerViewLayoutAttributes: CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes?
  fileprivate var footerViewLayoutAttributes: CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes?
  
  fileprivate var sectionsFrame: [CGRect] = []
  fileprivate var sectionsCellFrame: [CGRect] = []
  fileprivate var cellPanningScrollViews: [TrackingScrollView] = []
  
  fileprivate var sectionHeaderViewsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  fileprivate var sectionFooterViewsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  fileprivate var cellsLayoutAttributes: [[UICollectionViewLayoutAttributes]] = []
  
  /// A height of each section header. Set this value to 0.0 if you don't want section header views. Default is *0.0*
  @IBInspectable open var sectionHeaderHeight: CGFloat = 0.0
  /// A height of each section footer. Set this value to 0.0 if you don't want section footer views. Default is *0.0*
  @IBInspectable open var sectionFooterHeight: CGFloat = 0.0
  /// An inset around the cell area in each section inset from section header and footer view and the collection view's bounds. Default is *zero* on every sides.
  @IBInspectable open var sectionCellInset: UIEdgeInsets = UIEdgeInsets.zero
  /// A size of each cells.
  @IBInspectable open var cellSize: CGSize = CGSize.zero
  /// Horizontal spacing between cells. Default value is *8.0*
  @IBInspectable open var spacing: CGFloat = 8.0
  
  /// A header view of the collection view. Similar to table view's *tableHeaderView*
  @IBOutlet open var headerView: UIView?
  /// A footer view of the collection view. Similar to table view's *tableFooterView*
  @IBOutlet open var footerView: UIView?
  
  /// A boolean indicates that the layout is preparing for cell panning. This will be set to *true* when we invalidate layout by panning cells.
  fileprivate var preparingForCellPanning = false
  
  public override init() {
    super.init()
    register(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionHeader)
    register(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionFooter)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    register(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionHeader)
    register(ShelfHeaderFooterView.self, forDecorationViewOfKind: ShelfElementKindCollectionFooter)
  }
  
  open override func prepare() {
    defer {
      super.prepare()
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
    
    let oldPanningScrollViews = cellPanningScrollViews
    cellPanningScrollViews = []
    defer {
      oldPanningScrollViews.forEach({ $0.trackingView = nil })
    }
    
    do {
      var currentY = CGFloat(0.0)
      let collectionBounds = collectionView.bounds
      let collectionViewWidth = collectionBounds.width
      if let headerView = headerView {
        headerViewLayoutAttributes = CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes(forDecorationViewOfKind: ShelfElementKindCollectionHeader, with: IndexPath(index: 0))
        headerViewLayoutAttributes?.view = headerView
        let headerViewSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionViewWidth, height: 0.0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        headerViewLayoutAttributes?.size = headerViewSize
        headerViewLayoutAttributes?.frame = CGRect(origin: CGPoint(x: collectionBounds.minX, y: currentY), size: headerViewSize)
        currentY += headerViewSize.height
      }
      
      let numberOfSections = collectionView.numberOfSections
      for section in 0..<numberOfSections {
        let sectionMinY = currentY
        if sectionHeaderHeight > 0.0 {
          let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ShelfElementKindSectionHeader, with: IndexPath(index: section))
          sectionHeaderAttributes.frame = CGRect(
            origin: CGPoint(x: collectionBounds.minX, y: currentY),
            size: CGSize(width: collectionBounds.width, height: sectionHeaderHeight)
          )
          sectionHeaderViewsLayoutAttributes.append(sectionHeaderAttributes)
          currentY += sectionHeaderHeight
        }
        
        var currentCellX = collectionBounds.minX + sectionCellInset.left
        if section < oldPanningScrollViews.count {
          // Apply the old scrolling offset before preparing layout
          currentCellX -= oldPanningScrollViews[section].contentOffset.x
        }
        
        let cellMinX = currentCellX - sectionCellInset.left
        currentY += sectionCellInset.top
        let topSectionCellMinY = currentY
        var cellInSectionAttributes: [UICollectionViewLayoutAttributes] = []
        for item in 0..<collectionView.numberOfItems(inSection: section) {
          let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
          cellAttributes.frame = CGRect(
            origin: CGPoint(x: currentCellX, y: currentY),
            size: cellSize
          )
          currentCellX += cellSize.width + spacing
          cellInSectionAttributes.append(cellAttributes)
        }
        let sectionCellFrame = CGRect(
          origin: CGPoint(x: 0.0, y: topSectionCellMinY),
          size: CGSize(width: currentCellX - spacing + sectionCellInset.right - cellMinX, height: cellSize.height)
        )
        sectionsCellFrame.append(sectionCellFrame)
        
        cellsLayoutAttributes.append(cellInSectionAttributes)
        currentY += cellSize.height + sectionCellInset.bottom
        
        if sectionFooterHeight > 0.0 {
          let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ShelfElementKindSectionFooter, with: IndexPath(index: section))
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
        
        let panningScrollView = TrackingScrollView(frame: CGRect(origin: CGPoint.zero, size: sectionFrame.size))
        panningScrollView.delegate = self
        panningScrollView.trackingView = collectionView
        panningScrollView.trackingFrame = sectionCellFrame
        if section < oldPanningScrollViews.count {
          // Apply scrolling content offset with the old offset before preparing layout
          panningScrollView.contentOffset = oldPanningScrollViews[section].contentOffset
        }
                
        cellPanningScrollViews.append(panningScrollView)
      }
      
      if let footerView = footerView {
        footerViewLayoutAttributes = CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes(forDecorationViewOfKind: ShelfElementKindCollectionFooter, with: IndexPath(index: 0))
        footerViewLayoutAttributes?.view = footerView
        let footerViewSize = footerView.systemLayoutSizeFitting(CGSize(width: collectionViewWidth, height: 0.0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        footerViewLayoutAttributes?.size = footerViewSize
        footerViewLayoutAttributes?.frame = CGRect(origin: CGPoint(x: collectionBounds.minX, y: currentY), size: footerViewSize)
        currentY += footerViewSize.height
      }
    }
  }
    
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = collectionView else {
      return true
    }
    return collectionView.frame.size != newBounds.size
  }
  
  open override var collectionViewContentSize: CGSize {
    guard let collectionView = collectionView else {
      return .zero
    }
    let width = collectionView.bounds.width
    let numberOfSections = CGFloat(collectionView.numberOfSections)
    
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
  
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let headerAndFooterAttributes: [UICollectionViewLayoutAttributes] = [ headerViewLayoutAttributes, footerViewLayoutAttributes ].flatMap({ $0 }).filter { (attributes) -> Bool in
      return rect.intersects(attributes.frame)
    }
    
    let visibleSections = sectionsFrame.enumerated().filter({ (index: Int, element: CGRect) -> Bool in
      return rect.intersects(element)
    }).map({ $0.offset })
    
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
  
  open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cellsLayoutAttributes[indexPath.section][indexPath.row]
  }
  
  open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    switch elementKind {
    case ShelfElementKindCollectionHeader:
      return headerViewLayoutAttributes
    case ShelfElementKindCollectionFooter:
      return footerViewLayoutAttributes
    default:
      return nil
    }
  }
  
  open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    switch elementKind {
    case ShelfElementKindSectionHeader:
      return sectionHeaderViewsLayoutAttributes[indexPath.section]
    case ShelfElementKindSectionFooter:
      return sectionFooterViewsLayoutAttributes[indexPath.section]
    default:
      return nil
    }
  }
  
  open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    if let context = context as? CollectionViewShelfLayoutInvalidationContext,
      let panningInformation = context.panningScrollView,
      let indexOfPanningScrollView = cellPanningScrollViews.index(of: panningInformation) {
      
      let panningCellsAttributes = cellsLayoutAttributes[indexOfPanningScrollView]
      let minX = panningCellsAttributes.reduce(CGFloat.greatestFiniteMagnitude, { (currentX, attributes) in
        return min(currentX, attributes.frame.minX)
      }) - sectionCellInset.left
      
      let offset = -panningInformation.contentOffset.x - minX
      
      // UICollectionViewLayout will not guarantee to call prepareLayout on every invalidation.
      // So we do the panning cell translation in the invalidate layout so that we can guarantee that every panning will be accounted.
      panningCellsAttributes.forEach({ (attributes) in
        attributes.frame = attributes.frame.offsetBy(dx: offset, dy: 0.0)
      })
      
      self.preparingForCellPanning = true
    }
    
    super.invalidateLayout(with: context)
  }
  
  open override class var invalidationContextClass: AnyClass {
    return CollectionViewShelfLayoutInvalidationContext.self
  }
}


// MARK: - UIScrollViewDelegate methods

extension CollectionViewShelfLayout: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Because we tell Collection View that it has its width of the content size equals to its width of its frame (and bounds).
    // This means that we can use its pan gesture recognizer to scroll our cells
    // Our hack is to use a scroll view per section, steal that scroll view's pan gesture recognizer and add it to collection view.
    // Uses the scroll view's content offset to tell us how uses scroll our cells
    guard let trackingScrollView = scrollView as? TrackingScrollView else { return }
    
    let context = CollectionViewShelfLayoutInvalidationContext(panningScrollView: trackingScrollView)
    invalidateLayout(with: context)
  }
}


// MARK: - App Store Collection Layout Data Types

private class CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes: UICollectionViewLayoutAttributes {
  var view: UIView!
}

private class CollectionViewShelfLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
  fileprivate let panningScrollView: TrackingScrollView?
  
  override fileprivate var invalidateEverything: Bool {
    if panningScrollView == nil {
      return super.invalidateEverything
    } else {
      return false
    }
  }
  
  override fileprivate var invalidateDataSourceCounts: Bool {
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
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      }
    }
  }
  
  fileprivate override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    if let layoutAttributes = layoutAttributes as? CollectionViewShelfLayoutHeaderFooterViewLayoutAttributes {
      view = layoutAttributes.view
    }
    super.apply(layoutAttributes)
  }
}

private class TrackingScrollView: UIScrollView {
  weak var trackingView: UIView? {
    willSet {
      removeFromSuperview()
      trackingView?.removeGestureRecognizer(panGestureRecognizer)
    }
    didSet {
      trackingView?.addGestureRecognizer(panGestureRecognizer)
      translatesAutoresizingMaskIntoConstraints = false
      trackingView?.insertSubview(self, at: 0)
      frame = CGRect(origin: .zero, size: trackingView?.bounds.size ?? .zero)
    }
  }
  var trackingFrame: CGRect = CGRect.zero {
    didSet {
      contentSize = trackingFrame.size
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.contents = UIImage().cgImage
    panGestureRecognizer.maximumNumberOfTouches = 1
    isHidden = true
    alpha = 0.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.contents = UIImage().cgImage
    panGestureRecognizer.maximumNumberOfTouches = 1
    isHidden = true
    alpha = 0.0
  }
  
  @objc fileprivate override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, panGestureRecognizer === self.panGestureRecognizer else {
      return false
    }
    
    let positionInTrackingView = panGestureRecognizer.location(in: trackingView)
    return trackingFrame.contains(positionInTrackingView)
  }
  
  @objc fileprivate func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, panGestureRecognizer === self.panGestureRecognizer else {
      return false
    }
    guard let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer, otherPanGestureRecognizer.delegate is TrackingScrollView && otherPanGestureRecognizer.view === trackingView else {
      return false
    }
    
    return true
  }
  
  @objc fileprivate func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, self.panGestureRecognizer === panGestureRecognizer else {
      return false
    }
    
    let positionInTrackingView = touch.location(in: trackingView)
    return trackingFrame.contains(positionInTrackingView)
  }
}


