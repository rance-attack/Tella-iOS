//
//  ContentView.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentView: MainViewEnum = .MAIN
    var back: Button<AnyView> {
        return backButton { self.currentView = .MAIN }
    }
    
    func getMainView() -> AnyView {
        return AnyView(Group {
            // title row
            HStack {
                bigText("TELLA")
                Spacer()
                Button(action: {
                    print("shutdown button pressed")
                }) {
                    bigImg(.SHUTDOWN)
                }
            }
            Spacer()
            // center buttons
            VStack {
                bigLabeledImageButton(.CAMERA, "CAMERA") {
                    self.currentView = .CAMERA
                }
                bigLabeledImageButton(.RECORD, "RECORD") {
                    self.currentView = .RECORD
                }
            }
            Spacer()
            // bottom buttons
            HStack {
                smallLabeledImageButton(.COLLECT, "Collect") {
                    self.currentView = .COLLECT
                }
                Spacer()
                smallLabeledImageButton(.GALLERY, "Gallery") {
                    self.currentView = .GALLERY
                }
            }
            // settings button
            Button(action: {
                self.currentView = .SETTINGS
            }) {
                smallImg(.SETTINGS)
            }
        })
    }
    
    func getViewContents(_ currentView: MainViewEnum) -> AnyView {
        switch currentView {
        case .MAIN:
            return getMainView()
        case .CAMERA:
            return AnyView(CameraView(back: back))
        case .COLLECT:
            return AnyView(CollectView(back: back))
        case .RECORD:
            return AnyView(RecordView(back: back))
        case .SETTINGS:
            return AnyView(SettingsView(back: back))
        case .GALLERY:
            return AnyView(GalleryView(back: back))
        }
    }
    
    var body: some View {
        return VStack {
            getViewContents(currentView)
        }
            .padding(20)
            .background(Color.black)
    }
}

struct ontentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
