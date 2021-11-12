//
//  CalorieCard.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/30/21.
//

import Foundation
import SwiftUI

struct CalorieCard: View {
    @ObservedObject var calorie: Calorie
    var body: some View {
        Text("calorie at \(calorie.datetime ?? Date.distantPast, formatter: calorieFormatter)")
        
    }
}


private let calorieFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

