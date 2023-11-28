Pod::Spec.new do |spec|
  spec.name         = "OAFramework"
  spec.version      = "0.1.0"
  spec.summary      = "Single iOS Library for OAuth in popular social networks"
  spec.description  = "Single iOS Library for OAuth in popular social networks"
  spec.homepage     = "https://github.com/NaUKMA-Programistich/OAFramework"
  spec.license      = "MIT"
  spec.author       = { "Oleksii Dzhos" => "oleksii.dzhos@ukma.edu.ua" }
  spec.platform     = :ios
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/NaUKMA-Programistich/OAFramework", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.{h,m,swift}"
end
