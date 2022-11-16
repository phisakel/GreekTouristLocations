//
//  MapView.swift
//  GreekTouristLocations
//
//  Created by ffeli on 16/11/2022.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapView: View {
  @State var regionName: String
  @State var pois: [Poi] = []
  @EnvironmentObject var vm: ViewModel

  @State private var map_region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.08, longitude: 22.175), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))

    var body: some View {
      Map(coordinateRegion: $map_region, annotationItems: pois) {
        MapMarker(coordinate: $0.location.coordinate) 
      }.task {
        do {
          pois = try await vm.getRegionPois(regionName: regionName)
          if pois.count > 0 { map_region.center = pois[pois.count/2].location.coordinate }
        }
        catch { print(error.localizedDescription) }
      }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
      MapView(regionName: "Achaia").environmentObject(ViewModel())
    }
}
