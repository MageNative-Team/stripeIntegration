Pod::Spec.new do |spec|

  spec.name         = "stripeIntegration"
  spec.version      = "1.0.0"
  spec.swift_version = "5.0"
  spec.summary      = "Integrating stripe in your iOS app."
  spec.description  = "This is to integrate stripe in your iOS apps."
  spec.platform     = :ios, "15.0"
  spec.ios.deployment_target  = '15.0'
  spec.homepage     = "https://github.com/MageNative-Team/stripeIntegration.git"
  spec.license      = "MIT"
  spec.author             = { "Komal15B" => "komalbachani@magenative.com" }  
  spec.source       = { :git => "https://github.com/MageNative-Team/stripeIntegration.git", :tag => "#{spec.version}" }
  spec.source_files  = "stripeIntegration/**"
  spec.framework  = "UIKit"
  spec.dependency "SwiftyJSON"
  spec.dependency "Stripe" 
end
