#
# Be sure to run `pod lib lint PerfittPartners_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PerfittPartners_iOS'
  s.version          = '1.0.0-alpha'
  s.summary          = 'PerfittPartners_iOS is camera lib'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'PerfittParnert_iOS is camera lib for partners'
                       DESC

  s.homepage         = 'https://www.perfitt.io/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'perfitt' => 'nick.cho@perfitt.io' }
  s.source           = { :git => 'https://github.com/perfitt-dev/perfitt-ios-partners.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.4'

  s.source_files = 'PerfittPartners_iOS/Classes/**/*.{swift,h,m,c}'
  s.public_header_files = 'PerfittPartners_iOS/Classes/**/*.{h,swift}'
  s.swift_version = '4.2'
  s.frameworks = 'UIKit'
  
  # s.resource_bundles = {
  #   'PerfittPartners_iOS' => ['PerfittPartners_iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
