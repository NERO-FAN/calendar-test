//
//  LoginViewController.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var userObj = AuthService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Schedulr")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Sign in to continue")
                    .font(.headline)

                Group {
                    TextField("Email", text: $userObj.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $userObj.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding([.leading, .trailing], 16)

                Button(action: {
                    userObj.login(email: userObj.email, password: userObj.password)
                }) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding([.leading, .trailing], 16)
            }
            .padding()
            .navigationDestination(isPresented: $userObj.isLoggedIn) {
                MainTabBarView(userObj: userObj)
            }
        }
    }
}

#Preview {
    LoginView()
}
