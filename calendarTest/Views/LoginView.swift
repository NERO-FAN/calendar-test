//
//  LoginViewController.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var viewModel = AuthService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let error = viewModel.errorMsg {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {viewModel.login(email: viewModel.email, password: viewModel.password)}) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationDestination(isPresented: $viewModel.isLoggedIn){
                MainTabBarView(viewModel: viewModel)
                    .environmentObject(dateHolder)
                    
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(DateHolder())
}
