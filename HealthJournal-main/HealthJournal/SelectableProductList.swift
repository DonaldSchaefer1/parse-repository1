//
//  SelectableProductList.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
        return Image(uiImage: UIImage(data: data)!)
   .resizable()
  }
return self
.resizable()
}
}

struct SelectableProductList: View {
    var fetchRequest: FetchRequest<Product>
    let filterConfig: FilterConfig
    @Binding var selectedProducts: [Product]
    @State private var sheetIsPresented = false
    
    
    init(filterConfig: FilterConfig, selectedProducts: Binding<[Product]>) {
        self.filterConfig = filterConfig
        self._selectedProducts = selectedProducts
        if filterConfig.searchText != "" {
            let predicate = NSPredicate(format: "name BEGINSWITH %@", filterConfig.searchText)
            fetchRequest = FetchRequest<Product>(entity: Product.entity(), sortDescriptors: [], predicate: predicate)
        } else {
            fetchRequest = FetchRequest<Product>(entity: Product.entity(), sortDescriptors: [])
        }
    }
    
    var body: some View {
        if fetchRequest.wrappedValue.isEmpty {
            Button("Not in the pantry? Let's go shopping") {
                self.sheetIsPresented.toggle()
            }.sheet(isPresented: $sheetIsPresented) {
                Text("ShoppingView")
            }
        } else {
            List(fetchRequest.wrappedValue, id: \.self) { product in
                SelectableProductRow(product: product, selectedProducts: $selectedProducts)
            }
        }
    }
}

struct FilterConfig {
    var searchText = ""
    var sortedBy = "ASC"
}

struct SelectableProductRow: View {
     let product: Product
     @Binding var selectedProducts: [Product]
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    

     var body: some View {
         HStack {
             let url = URL(fileURLWithPath: paths).appendingPathComponent(product.imageLocation!)
             let string1 = "\(url)"
             /*
             if product.imageLocation != nil {
                 Image(product.imageLocation!)
                     .resizable()
                     .frame(width:50, height: 50)
             }
              */
             
             if product.imageLocation != nil {
                 Image(systemName: "placeholder image")
                 .data(url: URL(string: string1)!)
                 .resizable()
                 .frame(width:40, height: 40)
             }
             
             
             VStack(alignment: .leading) {
                 Text("\(product.ingredients)")
                     //.font(.title3)
                 Text("\(product.brand)")
                     .font(.caption)
             }

             Spacer()
             Button(action: {
                 if !selectedProducts.contains(product) {
                     self.selectedProducts.append(product)
                 } else {
                     self.removeProductFromSelectionsList()
                 }

             }) {
                 if selectedProducts.contains((product)) {
                     Image(systemName: "circle.fill")
                         .imageScale(.large)
                 } else {
                     Image(systemName: "circle")
                         .imageScale(.large)
                 }
             }
             
         }
     }
     
     func removeProductFromSelectionsList() {
         guard let index = self.selectedProducts.firstIndex(of: product) else {
             print("Something went wrong")
             return
         }
         self.selectedProducts.remove(at: index)
     }
    
    func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {

            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {}
            return nil
        }
    
    
    
}
     

