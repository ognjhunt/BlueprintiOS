//
//  InventoryFormView.swift
//  XCAInventoryTracker
//
//  Created by Alfian Losari on 30/07/23.
//

import SafariServices
import SwiftUI
import UniformTypeIdentifiers

struct InventoryFormView: View {
    
    enum Tab {
        case basic, advanced
    }
    
    @StateObject var vm = InventoryFormViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: Tab = .basic

    
    // Create a @State variable for sizeString
        @State private var sizeString: String = ""
    
    // Add this property to your View struct
    @State private var showPrivacyOptions = false
    @State private var isPopoverPresented = false
    
    var body: some View {
//        VStack(spacing: 0) {
//            Picker("Tab", selection: $selectedTab) {
//                Text("Basic info").tag(Tab.basic)
//                Text("Advanced settings").tag(Tab.advanced)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal)
//            
//            if selectedTab == .basic {
//               // basicInfoSection
//            } else if selectedTab == .advanced {
//              //  advancedSettingsSection
//            }
            Form {
                List {
                    inputSection
                    arSection
                    
                    if case .deleting(let type) = vm.loadingState {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Deleting \(type == .usdzWithThumbnail ? "USDZ file" : "Item")")
                                    .foregroundStyle(.red)
                            }
                            Spacer()
                        }
                    }
                    
                    if case .edit = vm.formType {
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    try await vm.deleteItem()
                                    dismiss()
                                } catch {
                                    vm.error = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(vm.loadingState != .none)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    //change to upload in other mode
                    Button("Save") {
                        do {
                            try vm.save()
                            dismiss()
                        } catch {}
                    }
                    .disabled(vm.loadingState != .none || vm.usdzURL == nil || vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog("Add USDZ", isPresented: $vm.showUSDZSource, titleVisibility: .visible, actions: {
                Button("Select file") {
                    vm.selectedUSDZSource = .fileImporter
                }
                
                Button("Object Capture") {
                    vm.selectedUSDZSource = .objectCapture
                }
            })
            .fileImporter(isPresented: .init(get: { vm.selectedUSDZSource == .fileImporter }, set: { _ in
                vm.selectedUSDZSource = nil
            }), allowedContentTypes: [UTType.usdz], onCompletion: { result in
                switch result {
                case .success(let url):
                    Task { await vm.uploadUSDZ(fileURL: url) }
                case .failure(let failure):
                    vm.error = failure.localizedDescription
                }
            })
            .alert(isPresented: .init(get: { vm.error != nil}, set: { _ in vm.error = nil }), error: "An error has occured", actions: { _ in
            }, message: { _ in
                Text(vm.error ?? "")
            })
      //  }
        .navigationTitle(vm.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var inputSection: some View {
        Section {
            TextField("Name", text: $vm.name)
            TextField("Descripton", text: $vm.description)
            
//            TextField("Price", text: Binding<String>(
//                        get: { String(format: "%.2f", vm.price) },
//                        set: { newValue in
//                            if let value = Double(newValue) {
//                                vm.price = value
//                            }
//                        }
//                    ))
            TextField("Tags (e.g. nature, outer space, relaxing)", text: $vm.tags)
            HStack {
                Image(systemName: "globe.americas")
                    .foregroundColor(.black) // Set the color of the image
                Button("Public") {
                                    // Toggle the privacy options popover here
                                    isPopoverPresented.toggle()
                                }
                .foregroundColor(.primary)

                                .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                                    VStack {
                                        Button("Private") {
                                            // Handle choosing private option
                                            vm.privacy = "Private"
                                            isPopoverPresented.toggle()
                                        }
                                        .foregroundColor(.primary)
                                        
                                        Divider()
                                        
                                        Button("Cancel") {
                                            isPopoverPresented.toggle()
                                        }
                                        .foregroundColor(.primary)
                                    }
                                    .padding()
                                }
                }
            TextField("Price", text: Binding<String>(
                get: { String(format: "%.2f", vm.price) },
                set: { newValue in
                    if let value = Double(newValue) {
                        vm.price = value
                    }
                }
            ))
            .foregroundColor(Color.gray) // Set the text color to gray
            .padding(.horizontal, 10) // Add some horizontal padding for the whole TextField
            .overlay(
                HStack {
                    Text("Price:")
                        .foregroundColor(Color.gray)
                    Spacer()
                    Text("$") // Add the '$' symbol to the left
                        .foregroundColor(Color.black) // Set the '$' symbol color to gray
                      //  .padding(.leading, 5) // Add some left padding to the '$' symbol
                        .padding(.trailing, 10) // Add a flexible space to push the input to the right
                    TextField("0.00", text: Binding(
                                get: {
                                    String(format: "%.2f", vm.price)
                                },
                                set: { newValue in
                                    vm.price = Double(newValue) ?? 0.00
                                }
                            ))
                            .foregroundColor(Color.black) // Set the text color to black
                            .multilineTextAlignment(.trailing) // Align the text to the trailing edge
                }
            //    .padding(.horizontal, 10) // Add horizontal padding to the overlay content
                .background(Color.white) // Set the background color of the overlay
                .cornerRadius(5) // Apply corner radius to the overlay
            )
        }
        .disabled(vm.loadingState != .none)
    }
    
    var arSection: some View {
        Section("Content") {
            if let thumbnailURL = vm.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                        
                    case .failure:
                        Text("Failed to fetch thumbnail")
                    default: ProgressView()
                    }
                }
                .onTapGesture {
                    guard let usdzURL = vm.usdzURL else { return }
                    viewAR(url: usdzURL)
                }
            }
            
            if let usdzURL = vm.usdzURL {
                Button {
                    viewAR(url: usdzURL)
                } label: {
                    HStack {
                        Image(systemName: "photo").imageScale(.large)
                        Text("Choose thumbnail")
                    }
                }
                Button {
                    viewAR(url: usdzURL)
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text("View")
                    }
                }
                
                Button("Delete USDZ", role: .destructive) {
                    Task { await vm.deleteUSDZ() }
                }
                
            } else {
                Button {
                    vm.showUSDZSource = true
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text("Add USDZ")
                    }
                }
            }
            
            if let progress = vm.uploadProgress,
               case let .uploading(type) = vm.loadingState,
               progress.totalUnitCount > 0 {
                VStack {
                    ProgressView(value: progress.fractionCompleted) {
                        Text("Uploading \(type == .usdz ? "USDZ" : "Thumbnail") file \(Int(progress.fractionCompleted * 100))%")
                    }
                    
                    Text("\(vm.byteCountFormatter.string(fromByteCount: progress.completedUnitCount)) / \(vm.byteCountFormatter.string(fromByteCount: progress.totalUnitCount))")
                        .onAppear {
                            // Assign the value to the sizeString variable
                            sizeString = vm.byteCountFormatter.string(fromByteCount: progress.totalUnitCount)
                        }
                    
                }
            }
        }
        .disabled(vm.loadingState != .none)
    }
    
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
}

extension UIApplication {
    
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
    
}

#Preview {
    NavigationStack {
        InventoryFormView()
    }
}
