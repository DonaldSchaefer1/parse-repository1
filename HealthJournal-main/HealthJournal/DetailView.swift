//
//  DetailView.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/30/21.
//

import Foundation
import SwiftUI

struct DetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var calorie: Calorie
    
    var body: some View {
        VStack {
            CalorieCard(calorie: calorie)
            //Toggle(isOn: $calorie.name, label: {
            //Text("Is Name")
            //})
        }
        .padding()
    }
}
