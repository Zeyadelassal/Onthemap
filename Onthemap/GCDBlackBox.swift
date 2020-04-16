//
//  GCDBlackBox.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/13/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(_ updates:@escaping ()->Void){
    DispatchQueue.main.async {
        updates()
    }
}
