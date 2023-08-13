//
//  InventoryFormView.swift
//  XCAInventoryTracker
//
//  Created by Alfian Losari on 30/07/23.
//

import SafariServices
import SwiftUI
import UniformTypeIdentifiers
import UIKit

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
    
    @State private var isPrivacyOptionsVisible = false
    
    @State private var isPhotoPickerPresented = false
    @State private var showDeleteAlert = false // Add this

    
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
                    if case .edit = vm.formType {
                        Button("Save") {
                            do {
                                try vm.save()
                                dismiss()
                            } catch {}
                        }
                        .disabled(vm.loadingState != .none || vm.usdzURL == nil || vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Upload") {
                            do {
                                try vm.save()
                                dismiss()
                            } catch {}
                        }
                        .disabled(vm.loadingState != .none || vm.usdzURL == nil || vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
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
            .sheet(isPresented: $isPhotoPickerPresented) {
                ImagePicker(sourceType: .photoLibrary) { selectedImage in
                    // Handle the selected image here, you can set it as the new thumbnail
                    if let image = selectedImage {
                        vm.thumbnailImage = image
                    }
                }
            }
        
        
            .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Delete item?"),
                        message: Text("Are you sure you want to delete this item from Blueprint? It will remove ____ for all user's Blueprints."),
                        primaryButton: .default(Text("Delete")) {
                            Task {
                                await vm.deleteUSDZ()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            
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
                    .fontWeight(.heavy)

                Button("Public") {
                    // Toggle the privacy options here
                    isPrivacyOptionsVisible.toggle()
                }
                .fontWeight(.medium)
                .foregroundColor(.primary)
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
                        .foregroundColor(Color.primary)
                    Spacer()
                    TextField("$", text: .constant("$"))
                        .frame(width: 20) // Adjust the width of the "$" input field
                        .foregroundColor(Color.black) // Set the text color to black
                        .multilineTextAlignment(.trailing) // Align the text to the trailing edge
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
                    .background(Color.init(red: 240/255, green: 236/255, blue: 236/255)).opacity(0.85)
                }
             //   .padding(.horizontal, 10) // Add horizontal padding to the overlay content
                .background(Color.white) // Set the background color of the overlay
                .cornerRadius(5) // Apply corner radius to the overlay
            )


        
        if isPrivacyOptionsVisible {
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "globe.americas.fill")
                                .foregroundColor(.black) // Set the color of the image
                            Button("Public - Anyone can search for and view") {
                                vm.privacy = "Public"
                                isPrivacyOptionsVisible.toggle()
                            }
                            .foregroundColor(.primary)
                         //   .fontWeight(.medium)
                        }
                        
                       // Divider()
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.black) // Set the color of the image
                            Button("Private - Only you can view") {
                                vm.privacy = "Private"
                                isPrivacyOptionsVisible.toggle()
                            }
                            .foregroundColor(.primary)
                            //.fontWeight(.medium)
                        }
                        
                        Divider()
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black) // Set the color of the image
                            Button("Cancel") {
                                isPrivacyOptionsVisible.toggle()
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.white) // Optional background color
                    .cornerRadius(10) // Optional corner radius
                    .shadow(radius: 5) // Optional shadow
                    .frame(maxWidth: .infinity, alignment: .bottom) // Align the view at the bottom
                    .transition(.slide) // Optional transition effect
                }
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
//                        if let thumbnailImage = vm.thumbnailImage {
//                            Image(uiImage: thumbnailImage)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxWidth: .infinity, maxHeight: 300)
//                        }
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
                    // go to photo library of user, if we don't have permission, then ask - the chosen photo will become the new thumbnail
                    isPhotoPickerPresented.toggle()

                } label: {
                    HStack {
                        Image(systemName: "photo").imageScale(.large)
                        Text("Change thumbnail")
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
                    Task {
                        if case .edit = vm.formType {
                            showDeleteAlert = true
                        } else {
                            await vm.deleteUSDZ()
                        }
                    }
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
