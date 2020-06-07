//
//  CDDocumentController.swift
//  C+++
//
//  Created by 23786 on 2020/5/31.
//  Copyright © 2020 Zhu Yixuan. All rights reserved.
//

import Cocoa

class CDDocumentController: NSDocumentController {
    
    var isCreatingProject = false
    
    override var defaultType: String? {
        if isCreatingProject {
            return "C+++ Project"
        } else {
            return super.defaultType
        }
    }
    
}
