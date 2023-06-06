//
//  NewJobView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/15/23.
//

import SwiftUI
import PhotosUI
struct NewJobView: View {
    @Binding var newJobPresented: Bool
    @StateObject var viewModel = NewJobViewViewModel()
    @State var ratingPlateImage: [PhotosPickerItem] = []
    @State var data: Data?
    var body: some View {
        // TODO: Replace photos picker with an option to take a photo
        // TODO: Ensure that the user is not sending in a diagnosticQuestion i.e. editing the firestore document before it is even created
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to diagnose problems with your water heater:")
                    .bold()
                    .padding(.leading, 10)
                    .padding(.top, 10)
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Find the rating plate of your water heater as pictured below.")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("2. Take a picture of the plate after clicking on the camera icon.")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("3. Ask about any issues your water heater is having.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 20)
                if let data = data, let uiimage = UIImage(data: data) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width,
                               height: 400)
                } else {
                    // Show rating plate example when a user has not yet uploaded an image
                    Image(uiImage: UIImage(named: "tankPlate")!)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width,
                               height: 400)
                }
                PhotosPicker(
                    selection: $ratingPlateImage,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    HStack{
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: 250, height: 60)
                                .foregroundColor(Color("Orange"))
                            HStack {
                                Text("Select picture")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                        Spacer()
                    }
                }
                .onChange(of: ratingPlateImage) { newValue in
                    guard let item = ratingPlateImage.first else {return}
                    item .loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data {
                                viewModel.recognizeText(data: data)
                                self.data = data
                            } else {
                                print("data is nil")
                            }
                        case .failure(let failure):
                            print(failure)
                            fatalError("failure")
                        }
                    }
                }
                HStack {
                    CustomTextField(placeholder: Text("Ask a question."), text: $viewModel.diagnosticQuestion)
                    Button {
                        viewModel.sendQuestion()
                        newJobPresented = false
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color("Orange"))
                            .cornerRadius(50)
                    }
                }
                .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("Gray"))
                    .cornerRadius(50)
                    .padding()
            }
        }
    }
}


struct NewJobView_Previews: PreviewProvider {
    static var previews: some View {
        NewJobView(newJobPresented: Binding(get: {
            return true
        }, set: { _ in
        })
        )
    }
}





