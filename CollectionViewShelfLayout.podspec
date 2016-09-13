Pod::Spec.new do |s|

  s.name         = "CollectionViewShelfLayout"
  s.version      = "0.6.0"
  s.summary      = "A UICollectionViewLayout subclass displays as rows of items similar to App Store Feature tab without a nested UITable/CollectionView hack."

  s.description  = "A UICollectionViewLayout subclass displays its items as rows of items similar to the App Store Feature tab without a nested UITableView/UICollectionView hack. You can use a single data source for all of your contents. Each section displays its items in a row. CollectionViewShelfLayout supports collection view's header view and footer view similar to table view's tableHeaderView and tableFooterView also sections' header and footer views too."

  s.homepage     = "https://github.com/pitiphong-p/CollectionViewShelfLayout"
  s.screenshots  = "https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/9665/CollectionViewShelfLayout.png"

  s.license      = "MIT"

  s.author    = "Pitiphong Phongpattranont"
  s.social_media_url   = "http://twitter.com/pitiphong_p"

  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/pitiphong-p/CollectionViewShelfLayout.git", :tag => s.version }

  s.source_files  = ["CollectionViewShelfLayout/*.swift"]

end
