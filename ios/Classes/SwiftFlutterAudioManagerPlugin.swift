import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterAudioManagerPlugin: NSObject, FlutterPlugin {
  var channel : FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_audio_manager", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAudioManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.channel = channel;
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getCurrentOutput"){
            result(getCurrentOutput())
        }
        else if(call.method == "getAvailableInputs"){
            result(getAvailableInputs())
        }
        else if(call.method == "changeToSpeaker"){
            result(changeToSpeaker())
        }
        else if(call.method == "changeToReceiver"){
            result(changeToReceiver())
        }
        else if(call.method == "changeToHeadphones"){
            result(changeToBluetooth())
        }
        else if(call.method == "changeToBluetooth"){
            result(changeToBluetooth())
        }
        result("iOS " + UIDevice.current.systemVersion)
  }
  func getCurrentOutput() -> [String]  {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
//        print("hello \(currentRoute.outputs)")
        for output in currentRoute.outputs {
            return getInfo(output);
        }
        return ["unknow","0"];
    }
    
    func getAvailableInputs() -> [[String]]  {
        var arr = [[String]]()
        if let inputs = AVAudioSession.sharedInstance().availableInputs {
//            print("availableInputs \(inputs.count)")
            for input in inputs {
                arr.append(getInfo(input));
             }
        }
        return arr;
    }
    
    func getInfo(_ input:AVAudioSessionPortDescription) -> [String] {
//        print(input.portType)
        var type="0";
        let port = AVAudioSession.Port.self;
        switch input.portType {
        case port.builtInReceiver,port.builtInMic:
            type="1";
            break;
        case port.builtInSpeaker:
            type="2";
            break;
        case port.headsetMic,port.headphones:
            type="3";
            break;
        case port.bluetoothA2DP,port.bluetoothLE,port.bluetoothHFP:
            type="4";
            break;
        default:
            type="0";
        }
        return [input.portName,type];
    }
    
    func changeToSpeaker() -> Bool{
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        return true;
    }
    
    func changeToReceiver() -> Bool{
        return changeByPortType([AVAudioSession.Port.builtInMic])
    }
    
    func changeToHeadphones() -> Bool{
        return changeByPortType([AVAudioSession.Port.headsetMic])
    }
    
    func changeToBluetooth() -> Bool{
        let arr = [AVAudioSession.Port.bluetoothLE,AVAudioSession.Port.bluetoothHFP,AVAudioSession.Port.bluetoothA2DP];
        return changeByPortType(arr)
    }
    
    func changeByPortType(_ ports:[AVAudioSession.Port]) -> Bool{
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if(ports.firstIndex(of: output.portType) != nil){
                return true;
            }
        }
        if let inputs = AVAudioSession.sharedInstance().availableInputs {
            for input in inputs {
                if(ports.firstIndex(of: input.portType) != nil){
                    try?AVAudioSession.sharedInstance().setPreferredInput(input);
                    return true;
                }
             }
        }
        return false;
    }
    
    public override init() {
        super.init()
        registerAudioRouteChangeBlock()
    }
    
    func registerAudioRouteChangeBlock(){
        NotificationCenter.default.addObserver( forName:AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance(), queue: nil) { notification in
            guard let userInfo = notification.userInfo,
                let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                    return
            }
            print("registerAudioRouteChangeBlock \(reason)");
            self.channel!.invokeMethod("inputChanged",arguments: 1)
        }
    }
}
