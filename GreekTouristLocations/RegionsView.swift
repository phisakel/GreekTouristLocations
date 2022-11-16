//
//  RegionsView.swift
//  GreekTouristLocations
//
//  Created by ffeli on 16/11/2022.
//

import SwiftUI

struct RegionsView: View {
  @State var regions: [Region] = []
  @State var showError = false
  @State var err: Error?
  @EnvironmentObject var vm: ViewModel
  
  var body: some View {
    NavigationView {
      List {
        ForEach(regions, id: \.self) { r in
          NavigationLink(r.name, destination: MapView(regionName :r.name))
        }
      }.task {
        do {
          regions = try await vm.getRegions()
        } catch { showError = true; err = error  }
      }.alert(err?.localizedDescription ?? "", isPresented: $showError) {
        Button("OK", role: .cancel) {}
      }.navigationBarTitle("Regions", displayMode: .inline)
    }
  }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView().environmentObject(ViewModel())
    }
}
