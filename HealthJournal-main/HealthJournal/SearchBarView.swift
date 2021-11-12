//
//  SearchBarView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var filterConfig: FilterConfig
    @State private var isEditing = false
    @State private var cancelButtonIsShowing = false
    
    var body: some View {
        TextField("Search", text: $filterConfig.searchText)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .onTapGesture {
                self.isEditing = true
            }
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                    if isEditing {
                        Button(action: {
                            self.filterConfig.searchText = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                    
                }
            )
    }
}
