//
//  Directory.swift
//  FileViewer
//
//  Created by mac on 12/10/15.
//  Copyright © 2015 JY. All rights reserved.
//

import AppKit

public struct Metadata : CustomDebugStringConvertible , Equatable {
  
  let name:String
  let date:NSDate
  let size:Int64
  let icon:NSImage
  let color:NSColor
  let isFolder:Bool
  let url:NSURL
  
  init(fileURL:NSURL, name:String, date:NSDate, size:Int64, icon:NSImage, isFolder:Bool, color:NSColor ) {
    self.name  = name
    self.date = date
    self.size = size
    self.icon = icon
    self.color = color
    self.isFolder = isFolder
    url = fileURL
  }
  
  public var debugDescription: String {
    return name + " " + "Folder: \(isFolder)" + " Size: \(size)"
  }
  
}

//MARK:  Metadata  Equatable
public func ==(lhs: Metadata, rhs: Metadata) -> Bool {
  return lhs.url.isEqual(rhs.url)
}


public struct Directory  {
  
  private var files = [Metadata]()
  let url:NSURL
  
  public enum FileOrder : String {
    case Name
    case Date
    case Size
  }
  
  public init( folderURL:NSURL ) {
    url = folderURL
    let requiredAttributes = [NSURLLocalizedNameKey, NSURLEffectiveIconKey,NSURLTypeIdentifierKey,NSURLCreationDateKey,NSURLFileSizeKey, NSURLIsDirectoryKey,NSURLIsPackageKey]
    if let enumerator = NSFileManager.defaultManager().enumeratorAtURL(folderURL, includingPropertiesForKeys: requiredAttributes, options: [.SkipsHiddenFiles, .SkipsPackageDescendants, .SkipsSubdirectoryDescendants], errorHandler: nil) {
      
      while let url  = enumerator.nextObject() as? NSURL {
        print( "\(url )")
        
        do{
          
          let properties = try  url.resourceValuesForKeys(requiredAttributes)
          files.append(Metadata(fileURL: url,
            name: properties[NSURLLocalizedNameKey] as? String ?? "",
            date: properties[NSURLCreationDateKey] as? NSDate ?? NSDate.distantPast(),
            size: (properties[NSURLFileSizeKey] as? NSNumber)?.longLongValue ?? 0,
            icon: properties[NSURLEffectiveIconKey] as? NSImage  ?? NSImage(),
            isFolder: (properties[NSURLIsDirectoryKey] as? NSNumber)?.boolValue ?? false,
            color: NSColor()))
        }
        catch {
          print("Error reading file attributes")
        }
      }
    }
  }
  
  
  func contentsOrderedBy(orderedBy:FileOrder, ascending:Bool) -> [Metadata] {
    let sortedFiles:[Metadata]
    switch orderedBy
    {
    case .Name:
      sortedFiles = files.sort{ return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending: ascending, attributeComparation:itemComparator(lhs:$0.name, rhs: $1.name, ascending:ascending)) }
    case .Size:
      sortedFiles = files.sort{ return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending, attributeComparation:itemComparator(lhs:$0.size, rhs: $1.size, ascending: ascending)) }
    case .Date:
      sortedFiles = files.sort{ return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending, attributeComparation:itemComparator(lhs:$0.date, rhs: $1.date, ascending:ascending)) }
    }
    return sortedFiles
  }
  
}

//MARK: - Sorting
func sortMetadata(lhsIsFolder lhsIsFolder:Bool, rhsIsFolder:Bool,  ascending:Bool , attributeComparation:Bool ) -> Bool
{
  if( lhsIsFolder && !rhsIsFolder) {
    return ascending ? true : false
  }
  else if ( !lhsIsFolder && rhsIsFolder ) {
    return ascending ? false : true
  }
  return attributeComparation
}

func itemComparator<T:Comparable>( lhs lhs:T, rhs:T, ascending:Bool ) -> Bool {
  return ascending ? (lhs < rhs) : (lhs > rhs)
}


//MARK: NSDate Comparable Extension
extension NSDate: Comparable {
  
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
  if lhs.compare(rhs) == .OrderedSame {
    return true
  }
  return false
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
  if lhs.compare(rhs) == .OrderedAscending {
    return true
  }
  return false
}