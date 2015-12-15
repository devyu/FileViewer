//
//  WindowController.swift
//  FileViewer
//
//  Created by mac on 12/10/15.
//  Copyright © 2015 JY. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {


  @IBAction func openDocument(sender: AnyObject?) {
    
    let openPanel = NSOpenPanel()
    openPanel.showsHiddenFiles       = false // 显示隐藏文件
    openPanel.canChooseFiles         = false // 是否可以选择文件
    openPanel.canChooseDirectories   = true // open 指令
    
    openPanel.beginSheetModalForWindow(self.window!) {
      (response) -> Void in
      guard response == NSFileHandlingPanelOKButton else {
        return
      }
      self.contentViewController?.representedObject = openPanel.URL
    }
  }
}
