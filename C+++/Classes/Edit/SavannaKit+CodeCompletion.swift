//
//  SavannaKit+CodeCompletion.swift
//  C+++
//
//  Created by 23786 on 2020/10/1.
//  Copyright © 2020 Zhu Yixuan. All rights reserved.
//

import Cocoa

extension SKInnerTextView: CDCodeCompletionViewControllerDelegate {
    
    var translationUnit: CKTranslationUnit {
        return CKTranslationUnit(text: self.string, language: CKLanguageCPP)
    }
    
    func codeCompletionViewController(_ viewController: CDCodeCompletionViewController, didSelectItemWithTitle title: String, range: NSRange) {
        self.insertCompletion(title, forPartialWordRange: range, movement: NSTextMovement.return.rawValue, isFinal: true)
    }
    
    override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        
        if let string = string as? String {
            
            switch string {
                case "(": super.insertText(")", replacementRange: replacementRange)
                case "[": super.insertText("]", replacementRange: replacementRange)
                case "{": super.insertText("}", replacementRange: replacementRange)
                case "\"": super.insertText("\"", replacementRange: replacementRange)
                case "'": super.insertText("'", replacementRange: replacementRange)
                default:
                    self.complete(nil)
                    return
            }
            self.setSelectedRange(NSMakeRange(self.selectedRange.location - 1, 0))
            
        }
        
    }
    
    override func completions(forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String]? {
        
        if !CDSettings.shared.autoComplete {
            return [String]()
        }
       
        var completionResults = [CDCompletionResult]()
        
        let substring = self.string.nsString.substring(with: charRange)
        if substring == "" || !(substring.first ?? "\0").isLetter && (substring.first ?? "\0") != "_" {
            return [String]()
        }
        
        
        if charRange.length == 1 {
            
            let line = self.string.lineNumber(at: self.selectedRange.location) ?? 0
            let column = self.string.columnNumber(at: self.selectedRange.location)
            let results = self.translationUnit.completionResults(forLine: UInt(line), column: UInt(column))
            
            if results != nil {
                
                for result in results! {
                    
                    if let _result = result as? CKCompletionResult {
                        
                        let completionResult = CDCompletionResult(clangKitCompletionResult: _result)
                        completionResults.append(completionResult)
                        
                    }
                    
                }
                
            }
            
            var array = [CDCompletionResult]()
            for result in completionResults {
                let _result = result.typedText.lowercased().compareWith(anotherString: substring.lowercased())
                if _result.string == substring.lowercased() && substring.count != result.completionString.count {
                    result.matchedRanges = _result.range
                    array.append(result)
                }
            }
            completionResults = array
            
            self.lastTimeCompletionResults = completionResults
            
            
        } else {
            
            var array = [CDCompletionResult]()
            for result in lastTimeCompletionResults {
                let _result = result.typedText.lowercased().compareWith(anotherString: substring.lowercased())
                if _result.string == substring.lowercased() && substring.count != result.completionString.count {
                    result.matchedRanges = _result.range
                    array.append(result)
                }
            }
            completionResults = array
            
        }
        
        guard completionResults.count > 0 else {
            return [String]()
        }
        
        // DispatchQueue.main.async {
        
        
        if self.codeCompletionViewController == nil {
            self.codeCompletionViewController = CDCodeCompletionViewController()
            self.codeCompletionViewController.delegate = self
        } else {
            self.codeCompletionViewController.popover = nil
        }
        self.codeCompletionViewController.results = completionResults
        self.codeCompletionViewController.range = charRange
        var rect = self.layoutManager?.boundingRect(forGlyphRange: self.selectedRange, in: self.textContainer!)
        rect?.size.width = 1.0
        //  DispatchQueue.main.async {
        self.codeCompletionViewController.openInPopover(relativeTo: rect!, of: self, preferredEdge: .maxY)
        //   }
        
        //   }
        // print(String(format: "Time = %.7lf", -date.timeIntervalSinceNow))
        return [String]()
        
    }
    
}
