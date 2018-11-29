Pod::Spec.new do |s|
  s.name             = 'SwiftDragAndDrop'
  s.version          = '0.2.4'
  s.summary          = 'Simple Drag and Drop component of multiple UITableView written in Swift'

  s.homepage         = 'https://github.com/uyphanha/SwiftDragAndDrop'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Phanha UY' => 'uyphanha.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/uyphanha/SwiftDragAndDrop.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/PhanhaUY'

  s.swift_version = '4'
  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*'
end
