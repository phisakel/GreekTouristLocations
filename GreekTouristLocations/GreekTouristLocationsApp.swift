//
//  GreekTouristLocationsApp.swift
//  GreekTouristLocations
//
//  Created by ffeli on 13/11/2022.
//

import SwiftUI

@main
struct GreekTouristLocationsApp: App {
    var body: some Scene {
        WindowGroup {
            UploadDataView().environmentObject(ViewModel())
        }
    }
}
