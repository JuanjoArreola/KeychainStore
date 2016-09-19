Pod::Spec.new do |s|
  s.name         = "KeychainStore"
  s.version      = "2.0"
  s.summary      = "Swift 2 Framework to access the Keychain in iOS"
  s.homepage     = "https://github.com/JuanjoArreola/KeychainStore"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juanjo Arreola" => "juanjo.arreola@gmail.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/JuanjoArreola/KeychainStore.git", :tag => "version_2.0" }
  s.source_files = "KeychainStore/*.swift"
  s.resources    = "KeychainStore/keychain_properties.plist"

  s.requires_arc = true
end
