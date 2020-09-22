//
//  CDSnippetTableViewDataSource.swift
//  C+++
//
//  Created by 23786 on 2020/9/20.
//  Copyright © 2020 Zhu Yixuan. All rights reserved.
//

import Cocoa

class CDSnippetTableViewDataSource: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    override init() {
        super.init()
    }
    
    private static let archievePath = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("C+++").appendingPathComponent("Snippets")
    
    static var savedSnippets: [CDSnippetTableViewCell] {
        return NSKeyedUnarchiver.unarchiveObject(withFile: archievePath.path) as! [CDSnippetTableViewCell]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("numberOfRows: \(CDSnippetTableViewDataSource.savedSnippets.count)")
        tableView.delegate = self
        return CDSnippetTableViewDataSource.savedSnippets.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Snippet"), owner: self) as? NSTableCellView {
            view.imageView?.image = CDSnippetTableViewDataSource.savedSnippets[row].image
            view.textField?.stringValue = CDSnippetTableViewDataSource.savedSnippets[row].title
            return view
        }
        return nil
    }
    
}
