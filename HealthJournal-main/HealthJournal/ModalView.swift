//
//  ModalView.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 11/10/21.
//

import Foundation
import SwiftUI
import CoreData



struct ModalView: View {

    @Binding var showModal: Bool
    @State var meal1text: String = ""
    @FocusState private var meal1textIsFocused: Bool
    @State var numberOfItems: Int = 0
    @State var showImagePicker: Bool = false
    @State var image2: Image? = nil
    @State var mealtext: String = ""
    

    var body: some View {
        VStack {
        Form {
            Section(header: Text("Add New Ingredient")) {
            HStack {
            Text("Ingredient:     ")
                .font(.callout)
            TextField("Ingredient:    ", text: $meal1text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 140)
                .focused($meal1textIsFocused)
            }
            HStack {
            Text("Portions:    ")
                .font(.callout)
            Stepper(value: $numberOfItems, in: 0...9, label: { Text("  \(numberOfItems)")})
            .padding(.horizontal, 36)
            }
            HStack {
            Text("Photo/Image:      ")
                    .font(.callout)
            Button(action: {
            self.showImagePicker.toggle()
            }) {
            Image(systemName: "photo")
            }
            image2?.resizable().frame(width: 80, height: 40)
            }
            .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
            self.image2 = Image(uiImage: image)

                }
            }
            Spacer()
                HStack {
            Button(action: {
                }) {
                Text("Save                        ")
                .frame(width: 40)
                .onTapGesture {
                meal1textIsFocused = false
                SaveProduct(namestr: mealtext, ingredientstr: meal1text, image1: image2!)
            }
            }
            
            Button("                       Back") {
                self.showModal.toggle()
            }
            }
        //}
        
        }
        }
        }
        
        
        
      
       // VStack {
            //Text("Inside //Modal View")
            //    .padding()
            
           // Button("Dismiss") {
            //    self.showModal.toggle()
           // }
       // }
    }
}

func SaveProduct(namestr: String, ingredientstr: String, image1: Image)
{
    
        lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "HealthJournal")
          container.loadPersistentStores { _, error in
            if let error = error as NSError? {
              // You should add your own error handling code here.
              fatalError("Unresolved error \(error), \(error.userInfo)")
            }
          }
          return container
        }()
        
        func saveContext() {
          let context = persistentContainer.viewContext
          if context.hasChanges {
            do {
              try context.save()
            } catch {
              // The context couldn't be saved.
              // You should add your own error handling here.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
          }
        }
    
        let image2: Image = image1 // Create an Image anyhow you want
        let uiImage: UIImage = image2.asUIImage()
        var uiImage1: UIImage
        var strrandom: String
        var pngname: String
        var namestr: String
        
        uiImage1 = scaleImage(uiImage)

        strrandom = randomString(length: 8)
        pngname = strrandom
      
    
         saveImageToDocumentDirectory(image1: uiImage1, filename1: pngname )

        let coreDataManager = CoreDataManager(modelName: "NealthJournal")
        let managedObjectContext = coreDataManager.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: managedObjectContext)!
        let saveproductvar = Product(entity: entity, insertInto: managedObjectContext)
    
        let newProduct = Product(context: persistentContainer.viewContext)
    
        namestr = GlobalVariables.mealnameglobal
    
        newProduct.name = namestr
        newProduct.ingredients = ingredientstr
        newProduct.imageLocation = pngname
        newProduct.id = "1"

        saveproductvar.id = newProduct.id
        saveproductvar.ingredients = newProduct.ingredients
        saveproductvar.name = newProduct.name
        
        

        do {
            saveContext()
            }

 
}

func randomString(length: Int) -> String {
      let letters = "0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
func scaleImage(_ image: UIImage) -> UIImage
  {
      var smallimage: UIImage
      let width: CGFloat = 200
      let height: CGFloat = 200
      var newsize: CGSize
      var rect: CGRect
      
      newsize = CGSize(width: 200.0, height: 200.0)
      UIGraphicsBeginImageContext(newsize)
      rect = CGRect(x: 0, y: 0, width: width, height: height)
      
      rect.size.width  = width
      rect.size.height = height
      
      image.draw(in: rect)
      
      //view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
      smallimage = UIGraphicsGetImageFromCurrentImageContext()!;
      UIGraphicsEndImageContext();
      
      return smallimage
  }


struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(showModal: .constant(true))
    }
}

func saveImageToDocumentDirectory(image1: UIImage, filename1: String ) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
   
    let fileName = filename1 // name of the image to be saved
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    if let data = image1.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path)
    {
        do {
            try data.write(to: fileURL)
            print("file saved")
        } catch {
            print("error saving file:", error)
        }
    }
}
