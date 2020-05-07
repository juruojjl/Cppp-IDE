//
//  CDTableView.swift
//  C+++
//
//  Created by 23786 on 2020/5/7.
//  Copyright © 2020 Zhu Yixuan. All rights reserved.
//

import Cocoa

class CDTableView: NSView, CDTableViewCellInfoViewControllerDelegate {
    
    private let Code: KeyValuePairs = [
        "For Statement": "\nfor (int i = , i <= , i ++ ) {\n\t\n}",
        "If Statement": "\nif () {\n\t\n}",
        "While Statement": "\nwhile () {\n\t\n}",
        "If-else Statement": "\nif () {\n\t\n} else {\n\t\n}",
        "Struct Declaration": "\nstruct TNode {\n\tint a, b;\n\tTNode(int x, int y) { a = x; b = y; }\n};",
        "Switch Statement" : "\nswitch () {\n\tcase : break;\n\tcase : break;\n}",
        "Function Declaration": "\nvoid func(int a, ...) {\n\t\n}",
        "DFS Template": "\nvoid dfs(int t) {\n\tif (/*Reaches the End*/) {\n\t\t/*Output;*/\n\t\treturn;\n\t}\n\tfor (int i = ; /*Every Possible Answers*/; i ++) {\n\t\tif (!gVis[i]) {\n\t\t\tgVis[i] = 1; // Change\n\t\t\t// Do Something;\n\t\t\tdfs(t + 1);\n\t\t\tgVis[i] = 0; // Recover\n\t\t}\n\t}\n}",
        "Bubble Sort": "\nfor (int i = 1; i <= n - 1; i ++) {\n\tfor (int j = 1; j <= n - i; j ++) {\n\t\tif(a[j] < a[j + 1]) swap(a[j], a[j + 1]);\n\t}\n}",
        "Bucket Sort": "\nint a;\nfor (int i = 0; i < arr.count; i ++) {\n\tscanf(\"%d\", &a);\n\tn[a] += 1;\n}\n// output\nfor (int i = 0; i < arr.count; i ++) {\n\tfor(int j = 1; j <= n[i]; j ++)\n\t\tprintf(\"%d \", i);\n}",
        "Binary Search": "\nvoid binarySearch(int x) {\n\tint L = 1, R = MAXN, mid;\n\twhile (L < R) {\n\t\tmid = (L + R) / 2;\n\t\tif (x >= n[mid]) {\n\t\t\tL = mid;\n\t\t} else {\n\t\t\tR = mid - 1;\n\t\t}\n\t}\n\tprintf(\"%d\", n[L]);\n}",
        "More...": "Press the \"+\" button below \nand add your own code snippets."
    ]
    
    @objc func didRemoveItem(senderTitle: String) {
        
        for (index, cell) in self.cells.enumerated() {
            
            if cell.title == senderTitle {
                self.remove(at: index)
                break
            }
            
        }
        
    }
    
    var cells : [CDTableViewCell] = []
    
    override var isFlipped: Bool {
        return true
    }
    
    
    // MARK: - init
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        for (name, code) in Code {

            self.append(cell: CDTableViewCell(title: name, code: code))
            
        }
        
        
    }
    
    func append(cell: CDTableViewCell) {
        
        self.cells.append(cell)
        setup()
        
    }
    
    func remove(at index: Int) {
        
        self.cells.remove(at: index)
        setup()
        
    }
    
    
    
    private func setup() {
        
        var y: CGFloat = 0
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for (_, cell) in self.cells.enumerated() {
            
            cell.frame.origin = NSPoint(x: 0, y: y)
            cell.bounds.origin = NSPoint(x: 0, y: y)
            cell.titleLabel.frame.origin = NSPoint(x: 0, y: y)
            cell.titleLabel.bounds.origin = NSPoint(x: 0, y: y)
            self.addSubview(cell)
            y += cell.bounds.height - 1;
            print(cell.bounds)
            
        }
        
        let height: CGFloat = CGFloat(self.cells.count) * 44.0 + 50.0
        print(height)
        // self.bounds.size.height = height
        // self.frame.size.height = height
        // self.superview?.superview?.bounds.size.height = height
        // self.bounds.size = NSSize(width: self.bounds.width, height: height)
        // self.superview?.superview?.bounds.size = NSSize(width: self.bounds.width, height: height)
    }
    
}
