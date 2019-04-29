Pod::Spec.new do |s|
  s.name         = "KeychainStore"
  s.version      = "3.0.4"
  s.summary      = "Swift Framework to access the Keychain in iOS"
  s.homepage     = "https://github.com/JuanjoArreola/KeychainStore"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juanjo Arreola" => "juanjo.arreola@gmail.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/JuanjoArreola/KeychainStore.git", :tag => "#{s.version}" }
  s.source_files = "Sources/KeychainStore/*.swift"

  s.requires_arc = true
  s.swift_version = '4.1'
end
