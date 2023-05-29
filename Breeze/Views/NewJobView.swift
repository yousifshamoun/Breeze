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
    var spinner = UIActivityIndicatorView(style: .large)
    @State var loading = false
    var body: some View {
        VStack {
            Text("New Job")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            Form {
                if let data = data, let uiimage = UIImage(data: data) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width,
                               height: 250)
                } else {
                    Image(uiImage: UIImage(named: "tankPlate")!)
                        .resizable()
                }
                PhotosPicker(
                    selection: $ratingPlateImage,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    HStack{
                        Spacer()
                        Text("Select picture")
                            .bold()
                            .font(.system(size: 16))
                        Image(systemName: "camera.fill")
                        Spacer()
                    }
                    .padding()
                }
                .listRowSeparator(.hidden)
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
                TextField("Ask any question... ", text: $viewModel.diagnosticQuestion)
                    .padding(.bottom)
            }
            Button {
                viewModel.sendQuestion()
                newJobPresented = false
            }
        label: {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 50,
                               height: 50)
                    Spacer()
                }
            }
        }
        .padding(.top)
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
