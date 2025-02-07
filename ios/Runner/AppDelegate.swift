import UIKit
import Flutter
import Firebase
import GoogleMaps
import FirebaseMessaging
import PushKit
import flutter_callkit_incoming 

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //paste api key for google maps here 
    GMSServices.provideAPIKey("AIzaSyAm5Eb0_kae5XbHjfAeVBytKvkegzEpAW4")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    let mainQueue = DispatchQueue.main
    let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [PKPushType.voIP]
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
    print(credentials.token)
    let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
    //Save deviceToken to your server
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
}

func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    print("didInvalidatePushTokenFor")
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
}
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith")
        print(payload.dictionaryPayload)
        // let idValue = (payload.dictionaryPayload["aps"] as? [String: Any])?["id"] as? String ?? ""
        // print("ID1: \(idValue)")
        
        
        guard type == .voIP else { return }
        
        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let nameCaller = payload.dictionaryPayload["nameCaller"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
        let channelId = (payload.dictionaryPayload["extras"] as? [String: Any])?["channelId"] as? String ?? ""
        let callTime = (payload.dictionaryPayload["extras"] as? [String: Any])?["callTime"] as? Any ?? ""
        
        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller,handle:handle,  type: isVideo ? 1 : 0)
        //set more data
        data.extra = [ 
                       "channelId": channelId,
                       "callTime": callTime]
        //data.iconName = ...
        //data.....
        print(data)
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
        
        //Make sure call completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }  
}
