//
//  MapView.swift
//  Anbulance
//
//  Created by Selen Yanar on 6.04.2021.
//

import MapKit
import SwiftUI
import Firebase

struct MapView: View {
    
    @ObservedObject private var locationManager = LocationManager()
    @State private var annotaionSelection: String? = nil
    @State private var showingAlert = false
    
    @State private var animalAnnotation: AnimalAnnotation? = nil
    @State private var shelterAnnotation: ShelterAnnotation? = nil
    @State var showReportView = false
    
    
    var body: some View {
        ZStack {
            
            
            // NAVIGATION LINK FOR ANIMAL DETAIL VIEW
            NavigationLink(destination: AnimalDetailView(animalAnnotation: animalAnnotation), tag: "animal_detail_view_tag", selection: $annotaionSelection) { EmptyView()
            }
            
            MapModel().onAnnotationTapped(perform: { annotation in
                
                // HERE YOU GET ANNOTATION TAPPED CALLBACKS
                if annotation is AnimalAnnotation {
                    self.animalAnnotation = annotation as? AnimalAnnotation
                    annotaionSelection = "animal_detail_view_tag"
                }else if annotation is ShelterAnnotation {
                    self.shelterAnnotation = annotation as? ShelterAnnotation
                    showingAlert = true
                }
                
            }).edgesIgnoringSafeArea(.all)
            
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(self.shelterAnnotation?.title ?? ""),
                      message: Text("Veteriner veya barınağı arayarak yaralı hayvanın durumunu bildir."),
                      primaryButton: .default(Text("Barınağı ara"),
                                              action: {callNumber(phoneNumber: "\(self.shelterAnnotation?.number ?? 0)" )}),
                      secondaryButton: .cancel(Text("İptal")))
            }
            
            Button(action: {
                showReportView.toggle()
            },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 300, height: 60, alignment: .center)
                        .foregroundColor(Color("AnbulanceBlue"))
                    Text("YARALI HAYVAN BİLDİR")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                }
            }).offset(y: 260)
            .sheet(isPresented: $showReportView,
                   content: {
                    ReportView()
                   })
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Çıkış yap") {
                    print("çıkış yap")
                    try! Auth.auth().signOut()
                    UserDefaults.standard.set(false,forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                    
                }
            }
        }.navigationBarHidden(false)
    }
}


private func callNumber(phoneNumber: String) {
    
    if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
        
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            if #available(iOS 10.0, *) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                application.openURL(phoneCallURL as URL)
                
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MapView()
        }
    }
}
