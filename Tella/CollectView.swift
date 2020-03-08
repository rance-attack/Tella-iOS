//
//  CollectView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct CollectView: View {
    
    let back: Button<AnyView>
    
    var body: some View {
        return Group {
            bigText("COLLECT")
            back
        }
    }
}