//
//  ReportView.swift
//  Anbulance
//
//  Created by Selen Yanar on 9.04.2021.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseStorage


struct ReportView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var locationManager = LocationManager()
    let firebaseServices = FirebaseService()
    let latitude = CLLocationManager().location?.coordinate.latitude
    let longitude = CLLocationManager().location?.coordinate.longitude
    var postID = "\(Int.random(in: 10000...10000000000))"
    @State var db = Firestore.firestore()

    
    @State private var description: String = ""
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var textIsFilled = false
    
    var btnBack : some View {
        Button(
            action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        Text("< Geri")
            .foregroundColor(Color("AnbulanceBlue"))
        
    }
    }
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 300, height: 220, alignment: .center)
                    .cornerRadius(8)
                
                // DİSPLAY THE IMAGE
                if image != nil {
                    image?
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AnbulanceBlue"))  
                }
                
            }
            .padding(.bottom, 50.0)
            .offset(y: -20)
            .onTapGesture {
                // Select Image
                self.showingImagePicker = true
            }
            TextEditor(text: $description)
                .frame(width: 300, height: 200, alignment: .center)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                .foregroundColor(Color("AnbulanceBlue")) 
            Button(
                action: {
                    
                    if description == "" {
                        
                        textIsFilled.toggle()
                        
                    } else {
                        print("Yayınla")
                        //createPost()
                        uploadImageAndAddData()
                        firebaseServices.fetchData()
                        presentationMode.wrappedValue.dismiss()
                        
                    }
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 300, height: 50, alignment: .center)
                            .foregroundColor(Color("AnbulanceBlue"))
                            .cornerRadius(8)
                        Text("Yayınla")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                    }.padding(.top, 40.0)
                })
                .alert(isPresented: $textIsFilled, content: {
                    Alert(title: Text("Eksik bilgi"),
                          message: Text("Lütfen tüm alanları doldurun"),
                          dismissButton: .default(Text("Tamam")))
                })
            
            Button(
                action: {
                    print("İptal")
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 300, height: 50, alignment: .center)
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                        Text("İptal")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding()
                    }
                })
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        
    }
    
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func uploadImageAndAddData() {
        
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let data = inputImage.pngData()
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = riversRef.putData(data!, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
//            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                addData(imageUrl: downloadURL.absoluteString)
            }
        }

    }

    // Create Firebase Document
    func addData(imageUrl : String) {
        db.collection("posts").document(postID).setData([
            "postID": postID,
            "description": description,
            "latitude": latitude ?? 28.9,
            "longitude": longitude ?? 40.9 ,
            "imageUrl": imageUrl
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added successfully.")
            }
        }
    }
    

    struct ReportView_Previews: PreviewProvider {
        static var previews: some View {
            ReportView()
        }
    }
}


