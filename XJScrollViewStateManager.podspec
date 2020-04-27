#
# Be sure to run `pod lib lint XJScrollViewStateManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJScrollViewStateManager'
  s.version          = '0.1.13'
  s.summary          = 'A short description of XJScrollViewStateManager.'
  s.homepage         = 'https://github.com/xjimi/XJScrollViewStateManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xjimi' => 'fn5128@gmail.com' }
  s.source           = { :git => 'https://github.com/xjimi/XJScrollViewStateManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'XJScrollViewStateManager/Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'DZNEmptyDataSet'

  s.resource_bundles = {
      s.name + '_resource_image' => ['XJScrollViewStateManager/Assets/*.xcassets'],
      s.name + '_resource_localizable' => ['XJScrollViewStateManager/Assets/Localizable/*.lproj/*']
  }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
end
