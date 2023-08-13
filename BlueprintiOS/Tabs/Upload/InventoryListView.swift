//
//  InventoryListView.swift
//  XCAInventoryTracker
//
//  Created by Alfian Losari on 30/07/23.
//

struct SignUpViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SignUpViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
     //   viewController.modalPresentationStyle = .fullScreen // Set modal presentation style
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
        // Not needed for this example
    }
}

import SwiftUI
import FirebaseAuth
import UIKit

struct InventoryListView: View {
    
    @StateObject var vm = InventoryListViewModel()
        
    @State var formType: FormType?
    
    @State private var showAlert = false // State variable to control whether the alert is shown
    @State private var showSignUp = false

    @State private var showCustomAlert = false

    
    var body: some View {
        // Check if there are no items to display
                    if vm.items.isEmpty {
                        if Auth.auth().currentUser != nil {
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.gray)
                                    .padding(.top, -110)
                                Text("Upload your first piece of content to Blueprint")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                   // .padding(.top, -10)
                                    .padding(.bottom, 12)
                                Button("+ Upload Item") {
                                    formType = .add
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .fontWeight(.semibold)
                                .font(.system(size: 15))
                                .cornerRadius(6)
//                                .frame(height: 45)
//                                .frame(width: UIScreen.main.bounds.width - 130)
                                .frame(maxWidth: .infinity)
                                .frame(minWidth: 300)
                                Spacer()
                            }
                            .navigationTitle("Uploads")
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button("+ Item") {
                                        formType = .add
                                     //   showCustomAlert.toggle()
                                    }
                                }
                            }
                            .background(
                                        ZStack {
                                            if showCustomAlert {
                                                Color.black.opacity(0.3)
                                                    .edgesIgnoringSafeArea(.all)
                                                    .onTapGesture {
                                                        showCustomAlert.toggle()
                                                    }
                                                CustomAlertView(isPresented: $showCustomAlert)
                                                    .transition(.move(edge: .bottom)) // Add this transition for bottom slide effect
                                            }
                                        }
                                    )
                            .sheet(item: $formType) { type in
                                NavigationStack {
                                    InventoryFormView(vm: .init(formType: type))
                                }
                                .presentationDetents([.fraction(0.85)])
                                .interactiveDismissDisabled()
                            }
                            
                            .onAppear {
                                vm.listenToItems()
                            }
                        } else {
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 110)
                                    .foregroundColor(.gray)
                                    .padding(.top, -120)
                                
                                Text("Sign in to view or upload your content")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .padding(.top, -10)
                                    .padding(.bottom, 12)

                                Button("Sign in") {
                                    showSignUp.toggle()
                                   
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .fontWeight(.semibold)
                                .font(.system(size: 15))
                                .cornerRadius(6)
//                                .frame(height: 45)
//                                .frame(width: UIScreen.main.bounds.width - 130)
                                .frame(maxWidth: .infinity)
                                .frame(minWidth: 300)
                                .fullScreenCover(isPresented: $showSignUp, content: SignUpViewControllerWrapper.init)
                                Spacer()
                            }
                            .navigationTitle("Uploads")
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button("+ Item") {
                                              showAlert.toggle() // Show the alert
                                    }
                                }
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Authentication Required"),
                                      message: Text("You need to sign in to upload an item."),
                                      primaryButton: .default(Text("Log in")) {
                                    // Handle log in action
                                    showSignUp.toggle()                                },
                                      secondaryButton: .cancel())
                            }
                        //    CustomUIView()
                        }
                        
                    } else {
                List {
//                    Section {
//                                   CustomUIView() // Adding the custom UIView here
//                               }
                    ForEach(vm.items) { item in
                        InventoryListItemView(item: item)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                formType = .edit(item)
                            }
                    }
                }
                .navigationTitle("Uploads")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("+ Item") {
                            if Auth.auth().currentUser != nil {
                                formType = .add
                                                    //showCustomAlert.toggle()
                                                } else {
                                                    showAlert.toggle()
                                                }
                        }
                    }
                }
                .background(
                            ZStack {
                                if showCustomAlert {
                                    Color.black.opacity(0.3)
                                        .edgesIgnoringSafeArea(.all)
                                        .onTapGesture {
                                            showCustomAlert.toggle()
                                        }
                                    CustomAlertView(isPresented: $showCustomAlert)
                                        .transition(.move(edge: .bottom)) // Add this transition for bottom slide effect
                                }
                            }
                        )
                .sheet(item: $formType) { type in
                    NavigationStack {
                        InventoryFormView(vm: .init(formType: type))
                    }
                    .presentationDetents([.fraction(0.85)])
                    .interactiveDismissDisabled()
                }
                .sheet(isPresented: $showCustomAlert) {
                    CustomAlertView(isPresented: $showCustomAlert)
                }
                .onAppear {
                    vm.listenToItems()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Authentication Required"),
                          message: Text("You need to sign in to upload an item."),
                          primaryButton: .default(Text("Log in")) {
                        // Handle log in action
                        showSignUp.toggle()                    },
                          secondaryButton: .cancel())
                }
            }
        }
}

struct InventoryListItemView: View {
    
    let item: InventoryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                        }
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .frame(width: 150, height: 150)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Group {
                    Text("Description: ")
                        .font(.subheadline)
                        .fontWeight(.semibold) +
                    Text("\(item.description)")
                        .font(.subheadline)
                }
                Group {
                    Text("Size: ")
                        .font(.subheadline)
                        .fontWeight(.semibold) +
                    Text("\(Int(ceil(item.size))) MB") // Round up the size to the nearest whole number
                        .font(.subheadline)
                }
                Group {
                    Text("Price: ")
                        .font(.subheadline)
                        .fontWeight(.semibold) +
                    Text(item.price == 0 ? "FREE" : "$\(String(format: "%.2f", item.price))") // Display "FREE" when price is 0
                        .font(.subheadline)
                }
            }
        }
    }
}

struct CustomUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 92, width: UIScreen.main.bounds.width, height: 0.5)
        customView.backgroundColor = UIColor.systemGray5
        return customView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Not needed for this example
    }
}

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Create")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                }
                .background(Color.white)
                
                HStack(spacing: 40) {
                    VStack {
                        Image(systemName: "view.3d")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                        
                        Text("Model")
                            .foregroundColor(.black)
                    }
                    
                    VStack {
                        Image(systemName: "globe.americas")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                        
                        Text("Portal")
                            .foregroundColor(.black)
                    }
                    
                    VStack {
                        Image(systemName: "mountain.2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                        
                        Text("Environment")
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(Color.white)
              //  .alignmentGuide(HorizontalAlignment.center) { d in d[.leading] }

                
                Divider()
                    .background(Color.black)
                    .padding(.horizontal)
                
                Button("Cancel") {
                    isPresented = false
                }
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    NavigationStack {
        InventoryListView()
    }
}
