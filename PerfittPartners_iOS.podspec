#
# Be sure to run `pod lib lint PerfittPartners_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'PerfittPartners_iOS'
    s.version          = '1.0.0-alpha13'
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
    
    s.ios.deployment_target = '12.0'
    
    s.source_files = 'PerfittPartners_iOS/Classes/**/*'
    s.swift_version = '4.2'

    s.frameworks = 'UIKit', 'AVFoundation'
    
    s.static_framework = true
    s.dependency 'TensorFlowLiteSwift', '~> 2.2.0'
    
    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    
    s.info_plist = {
        'CFBundleIdentifier' => 'org.cocoapods.PerfittPartners-iOS'
    }
    
#     s.resources = 'Sources/PerfittPartners_iOS/**/*'
    s.resources = 'PerfittPartners_iOS/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
    
    s.resource_bundles = {
        'PerfittPartners_iOS' => ['PerfittPartners_iOS/Assets/**/*']
    }
    
end
