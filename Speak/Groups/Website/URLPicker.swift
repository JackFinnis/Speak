//
//  WebsitePickerView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI

struct URLPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var webVM = WebVM()
    @FocusState var focused: Bool
    let completion: (URL) -> Void
    
    var body: some View {
        NavigationView {
            WebView(webVM: webVM)
                .ignoresSafeArea(edges: .bottom)
                .searchable(text: $webVM.text, placement: .navigationBarDrawer(displayMode: .always))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit(of: .search) {
                    webVM.submitUrl()
                }
                .navigationTitle("Enter Website")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    focused = true
                }
                .overlay(alignment: .bottom) {
                    if let url = webVM.url {
                        Button {
                            completion(url)
                            dismiss()
                        } label: {
                            Text("Import")
                                .bigButton()
                        }
                        .padding()
                    }
                }
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
