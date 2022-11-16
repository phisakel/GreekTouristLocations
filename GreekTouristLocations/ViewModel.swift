//
//  ViewModel.swift
//  GreekTouristLocations
//
//  Created by ffeli on 13/11/2022.
//

import Foundation
import CloudKit
import GPXKit

struct Region: Hashable {
  var name: String
  var rec: CKRecord?
}

struct Poi: Identifiable {
  var id: String { name }
  var name: String // name of poi
  var location: CLLocation
  var rec: CKRecord?
}

@MainActor
final class ViewModel: ObservableObject {
  var regions = [Region]()
  var pois = [Poi]()
  var track: GPXTrack!
  //var regionPois: [Region: [Poi]] = [:]
  lazy var container = CKContainer.default() // (identifier: "iCloud.gr.phisakel.GreekTouristLocations")
  lazy var database = container.publicCloudDatabase
  
  func getRegions() async throws -> [Region] {
      let predicate = NSPredicate(value: true)
      let query = CKQuery(recordType: "Region", predicate: predicate)
      let (matchResults, _) = try await database.records(matching: query)
      let regions = matchResults.compactMap { _, result in try? result.get() }.compactMap { Region(name: $0["name"] as! String)  }
      return regions
  }
  
  func getRegionPois(regionName: String) async throws -> [Poi] {
    let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: regionName), action: .none)
    let predicate = NSPredicate(format: "region == %@", reference)
    let query = CKQuery(recordType: "Poi", predicate: predicate)
    let (matchResults, _) = try await database.records(matching: query)
    let pois = matchResults.compactMap { _, result in try? result.get() }.compactMap { Poi(name: $0["name"] as! String, location: $0["location"] as! CLLocation) }
    return pois
  }
  
#if DEBUG
  func upload(_ track:GPXTrack) async throws {
    self.track = track
    for wp in track.waypoints! {
      guard let poi_name = wp.name else {continue}
      let c = wp.coordinate
      let region_name = poi_name.components(separatedBy: " ").first!
      var region = regions.first(where: {$0.name == region_name})
      if region == nil {
        region = Region(name: region_name)
        region!.rec = CKRecord(recordType: "Region", recordID: CKRecord.ID(recordName: region_name))
        region!.rec!["name"] = region_name
        regions.append(region!)
      }
      var poi = Poi(name: poi_name, location: CLLocation(latitude: c.latitude, longitude: c.longitude))
      poi.rec = CKRecord(recordType: "Poi", recordID: CKRecord.ID(recordName: poi_name))
      poi.rec!["name"] = poi_name
      poi.rec!["location"] = poi.location
      poi.rec!["region"] = CKRecord.Reference(record: region!.rec!, action: .none)
      pois.append(poi)
    }
    //upload to cloudkit
    let regionRecords = regions.compactMap(\.rec)
    let poiRecords = pois.compactMap(\.rec)
    let result1 = try await database.modifyRecords(saving: regionRecords, deleting: [], savePolicy: .allKeys)
    // Determine successfully saved records via inner Results.
    let savedRegions = result1.saveResults.values.compactMap { try? $0.get() }
    print("Saved ", savedRegions.map { $0.recordID }.count, " regions")
    let result2 = try await database.modifyRecords(saving: poiRecords, deleting: [], savePolicy: .allKeys)
    let savedPois = result2.saveResults.values.compactMap { try? $0.get() }
    print("Saved ", savedPois.map { $0.recordID }.count, " pois")
  }
  
  func testUploadGpxFile() async throws {
     guard let url = Bundle.main.url(forResource: "Tourist_locations_GR", withExtension: "gpx") else {
      fatalError("Failed to locate file in app bundle.")
    }
    let textXml = try String(contentsOf: url, encoding: .utf8)
    let parser = GPXFileParser(xmlString: textXml)
    switch parser.parse() {
    case .success(let track):
      try await upload(track)
    case .failure(let error):
      throw error
    }
  }
  #endif
}
