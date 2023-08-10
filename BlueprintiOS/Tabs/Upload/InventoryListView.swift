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
        viewController.modalPresentationStyle = .fullScreen // Set modal presentation style
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

    
    var body: some View {
        // Check if there are no items to display
                    if vm.items.isEmpty {
                        if Auth.auth().currentUser != nil {
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                Text("Upload your first piece of content to Blueprint")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Button("+ Upload Item") {
                                    formType = .add
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                Spacer()
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
                                .sheet(isPresented: $showSignUp) {
                                                        // Use the SignUpViewControllerWrapper here
                                                        SignUpViewControllerWrapper()
                                                    }
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
                        }
                        
                    } else {
                List {
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
                            } else {
                                formType = .add
                                
                                //                        // Display an alert here since the user is not authenticated
                                //                        showAlert.toggle() // Show the alert
                            }
                        }
                    }
                }
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
                    Text("\(item.size) MB")
                        .font(.subheadline)
                }
                Group {
                    Text("Price: ")
                        .font(.subheadline)
                        .fontWeight(.semibold) +
                    Text("$\(item.price)")
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InventoryListView()
    }
}
