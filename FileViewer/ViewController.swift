//
//  ViewController.swift
//  FileViewer
//
//  Created by mac on 12/10/15.
//  Copyright © 2015 JY. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet weak var statusLabel: NSTextField!
  @IBOutlet weak var tableView: NSTableView!


  let sizeFormatter = NSByteCountFormatter()
  var directory:Directory?
  var directoryItems:[Metadata]?
  var sortOrder = Directory.FileOrder.Name
  var sortAscending = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    statusLabel.stringValue = ""
    
    tableView.setDataSource(self)
    tableView.setDelegate(self)
    
    // note: Double-click notifications are sent as an anction to the view target. Recive those notifications in the view controller, you need to set the table view 'target' and 'doubleAction' properties.
    // This tell table view that the view coontroller will become the target for this actions, and then it sets the method that will be called after a double-click.
    tableView.target = self
    tableView.doubleAction = "tableViewDoubleClick:"
    
    
    // Creat the sort descriptions:
    let descriptionName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
    let descriptionDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
    let descriptionSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
    
    // Add the sort description for the every colum by setting its 'sortDescriptorPrototype'
    tableView.tableColumns[0].sortDescriptorPrototype = descriptionName
    tableView.tableColumns[1].sortDescriptorPrototype = descriptionDate
    tableView.tableColumns[2].sortDescriptorPrototype = descriptionSize
  }
  
  override var representedObject: AnyObject? {
    didSet {
      if let url = representedObject as? NSURL {
//        print("Represented object: \(url)")
        directory = Directory(folderURL: url)
        reloadFileList()
      }
    }
  }
  
  func reloadFileList() {
    directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
    tableView.reloadData()
  }
  
  func updateStatus() {
    let text: String
    
    let itemsSelected = tableView.selectedRowIndexes.count
    
    if directoryItems == nil { text = "" }
    else if itemsSelected == 0 { text = "\(directoryItems!.count) items" }
    else { text = "\(itemsSelected) of \(directoryItems!.count) selected" }
    
    statusLabel.stringValue = text
  }
  
// MARK: tableView double-click action method
  func tableViewDoubleClick(sender: AnyObject) {

    // 1. If the table view selection is empty, or 'tableView.selectedRow' value equal to -1
    guard tableView.selectedRow >= 0 , let item = directoryItems?[tableView.selectedRow]
    else { return }
    
    // 2. If the item is a folder, it set a representedObject property to the item's url. The the table view refreshs to show the contents of that folder.
    if item.isFolder {
      self.representedObject = item.url;
    } else {
      // 3. If the item is a file, it open it in the defalut application by calling NSWorkspace method 'openUrl:'
      NSWorkspace.sharedWorkspace().openURL(item.url)
    }
    
  }

}



// MARK: NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
  
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return directoryItems?.count ?? 0
  }
  
  // MARK: When the user clicks on any column header, the table view will call the data source
  func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    
    // 1. Retrieves the first sort descriptor that corresponds to the column header clicked by the user.
    guard let sortDescriptor = tableView.sortDescriptors.first else { return }
    
    if let order = Directory.FileOrder(rawValue: sortDescriptor.key!) {
      // 2. Assigns the 'sortOrder' and 'sortAscending' propertis of the view controller, and tell table view reload the data
      sortOrder = order
      sortAscending = sortDescriptor.ascending
      
      reloadFileList()
    }
    
    reloadFileList()
  }
}

// MARK: NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var image: NSImage?
    var text: String = ""
    var cellIdentifier: String = ""
    
    // 1: If there is no date to display, it return no cell
    guard let item = directoryItems?[row] else { return nil }
    
    
    // 2: Based on the  column where the cell will display(Name, Date, Size), it sets the cell identifier, text and imageg
    if  tableColumn == tableView.tableColumns[0] {
      image = item.icon
      text = item.name
      cellIdentifier = "NameCellID"
    } else if tableColumn == tableView.tableColumns[1] {
      text = item.date.description
      cellIdentifier = "DateCellID"
    } else if tableColumn == tableView.tableColumns[2] {
      text = item.isFolder ? "--" : sizeFormatter.stringFromByteCount(item.size)
      cellIdentifier = "SizeCellID"
    }
    
    
    // 3: Creats or reuses a cell with that identifier.
    if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
      
      cell.textField?.stringValue = text
      cell.imageView?.image = image ?? nil
      
      return cell
    }
    
    return nil
  }
  
  func tableViewSelectionDidChange(notification: NSNotification) {
    updateStatus()
  }
}



















