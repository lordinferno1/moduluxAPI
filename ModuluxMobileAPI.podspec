#
#  Be sure to run `pod spec lint ModuluxMobileAPI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ModuluxMobileAPI"
  s.version      = "0.0.6"
  s.summary      = "Modulux Mobile Api used for iOS basic behaviours"
  s.description  = "Used for internal use, but feel free to used it anywhere"
  s.homepage     = "https://github.com/lordinferno1/moduluxAPI"
  s.license      = "MIT"

  s.author             = { "Jonathan Silva" => "jhi.290292@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/lordinferno1/moduluxAPI.git", :tag => "#{s.version}" }

  s.source_files  = "ModuluxMobileApi", "ModuluxMobileApi/**/*.{h,m,swift}"
  s.exclude_files = "ModuluxMobileAPI/testingPlists/*"
  # s.requires_arc = true
  # s.dependency "JSONKit", "~> 1.4"
  s.dependency "Alamofire", "~> 4.4"
end
