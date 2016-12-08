Pod::Spec.new do |s|
  s.name         = "SGDTestLog"
  s.version      = "0.1.1"
  s.summary      = "Color test logger"
  s.homepage     = "https://github.com/Sangen/SGDTestLog"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Sangen"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Sangen/SGDTestLog.git", :tag => "v#{s.version}" }
  s.source_files = "Sources", "Sources/**/*.{h,m}"
  s.framework    = "XCTest"
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
