//
//  MedusaServerView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI

struct MedusaServer: View {
    let function: (_: Bool, _: String?, _: String?) -> Void
    @Bindable var viewModel = MedusaServerViewModel()

    @State var url = ""
    var body: some View {
        Section {
            LabeledContent("Medusa URL") {
                TextField("https://…", text: $viewModel.url)
                    .keyboardType(.URL)
            }
            LabeledContent {
                TextField("\("user@example.com")", text: $viewModel.email)
                    .keyboardType(.emailAddress)
            } label: {
                Text("E-Mail")
            }

            LabeledContent {
                SecureField("Required", text: $viewModel.password)
                    .keyboardType(.emailAddress)
            } label: {
                Text("Password")
            }
        }
        .textInputAutocapitalization(.never)
        .onChange(of: viewModel.url) { _, _ in
            viewModel.userInput()
        }
        .onChange(of: viewModel.email) { _, _ in
            viewModel.userInput()
        }
        .onChange(of: viewModel.password) { _, _ in
            viewModel.userInput()
        }

        Section {
            if viewModel.loading {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Testing Connection")
                    Spacer()
                }
            } else if viewModel.success {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                    Text("Test OK")
                    Spacer()
                }
            } else if viewModel.error != nil {
                if let error = viewModel.error {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                        Text(error)
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                        Text("Unknown Error")
                        Spacer()
                    }
                }

            } else {
                Button {
                    
                } label: {
                    Text("Test Connection")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var success = false
    Form {
        MedusaServer { _, _, _ in
        }
    }
}
