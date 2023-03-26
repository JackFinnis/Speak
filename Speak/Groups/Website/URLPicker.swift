//
//  WebsitePickerView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI

struct URLPicker: View {
    @EnvironmentObject var filesVM: FilesVM
    @Environment(\.dismiss) var dismiss
    @StateObject var webVM = WebVM()
    let completion: (URL) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    if webVM.loading {
                        ProgressView()
                    }
                    WebView(webVM: webVM)
                }
                
                if let url = webVM.url {
                    Button {
                        completion(url)
                        dismiss()
                    } label: {
                        Text("Import")
                            .font(.headline)
                            .padding()
                            .horizontallyCentred()
                            .foregroundColor(.white)
                            .background(Color.accentColor.ignoresSafeArea())
                    }
                }
            }
            .interactiveDismissDisabled(webVM.url != nil)
            .ignoresSafeArea(edges: .bottom)
            .searchable(text: $webVM.text, placement: .navigationBarDrawer(displayMode: .always))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit(of: .search) {
                webVM.submitUrl()
            }
            .navigationTitle("Enter Website")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct URLPicker_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                URLPicker { url in
                    print(url.absoluteString)
                }
            }
    }
}
