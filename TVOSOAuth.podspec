Pod::Spec.new do |s|

  s.platform = :tvos
  s.tvos.deployment_target = '9.0'
  s.name = "TVOSOAuth"
  s.summary = "TVOSOAuth OAuth service for tvOS apps using Authorization codes"
  s.requires_arc = true

  s.version = "0.1.0"

  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author = { "Rabah Shihab" => "rabah@bithunch.com" }


  s.homepage = "https://github.com/rabahs/tvos-oauth"


  s.source = { :git => "https://github.com/rabahs/tvos-oauth.git", :tag => "#{s.version}"}


  s.framework = "UIKit"
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'CryptoSwift'
  s.source_files = "TVOSOAuth/*.swift"
end
