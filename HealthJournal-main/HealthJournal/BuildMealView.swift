//
//  BuildMealView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//


import SwiftUI
import CoreData
import MobileCoreServices
import AVFoundation

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct BuildMealView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var buildMealConfig = BuildMealConfig()
    @State var mealtext: String = ""
    let storageProvider: StorageProvider
    let mealDataHandler: MealDataHandler
    @FocusState private var mealtextIsFocused: Bool
    @State var showImagePicker: Bool = false
    @State var meals = ["Breakfast", "Lunch", "Dinner", "Snack", "Drink" ]
    @State var selectedMeal = ""
    @State private var showModal = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View  {
        VStack {
            Form {
                Section (header: Text("Entry Description").bold()) {
                    TextField("A catchy name or phrase", text: $buildMealConfig.mealName)
                    DatePicker("When", selection: $buildMealConfig.selectedDate)
                    Toggle("Save as a Recipe", isOn: $buildMealConfig.recipeToggleIsActive)
                        .navigationBarTitle("Your Meal")
                    
                
                HStack(alignment: .center) {
                Text("Meal Type:")
                    .font(.callout)
                Button(action: {
                }) {
                    Image(systemName: "folder")
                   }
                   Picker("", selection: $selectedMeal) {
                   ForEach(meals, id: \.self) {
                   Text($0)
                  }

                  }
                  // .menuStyle(.PopUpButtonPickerStyle)
                  .padding()
                  .frame(width: 180, height: 40, alignment: .center)
                  }
                }
                
                HStack(alignment: .center) {
                TextField("Meal", text: $mealtext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                        .focused($mealtextIsFocused)
                Button(action: {
                    mealtextIsFocused = false
                    SaveMeal(namestr: mealtext)
                    
                }) {
                  Text("Add Meal")
                }
                }
                
               
                Section (header: ListHeader(alternateViewIsShowing: $buildMealConfig.selection))
                    {
                    if buildMealConfig.selectedProducts.count != 0 {
                        List {
                            ForEach(buildMealConfig.selectedProducts, id: \.self) { product in
                                ProductRow(product: product)
                            }
                        }
                    }
                    else {
                      
                        HStack(alignment: .center) {
                        Button("Add Ingredient") {
                            self.showModal.toggle()
                            }.sheet(isPresented: $showModal) {
                            ModalView(showModal: self.$showModal)
                        }
                              
                        }
                        
  
                    
                .padding(.horizontal)
               
                           
                    }
                   
                    }

    
                }.alert(isPresented: $buildMealConfig.alertModel.alertIsPresented, content: {
                    Alert(title: Text(buildMealConfig.alertModel.alertType), message: Text(buildMealConfig.alertModel.alertText))
                })
            }
        .toolbar(content: {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Save") {
                   guard buildMealConfig.mealName == "" || !buildMealConfig.selectedProducts.isEmpty else {
                        buildMealConfig.alertModel.alertText = "Please finish your meal entry before submitting."
                        buildMealConfig.alertModel.alertIsPresented.toggle()
                        return
                    }
                    mealDataHandler.saveNewMeal(mealDetails: buildMealConfig) { result in
                        switch result {
                        case .success:
                            print("Successfully submitted meal")
                            self.presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            switch error {
                            case .entityAlreadyExistsInDataStore:
                                fatalError("Unexpected duplicate entity. Please Submit a bug report")
                            case .localDataStoreError(let description):
                        
                                self.buildMealConfig.alertModel.alertText = "Unexpected problem with database. Please try again"
                                self.buildMealConfig.alertModel.alertIsPresented.toggle()
                            case .networkingError:
                                self.buildMealConfig.alertModel.alertText = "Unexpected networking issue. Please try again"
                                self.buildMealConfig.alertModel.alertIsPresented.toggle()
                            case .remoteDataStoreError(let description):
                               
                                self.buildMealConfig.alertModel.alertText = "Unexpected datastore issue. Please try again."
                                self.buildMealConfig.alertModel.alertIsPresented.toggle()
                            }
                        }
                    }
                }
            }
        })
             
    
    
            NavigationLink(destination: MealCompositionView(storageProvider: storageProvider, constituentProducts: $buildMealConfig.selectedProducts), tag: "A", selection:  $buildMealConfig.selection) { EmptyView() }
            NavigationLink(destination: Text("Welcome to RecipesView!"), tag: "B", selection: $buildMealConfig.selection) { EmptyView() }
            NavigationLink(destination: Text("Welcome to RestaurantsView!"), tag: "C", selection: $buildMealConfig.selection) { EmptyView() }
            
           
            }
    
    
    
    func SaveMeal(namestr: String) {
        
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


        let newMeal = Meal(context: persistentContainer.viewContext)
        newMeal.name = namestr
        newMeal.datetime = Date()
    
        GlobalVariables.mealnameglobal = namestr
       
        do {
            saveContext()
        }
        
    }
    
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
}



struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    private var presentationMode

    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    final class Coordinator: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {

        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void

        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }

    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    
}

struct BuildMealConfig {
    var selection: String? = nil
    var mealName = ""
    var selectableProductsViewIsActive = false
    var selectedDate = Date()
    var recipeToggleIsActive = false
    var alertModel = AlertModel()
    var alternateViewIsShowing = false
    var selectedProducts: [Product] = []
}

struct ListHeader: View {
    @Binding var alternateViewIsShowing: String?
    @State private var meal1: String = ""
    @State private var selection = 0
    @State private var selectedColor = "Red"
    @State private var selectedItem: Int = 0
    @State private var showModal = false
    @State private var isPresented = false
        
    var body: some View {
        HStack {
            Text("Them Key Materials")
                .bold()
            Spacer()
            Button(action: {
                self.alternateViewIsShowing = "A"
            }) {
                Image(systemName: "plus.square")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            Button(action: {
                self.alternateViewIsShowing = "B"
            }) {
                Image(systemName: "bookmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal)
            }
            Button(action: {
                self.alternateViewIsShowing = "C"
            }) {
                Image(systemName: "person.2.square.stack")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct ProductRow: View {
    var product: Product

    var body: some View {
        HStack {
            if product.imageLocation != nil {
                Image(product.imageLocation!)
                    .resizable()
                    .frame(width:50, height: 50)
            }
            VStack(alignment: .leading) {
                Text("\(product.ingredients)")
                    .font(.title3)
                Text("\(product.brand)")
            }
            Spacer()
        }
    }
}

struct ProductRow1: View {
    var product: Product

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(product.ingredients)")
                    .font(.title3)
            }
            Spacer()
        }
    }
}


