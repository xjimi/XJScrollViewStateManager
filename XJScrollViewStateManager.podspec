#
# Be sure to run `pod lib lint XJScrollViewStateManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJScrollViewStateManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of XJScrollViewStateManager.'
  s.homepage         = 'https://github.com/xjimi/XJScrollViewStateManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xjimi' => 'fn5128@gmail.com' }
  s.source           = { :git => 'https://github.com/xjimi/XJScrollViewStateManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'XJScrollViewStateManager/Classes/**/*'
  s.dependency 'DZNEmptyDataSet'
  s.dependency 'Reachability'

  s.frameworks = 'UIKit', 'Foundation'

  # s.resource_bundles = {
  #   'XJScrollViewStateManager' => ['XJScrollViewStateManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
end
