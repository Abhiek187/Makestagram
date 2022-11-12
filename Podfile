source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'Makestagram' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Makestagram
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Email'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Kingfisher'
  
  pod 'FBSDKLoginKit'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FirebaseUI/Facebook'
  
  pod 'GoogleSignIn'
  pod 'FirebaseUI/Google'
  
  pod 'JSQMessagesViewController'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Change the deployment target of all pods to match the project's target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      # As of Xcode 14, all signed pod bundles require a development team
      config.build_settings["DEVELOPMENT_TEAM"] = "UF6E5BVT98"
    end
  end
end
