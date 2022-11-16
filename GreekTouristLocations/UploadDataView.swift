//
//  ContentView.swift
//  GreekTouristLocations
//
//  Created by ffeli on 13/11/2022.
//

import SwiftUI
import CloudKit
import AuthenticationServices

#if DEBUG
struct UploadDataView: View {
  @AppStorage("login") private var login = false
  @EnvironmentObject var vm: ViewModel
  
  var body: some View {
    VStack {
      Text("Login to save your data")
      SignInWithAppleButton(
        // Request User FullName and Email
        onRequest: { request in
          // You can change them if needed.
          request.requestedScopes = [.fullName, .email]
        },
        // Once user complete, get result
        onCompletion: { result in
          // Switch result
          switch result {
            // Auth Success
          case .success(let authResults):
            
            switch authResults.credential {
            case _ as ASAuthorizationAppleIDCredential:
               // Change login state
              self.login = true
              Task { try? await vm.testUploadGpxFile() }
            default:
              break
            }
          case .failure(let error):
            print("failure", error)
          }
        }
      )
      .signInWithAppleButtonStyle(.white) // Button Style
      .frame(width:350,height:50)         // Set Button Size (Read iOS 14 beta 7 release note)
      
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    UploadDataView().environmentObject(ViewModel())
  }
}
#endif
