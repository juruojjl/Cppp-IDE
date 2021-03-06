//
//  CDTextView.swift
//  C+++
//
//  Created by apple on 2020/3/23.
//  Copyright © 2020 Zhu Yixuan. All rights reserved.
//

import Cocoa

class CDCodeEditor: NSTextView, CDCodeCompletionViewControllerDelegate, CDHighlightDelegate {
    
    @IBOutlet weak var lineNumberView: CDCodeEditorLineNumberView!
    
    let highlightr = CDHighlightr()
    var scrollView: CDScrollView!
    var codeEditorDelegate: CDCodeEditorDelegate!
    weak var document: CDCodeDocument!
    var codeAttributedString: CDHighlightrAttributedString!
    var allowsSyntaxHighlighting: Bool = true
    var allowsCodeCompletion: Bool = true
    var codeCompletionViewController : CDCodeCompletionViewController!
    
    var translationUnit: CKTranslationUnit {
        
        return CKTranslationUnit(text: self.string, language: CKLanguageCPP)
        
    }
    
    
    
    open override func didChangeText() {
        
        super.didChangeText()
        
       /* if self.allowsSyntaxHighlighting {
            
            let selectedRange = self.selectedRange
            
            let highlightedCode = highlightr!.highlight(self.string, as: "C++")
            
            self.textStorage!.setAttributedString(highlightedCode!)
            self.setSelectedRange(selectedRange)
            
        } */
        
        DispatchQueue.main.async {
            
            self.lineNumberView?.draw()
            
            /*if CDSettings.shared.codeCompletion {
                self.complete(self)
            }*/
            
            self.codeEditorDelegate?.codeEditorDidChangeText!(lines: self.textStorage?.paragraphs.count ?? 0, characters: self.textStorage?.characters.count ?? 0)
            
        }
        
    }
    
    public var lineRects: [CGRect] {
        
        var array = [CGRect]()
        var location = 0
        for line in self.string.components(separatedBy: "\n") {
            let rect = self.layoutManager!.boundingRect(forGlyphRange: NSMakeRange(location, 0), in: self.textContainer!)
            if rect != NSMakeRect(0, 0, 0, 0) {
                array.append(rect)
            }
            location += line.count + 1
        }
        return array
        
    }
    
    
    
    
    /// Inserts the given string into the receiver, replacing the specified content. Overriden to support automatic completion.
    /// - Parameters:
    ///   - string: The text to insert, either an NSString or NSAttributedString instance.
    ///   - replacementRange: The range of content to replace in the receiver’s text storage.
    open override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        
        if CDSettings.shared.autoComplete == false {
            return
        }
        
        var right = ""
        switch string as! String {
            case "(":
                right = ")"
            case "[":
                right = "]"
            case "\"":
                right = "\""
            case "\'":
                right = "\'"
            case "{":
                insertNewline(self)
                let location = self.selectedRange.location
                insertNewline(self)
                deleteBackward(self)
                super.insertText("}", replacementRange: replacementRange)
                self.showFindIndicator(for: NSMakeRange(self.selectedRange.location - 1, 1))
                self.selectedRange.location = location
                return
            
            default:
                
                if CDSettings.shared.codeCompletion && self.allowsCodeCompletion {
                    self.complete(nil)
                }
                return
                
        }
        
        super.insertText(right, replacementRange: replacementRange)
        self.selectedRange.location -= 1
        self.showFindIndicator(for: NSMakeRange(self.selectedRange.location, 1))
        
    }
    
    
    
    /// When press ENTER, insert tabs.
    open override func insertNewline(_ sender: Any?) {
        super.insertNewline(sender)
        
        DispatchQueue.main.async {
            let line = self.string.lineNumber(at: self.selectedRange.location) ?? -1
            for i in 0 ..< self.lineNumberView.debugLines.count {
                // if self.lineNumberView.debugLines[i] >= line {
                    
                    // self.lineNumberView.debugLines[i] += 1
                // }
            }
        }
        
        guard CDSettings.shared.autoIndentation else {
            return
        }
        
        let nsstring = NSString(string: self.string)
        let string = nsstring.substring(to: self.selectedRange.location)
        let l = string.challenge("{")
        let r = string.challenge("}")
        let c = l - r
        if c > 0 {
            for _ in 1...c {
                self.insertText("\t", replacementRange: self.selectedRange)
            }
        }
        
    }
    
    open override func deleteBackward(_ sender: Any?) {
        if self.selectedRange.location == 0 && self.selectedRange.length == 0 {
            super.deleteBackward(sender)
            return
        }
        
        let string = self.string.nsString.substring(with: NSMakeRange(self.selectedRange.location + (self.selectedRange.length == 0 ? -1 : 0), self.selectedRange.length + (self.selectedRange.length == 0 ? 1 : 0)))
        super.deleteBackward(sender)
        
        DispatchQueue.main.async {
            let line = self.string.lineNumber(at: self.selectedRange.location) ?? -1
            let count = string.challenge("\n")
            for i in 0 ..< self.lineNumberView.debugLines.count {
                // if self.lineNumberView.debugLines[i] >= line + count {
                    // self.lineNumberView.debugLines[i] -= count
                // }
            }
        }
        
    }
    
    
    private var lastTimeCompletionResults = [CDCompletionResult]()
    
    open override func completions(forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String]? {
        
        // let date = Date()
        
        if !(self.allowsCodeCompletion) {
            return [String]()
        }
       
        var completionResults = [CDCompletionResult]()
        
        let substring = self.string.nsString.substring(with: charRange)
        if substring == "" || !(substring.first ?? "\0").isLetter {
            return [String]()
        }
        
        
        if charRange.length == 1 {
            
            let line = self.string.lineNumber(at: self.selectedRange.location) ?? 0
            let column = self.string.columnNumber(at: self.selectedRange.location)
            let results = self.translationUnit.completionResults(forLine: UInt(line), column: UInt(column))
            
            if results != nil {
                
                var returnType: String!
                var typedText = ""
                var otherTexts = [String]()
                var type: CDCompletionResult.ResultType = .other
                
                for result in results! {
                    if let _result = result as? CKCompletionResult {
                        
                        type = CDCompletionResult.ResultType.resultType(forCKCursorKind: _result.cursorKind)
                        
                        otherTexts = [String]()
                        
                        for chunk in _result.chunks {
                            if let _chunk = chunk as? CKCompletionChunk {
                                
                                switch _chunk.kind {
                                    case CKCompletionChunkKindResultType:
                                        returnType = _chunk.text
                                    case CKCompletionChunkKindTypedText:
                                        typedText = _chunk.text
                                    case CKCompletionChunkKindPlaceholder:
                                        otherTexts.append("{\(_chunk.text!)}")
                                    default:
                                        otherTexts.append(_chunk.text)
                                }
                                
                                
                            }
                            
                        }
                        
                       // let completionResult = CDCompletionResult(returnType: returnType, typedText: typedText, otherTexts: otherTexts)
                       // completionResult.type = type
                       // completionResults.append(completionResult)
                        
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
    
    
    func codeCompletionViewController(_ viewController: CDCodeCompletionViewController, didSelectItemWithTitle title: String, range: NSRange) {
        self.insertCompletion(title, forPartialWordRange: range, movement: NSTextMovement.return.rawValue, isFinal: true)
    }
    
    
    open override func complete(_ sender: Any?) {
        super.complete(sender)
    }
    
    
    open override func insertCompletion(_ word: String, forPartialWordRange charRange: NSRange, movement: Int, isFinal flag: Bool) {
        super.insertCompletion(word, forPartialWordRange: charRange, movement: movement, isFinal: flag)
        self.lastTimeCompletionResults = []
    }
    
    
    // MARK: - init(coder:)
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.textContainer?.size = NSSize(width: CGFloat(Int.max), height: CGFloat(Int.max))
        self.textContainer?.widthTracksTextView = false
        
        self.highlightr!.setTheme(to: CDSettings.shared.lightThemeName)
        self.highlightr!.theme.setCodeFont(CDSettings.shared.font)
        
        let textStorage = CDHighlightrAttributedString(highlightr: (self.highlightr ?? CDHighlightr()!))
        textStorage.language = "C++"
        textStorage.highlightDelegate = self
        self.layoutManager?.replaceTextStorage(textStorage)
        
    }
    
    /*
    override init(frame: NSRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.textContainer?.size = NSSize(width: CGFloat(Int.max), height: CGFloat(Int.max))
        self.textContainer?.widthTracksTextView = false
        
        self.highlightr!.setTheme(to: CDSettings.shared.lightThemeName)
        self.highlightr!.theme.setCodeFont(CDSettings.shared.font)
        
    }*/
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    public func shouldHighlight(_ range: NSRange) -> Bool {
        return self.allowsSyntaxHighlighting
    }
    
}
