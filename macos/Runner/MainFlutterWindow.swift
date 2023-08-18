import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
      print("MainFlutterWindow")
      let testChannel = FlutterMethodChannel(name: "test/aa", binaryMessenger: flutterViewController.engine.binaryMessenger)
      testChannel.setMethodCallHandler{(call,result) in
          print("call.method=\(call.method)")
          self.requestWritePermission()
          
      }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
    private func requestWritePermission(){
        let fileManager = FileManager.default
        let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        print("applicationSupportURL=\(String(describing: applicationSupportURL))")
        
//        let openPanel = NSOpenPanel()
//               openPanel.canChooseDirectories = true
//               openPanel.canChooseFiles = false
//
//               openPanel.begin { (result) in
//                   if result == .OK, let url = openPanel.url {
////                       self.saveDirectoryPath(url.path)
//                       print("url=\(url)")
//                   }
//               }
        if let result = executeShellCommand("ls -l") {
            print(result)
        }
        
    }
    func executeShellCommand(_ command: String) -> String? {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
    }
}
