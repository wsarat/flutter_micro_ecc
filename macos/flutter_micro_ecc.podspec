#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run 'pod lib lint flutter_micro_ecc.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_micro_ecc'
  s.version          = '0.0.1'
  s.summary          = 'A flutter interface to micro_ecc for ECDH key exchange.'
  s.description      = <<-DESC
A flutter interface to micro_ecc for ECDH key exchange.
                       DESC
  s.homepage         = 'https://swanav.github.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Swanav' => 'sswanav@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'
  s.platform = :macos, '10.14'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'GCC_PREPROCESSOR_DEFINITIONS[config=Debug]' => 'uECC_PLATFORM=6'
  }
  s.swift_version = '5.0'
end
