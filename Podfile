source 'https://cdn.cocoapods.org/'

platform :ios, '9.0'

def ht_pods
  pod 'GRDB.swift', '4.4.0'
end

target 'HyperTrack' do
  use_frameworks!

  ht_pods

  target 'SDKTest' do
    pod 'Fabric'
    pod 'Crashlytics'
  end
  
  target 'HyperTrackTests' do
    ht_pods
  end

  target 'Trips' do
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
    pod 'SnapKit'
    pod 'RxCoreLocation', '~> 1.4'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['GRDB.swift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
