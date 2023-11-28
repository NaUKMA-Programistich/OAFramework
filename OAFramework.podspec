Pod::Spec.new do |spec|
  spec.name         = "OAFramework"
  spec.version      = "0.1.0"
  spec.summary      = "iOS Framework with popular social"
  spec.description  = "Single iOS Library for OAuth in popular social networks"
  spec.homepage     = "https://github.com/NaUKMA-Programistich/OAFramework"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Oleksii Dzhos" => "oleksii.dzhos@ukma.edu.ua" }
  spec.platform     = :ios
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/NaUKMA-Programistich/OAFramework.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.{h,m,swift}"
  spec.swift_versions = ['5.7', '5.9']

  spec.dependency 'GoogleSignIn'
  spec.dependency 'FacebookLogin'
  spec.dependency 'FacebookCore'
  spec.dependency 'Logging'
  spec.dependency 'SwiftLint'
end
