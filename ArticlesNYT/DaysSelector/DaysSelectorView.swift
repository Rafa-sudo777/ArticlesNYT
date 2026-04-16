//
//  DaysSelectorView.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

import SwiftUI

struct DaysSelectorView: View {
    @State private var days: String
    @State private var path: [String] = []
    @State private var showAlert = false

    init(days: String) {
        _days = State(initialValue: days)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                TextField("Ingresa un numero de dias", text: $days)
                    .font(.headline)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 15)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(showAlert ? Color.red : Color.gray, lineWidth: 1)
                    )
                Spacer()

                Button {
                    if days.isValidDay {
                        showAlert = false
                        path.append(days)
                    } else {
                        showAlert = true
                    }
                } label: {
                    Text("Buscar")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .alert("Por favor, ingrese un número válido de días", isPresented: $showAlert) {
            } message: {
                Text("Debe ser 1, 7 o 30")
            }
            .navigationDestination(for: String.self) { selectedDay in
                ArticlesListView(days: selectedDay)
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    DaysSelectorView(days: "")
}
