//
//  WelcomeViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var userObj = AuthService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Schedulr")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Create an Account")
                    .font(.headline)

                Group {
                    TextField("Username", text: $userObj.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Email", text: $userObj.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $userObj.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding([.leading, .trailing], 16)

                Button(action: {
                    userObj.signUp(username: userObj.username, email: userObj.email, password: userObj.password)
                }) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding([.leading, .trailing], 16)

                HStack {
                    Text("Already have an account?")
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView()
}
