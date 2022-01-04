# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'uberbiz' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Ignore all warning from pod
  inhibit_all_warnings!
  
  post_install do |pi|
      pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
        end
      end
  end

  # Pods for uberbiz
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'IQKeyboardManagerSwift', '~> 6.0.4'
  pod 'Alamofire', '~> 5.2'
  pod 'AlamofireImage'
  pod 'SVProgressHUD'
  pod 'SwiftyJSON'
  pod 'Shimmer'
  pod 'UITextView+Placeholder'
  
  # Firebase
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
end
