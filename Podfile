platform :ios, '10.2'
source 'https://github.com/kydonnelly/specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_modular_headers!

def shared_pods
  pod 'AWSS3', '2.26.3'
  pod 'Giphy', '2.1.8'
end

def pods
  pod 'Apollo', '0.27.1'
  pod 'AFNetworking', '4.0.1'
  pod 'KTDIconFont', '0.0.5'
  shared_pods
end

target 'Decidim' do
  pods
end

target 'DecidimTests' do
  pods
end

target 'com.cooperative4thecommunity.DecidimNotificationService' do
  shared_pods
end
