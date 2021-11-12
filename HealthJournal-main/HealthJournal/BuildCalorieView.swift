//
//  BuildCalorieView.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/28/21.
//

import SwiftUI
import CoreData

struct AverageSpeed: Identifiable, Hashable {
    let id: Int
    let name: String
}


struct BuildCalorieView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var buildCalorieConfig = BuildCalorieConfig()
    @State var distancetext: String = ""
    @State var averagespeedtext: String = ""
    @State var nametext: String = ""
    @State var heighttext: String = ""
    @State var weighttext: String = ""
    @State var agetext: String = ""
    @State var sextext: String = ""
    @State var caloriestext: String = ""
    @State var timespenttext: String = ""
    let storageProvider: StorageProvider
    let calorieDataHandler: CalorieDataHandler
    @State var exercisetypes = ["Running", "Walking", "Bicycling" ]


    var averagebicyclingspeed = [
            AverageSpeed(id: 0, name: "Bicycling, mountain, uphill, vigorous"),
            AverageSpeed(id: 1, name: "Bicycling, mountain, uphill, vigorous"),
            AverageSpeed(id: 2, name: "Bicycling, leisure, 9.4 mph")
        ]
        
        var averagerunningspeed = [
            AverageSpeed(id: 0, name: "4 mph (15 min/mile)"),
            AverageSpeed(id: 1, name: "5 mph (12 min/mile)"),
            AverageSpeed(id: 2, name: "5.2 mph (11.5 min/mile"),
            AverageSpeed(id: 3, name: "6.0 mph (10 min/mile)"),
            AverageSpeed(id: 4, name: "6.7 mph (9 min/mile)")
        ]
        
        var averagewalkingspeed = [
            AverageSpeed(id: 0, name: "Less than 2.0 mph, strolling"),
            AverageSpeed(id: 1, name: "2.0 mph, slow pace"),
            AverageSpeed(id: 2, name: "Walking for pleasure")
        ]

    
    @State var selectedexercisetype = ""
    @State var showAlert = false
    @FocusState private var nametextIsFocused: Bool
    
    
    var body: some View  {
        VStack {
            Form {
                Section (header: Text("Entry Description").bold()) {
                    DatePicker("When", selection: $buildCalorieConfig.selectedDate)
                    
                HStack(alignment: .center) {
                Text("Exercise Type:")
                    .font(.callout)
                Button(action: {
                   // dynamicAverageSpeed()
                }) {
                    Image(systemName: "folder")
                   }
                   Picker("", selection: $selectedexercisetype) {
                   ForEach(exercisetypes, id: \.self) {
                   Text($0)
                  }

                  }
                  // .menuStyle(.PopUpButtonPickerStyle)
                  .padding()
                  .frame(width: 180, height: 40, alignment: .center)
                  }
                   // dynamicAverageSpeed(strexercisetype: selectedexercisetype)
                }
                
                HStack(alignment: .center) {
                Text("Height(inches) ")
                TextField("72", text: $heighttext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40)
                
                Text("Weight(lbs) ")
                TextField("175", text: $weighttext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                    
                Text("Age ")
                TextField("28", text: $agetext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40)
                    
                Text("Sex ")
                TextField("M ", text: $sextext)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 40)
                }
                
                
                HStack(alignment: .center) {
                Text("Distance Traveled       ")
                TextField("Distance Traveled", text: $distancetext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)

                }
                
                HStack(alignment: .center) {
                Text("Time Spent(min)       ")
                TextField("Time Spent       ", text: $timespenttext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)

                }
                
                if (selectedexercisetype == "Running" )
                {
                HStack(alignment: .center) {
                Text("Average Speed            ")
                    
                Button(action: {
                    }) {
                        Image(systemName: "folder")
                       }
                    
                    Picker("", selection: $averagespeedtext){
                                            ForEach(averagerunningspeed) { AverageSpeed in
                                                Text(AverageSpeed.name).tag(AverageSpeed.name)
                                            }
                                          }
                    
                       .padding()
                       .frame(width:240, height: 40, alignment: .center)
                    
                    }
                }
                
                if (selectedexercisetype == "Walking" )
                {
                HStack(alignment: .center) {
                Text("Average Speed            ")
                    
                Button(action: {
                    }) {
                        Image(systemName: "folder")
                       }
                    
                    
                    Picker("", selection: $averagespeedtext){
                        ForEach(averagewalkingspeed) { AverageSpeed in
                            Text(AverageSpeed.name).tag(AverageSpeed.name)
                        }
                      }
                    
                       .padding()
                       .frame(width:240, height: 40, alignment: .center)
                    
                    }
                }
                
                if (selectedexercisetype == "Bicycling" )
                {
                HStack(alignment: .center) {
                Text("Average Speed            ")
                    
                Button(action: {
                    }) {
                        Image(systemName: "folder")
                       }
                    
                    Picker("AverageSpeed", selection: $averagespeedtext){
                        ForEach(averagebicyclingspeed, id: \.self) { AverageSpeed in
                            Text(AverageSpeed.name).tag(AverageSpeed.name)
                      }
                    }
                   
                
                       .padding()
                       .frame(width:240, height: 40, alignment: .center)
                    
                    }
                }
                
                
                
                
                HStack(alignment: .center) {
                    Label("Calories Burned ", systemImage: "book.fill")
                        .labelStyle(TitleOnlyLabelStyle())
                    Button(action: {
                        self.showAlert.toggle()
                    }) {
                        Text("Show Calories Burned")
                    }
                }.alert(isPresented: $showAlert) { () -> Alert in
                    //Alert(title: Text("1,293.758353"))
                    Alert(title: Text(GlobalVariables.calorieglobal))
                }
                
                HStack(alignment: .center) {
                TextField("Session Name", text: $nametext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                        .focused($nametextIsFocused)
                Button(action: {
                    nametextIsFocused = false
                    SaveCalorie(namestr: nametext,
                        typestr: selectedexercisetype,
                        distancestr: "6",
                        averagespeedstr: averagespeedtext,
                        heightstr: "72",
                        weightstr: "175",
                        agestr: "28",
                        sexstr: "M",
                        caloriesstr: "678",
                        timespentstr: timespenttext)
                }) {
                  Text("Add Exercise Session")
                }
                }
    
                }.alert(isPresented: $buildCalorieConfig.alertModel.alertIsPresented, content: {
                    Alert(title: Text(buildCalorieConfig.alertModel.alertType), message: Text(buildCalorieConfig.alertModel.alertText))
                })
        
       
        }
        /*
                VStack {
                    Button(action: {
                        self.showAlert.toggle()
                    }) {
                        Text("strcalorie!")
                    }
                }.alert(isPresented: $showAlert) { () -> Alert in
                    Alert(title: Text("strcalorie!"))
                }
        */
    }
        
}



func SaveCalorie(namestr: String, typestr: String, distancestr: String, averagespeedstr: String,
    heightstr: String, weightstr: String, agestr: String, sexstr: String, caloriesstr: String, timespentstr: String)
{
    var doubledistance: Double
    var doubleheight: Double = 0.0
    var doubleweight: Double = 0.0
    var doubleage: Double = 0.0
    var doublecalories: Double
    var doubletimespent: Double
    var doublebmr: Double = 0.0
    var doubleweightkg: Double = 0.0
    var doubleheightcm: Double = 0.0
    var doublemets: Double = 0.0
    var doublehour: Double = 0.0
    var strmets: String = ""
    var strcalorie: String = ""
    var recordcount: Int = 0
    var _mets: [Mets] = []
    
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
    
    recordcount = getRecordsCount()
    print("recordcount")
    print(recordcount)
    
    
    if ( recordcount == 0 )
    {
       metsarray()
    }
    
    doubleheight = Double(heightstr)!
    doubledistance = Double(distancestr)!
    doubleweight = Double(weightstr)!
    doubleage = Double(agestr)!
    doubletimespent = Double(timespentstr)!

    
    doubleweightkg = doubleweight/2.2046
    doubleheightcm = doubleheight*2.54
    
    if ( sexstr == "M")
    {
    doublebmr =  88.362 + (13.397 * doubleweightkg) + (4.799 * doubleheightcm) - (5.677 * doubleage )
    }
    
    if ( sexstr == "F")
    {
        doublebmr = 447.593 +  (9.247 * doubleweightkg) + ( 3.098 * doubleheightcm) - (4.330 * doubleage )
    }
    
    _mets = GetMets(strspeed: averagespeedstr)
    strmets = (_mets.first?.mets)!
    doublemets = Double(strmets)!

    doublehour = doubletimespent/60
    doublemets = doublemets * doublehour
    doublemets = doublemets / 24
    doublecalories = doublebmr * doublemets

    let newCalorie = Calorie(context: persistentContainer.viewContext)
    newCalorie.name = namestr
    newCalorie.datetime = Date()
    newCalorie.type = typestr
    newCalorie.distanceTraveled = doubledistance
    newCalorie.height = doubleheight
    newCalorie.weight = doubleweight
    newCalorie.age = doubleage
    newCalorie.sex = sexstr
    newCalorie.caloriesBurned = doublecalories
    newCalorie.timeSpent = doubletimespent
    newCalorie.averageSpeed = averagespeedstr
    newCalorie.bmr = doublebmr
    
    strcalorie = String(format: "%f", doublecalories)
    GlobalVariables.calorieglobal = strcalorie
  
    do {
        saveContext()
    }
    
}


struct BuildCalorieConfig {
    var selection: String? = nil
    var calorieName = ""
    var selectableProductsViewIsActive = false
    var selectedDate = Date()
    var recipeToggleIsActive = false
    var alertModel = AlertModel()
    var alternateViewIsShowing = false
    var selectedProducts: [Product] = []
}

struct CalorieListHeader: View {
    @Binding var alternateViewIsShowing: String?
    @State private var selection = 0
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

struct CalorieProductRow: View {
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

struct CalorieProductRow1: View {
    var calorie: Calorie

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Name:  \(calorie.name!)")
                    .font(.title3)
                Text("Exercise Type:  \(calorie.type!)")
                    .font(.title3)
                Text("Height:   \(calorie.height)")
                    .font(.title3)
                Text("Distance Traveled:   \(calorie.distanceTraveled)")
                    .font(.title3)
                Text("Calories Burned:   \(calorie.caloriesBurned)")
                    .font(.title3)
                Text("Time Spent:   \(calorie.timeSpent)")
                    .font(.title3)
            }
            Spacer()
        }
        }
    }
   



struct CalorieProductRow2: View
 {
    @Environment(\.managedObjectContext) private var viewContext
    
    //@FetchRequest
    @FetchRequest var calories: FetchedResults<Calorie>
    //public var calories: FetchedResults<Calorie>
    public var namevar: String = "Ccc"
    let boolCalorie: Bool = true
    let fetchRequest = NSFetchRequest<Calorie>()
    let entity = Calorie.entity()
   // fetchRequest.entity = entity
    var calorie1: [Calorie] = []
    
    
    init(boolCalorie: Bool) {
    
        var predicate: NSPredicate? = nil
            predicate = NSPredicate(format: "name == %@", namevar)
       
        _calories = FetchRequest( entity: Calorie.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Calorie.name, ascending: true)],predicate: predicate)
    
    }
    
    
    var body: some View {
        Text("Name:  ")
                   
      }
       
}

struct GlobalVariables
{
    static var calorieglobal: String = "Ddd"
    static var namevarglobal: String = "Aaa"
    static var mealnameglobal: String = ""
}


func getRecordsCount() -> Int
  {
      var count: Int
      let coreDataManager = CoreDataManager(modelName: "HealthJournal")
      count = 0
      let managedObjectContext = coreDataManager.managedObjectContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mets")
          do {
              count = try managedObjectContext.count(for: fetchRequest)
          } catch {
              print(error.localizedDescription)
          }
      return count
  }

func GetMets(strspeed: String) -> [Mets]
{
    //var mets: [Mets] = []
    var pp: [Mets] = []
    let coreDataManager = CoreDataManager(modelName: "HealthJournal")
    let managedObjectContext = coreDataManager.managedObjectContext
    let entity = NSEntityDescription.entity(forEntityName: "Mets", in: managedObjectContext)!
    
    let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "entity")
    request.entity = entity
           
    let predicate = NSPredicate(format:"(self.averagespeed == %@)", strspeed)
                                
    request.predicate = predicate
    
    do {
        let f = try managedObjectContext.fetch(request)
        pp = f as! [Mets]
    } catch let error as NSError {
        print("Mets \(error)")
    }

    return pp
}

func metsarray()
 {
     var dict: NSDictionary?
     var strmetsid: String
     var intmetsid: Int16
     var strexercisetype: String
     var strspeed: String
     var strmets: String
     let coreDataManager = CoreDataManager(modelName: "HealthJournal")
     let managedObjectContext = coreDataManager.managedObjectContext
     let entity = NSEntityDescription.entity(forEntityName: "Mets", in: managedObjectContext)!
     
     
     if let path = Bundle.main.path(forResource: "healthjournal", ofType: "plist")
     {
         dict = NSDictionary(contentsOfFile: path)!
     }
     
     for dc in dict?.object(forKey: "mets") as! Array<Dictionary<String, AnyObject>>
     {
         strexercisetype = dc["exercisetype"] as! String
         strspeed = dc["speed"] as! String
         strmets = dc["mets"] as! String
         strmetsid = dc["metsid"] as! String
         intmetsid = Int16(strmetsid)!
         
         let mets = Mets(entity: entity, insertInto: managedObjectContext)
         
         mets.exercisetype = strexercisetype
         mets.averagespeed = strspeed
         mets.mets = strmets
         mets.metsid = intmetsid
         
         do {
             try managedObjectContext.save()
             } catch {
             fatalError("Failure to save context: \(error)")
             }
     }
 
 }


 
  


   





 
  


   


