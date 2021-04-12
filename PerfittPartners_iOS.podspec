Pod::Spec.new do |s|
    s.name             = 'PerfittPartners_iOS'
    s.version          = '1.0.0-alpha24'
    s.summary          = 'PerfittPartners_iOS is camera lib'
    
    s.description      = <<-DESC
    'PerfittParnert_iOS is camera lib for partners'
    DESC
    
    s.homepage         = 'https://www.perfitt.io/'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'perfitt' => 'nick.cho@perfitt.io' }
    s.source           = { :git => 'https://github.com/perfitt-dev/perfitt-ios-partners.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '12.0'
    
    s.source_files = 'PerfittPartners_iOS/Classes/**/*'
    s.swift_version = '4.2'
    
    s.static_framework = true
    s.dependency 'TensorFlowLiteSwift', '~> 2.2.0'
    
    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    
    s.info_plist = {
        'CFBundleIdentifier' => 'org.cocoapods.PerfittPartners-iOS'
    }
    
    s.resource_bundles = {
        'PerfittPartners_iOS' => ['PerfittPartners_iOS/Assets/**/*']
    }
    
end
