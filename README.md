# CollectionViewShelfLayout
A UICollectionViewLayout subclass displays its items as rows of items similar to the App Store Feature tab without a nested UITableView/UICollectionView hack. You can use a single data source for all of your contents. Each section displays its items in a row. `CollectionViewShelfLayout` supports collection view's *header view and footer view* similar to table view's *tableHeaderView and tableFooterView* also *sections' header and footer views* too.

![CollectionViewShelfLayout screenshot](https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/9666/CollectionViewShelfLayout_small.png)

# Requirements
- iOS 9+
- Swift 3.0+

This requirement is due to usage of some Auto Layout APIs available in iOS 8 and 9 or later.
 If you want to use `CollectionViewShelfLayout` in iOS 8, you can replace NSLayoutAnchor usage with other APIs.

# Installation
## Manaully
This project comes with built in *`CollectionViewShelfLayout framework`* target. You can drag `CollectionViewShelfLayout.xcproj` file into your project, add `CollectionViewShelfLayout framework` target as a target dependency and link/embed that framework. and Voila!!!
````swift
import CollectionViewShelfLayout
````
## CocoaPods
Add the following to your `Podfile`
````ruby
pod 'CollectionViewShelfLayout'
use_frameworks!
````
## Carthage
Add the following to your `Cartfile`
````ruby
github "pitiphong-p/CollectionViewShelfLayout"
````
## Swift 2
You can use CollectionViewShelfLayout in Swift 2.2 by checking out tag `0.5.5`

# Usage
Set collecion view's layout to an instance of `CollectionViewShelfLayout`. Set the layout's properties you want (eg. cellSize). You can set its layout both via code or `Storyboard`.
````swift
let shelfLayout = CollectionViewShelfLayout()
shelfLayout.itemSize = CGSize(width: 100, height: 180)
collectionView.collectionViewLayout = shelfLayout
````

# Demo App
`CollectionViewShelfLayout` project comes with a demo app target. You can see `CollectionViewShelfLayout` in action by just running `AppStoreCollectionViewLayout-Demo` demo app target.
# Contact
Pitiphong Phongpattranont
- [@pitiphong_p on Twitter] (https://twitter.com/pitiphong_p)

# License
`CollectionViewShelfLayout` is released under an MIT License.  
Copyright © 2016-present Pitiphong Phongpattranont.



