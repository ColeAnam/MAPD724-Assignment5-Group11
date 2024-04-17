//
//  ContentView.swift
//  MAPD724-Assignment5-Group11
//
//  Created by Cole Anam on 13/4/24.
//

import SwiftUI
import MapKit

class favRestaurants: ObservableObject {
    @Published var favourites: [Restaurants] = []
}

struct ContentView: View {
    @State private var selectedAnnotation: RestaurantAnnotation?
    @State private var isPresent = false
    @State var currentDetent: PresentationDetent = .fraction(0.3)
    @State var selection: Int?
    @ObservedObject var favs = favRestaurants()
    
    let toronto = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.65, longitude: -79.38), latitudinalMeters: 100, longitudinalMeters: 100)
    
    let restaurants = [
        Restaurants(openTime: "11 a.m.", closingTime: "9 p.m.", rating: "4.7", restName: "Gus Tacos", address: "2897 Kingston Rd, Scarborough, ON M1M 1N3", coordinate: CLLocationCoordinate2D(latitude: 43.72396539599484,  longitude: -79.23550123447204)),
        Restaurants(openTime: "12 p.m.", closingTime: "8:30 p.m.", rating: "4.5", restName: "Kyouka Ramen", address: "2222 Queen St E, Toronto, ON M4E 1E9", coordinate: CLLocationCoordinate2D(latitude: 43.67282719312579, longitude: -79.2881155450992)),
        Restaurants(openTime: "11:30 a.m.", closingTime: "12 a.m.", rating: "4.0", restName: "Korean Grill House", address: "754 Yonge St, Toronto, ON M4Y 2B6", coordinate: CLLocationCoordinate2D(latitude: 43.671893309766446,  longitude: -79.38588625358118)),
        Restaurants(openTime: "11 a.m.", closingTime: "10 p.m.", rating: "4.3", restName: "Chick-fil-A", address: "709 Yonge St, Toronto, ON M4Y 2B6", coordinate: CLLocationCoordinate2D(latitude: 43.6696830605715,  longitude: -79.38611141626319)),
        Restaurants(openTime: "11 a.m.", closingTime: "11 p.m.", rating: "4.3", restName: "Kothur Indian Cuisine", address: "649 Yonge St, Toronto, ON M4Y 1Z9", coordinate: CLLocationCoordinate2D(latitude: 43.66806103284311,  longitude: -79.38561788991387)),
        Restaurants(openTime: "11 a.m.", closingTime: "9 p.m.", rating: "4.5", restName: "Pho Metro", address: "2057 Lawrence Ave E, Scarborough, ON M1R 2Z4", coordinate: CLLocationCoordinate2D(latitude: 43.7474363510687, longitude: -79.29341176707806)),
        Restaurants(openTime: "11 a.m.", closingTime: "1 a.m.", rating: "4.3", restName: "JOEY Eaton Centre", address: "1 Dundas St W, Toronto, ON M5G 1Z3", coordinate: CLLocationCoordinate2D(latitude: 43.65636306233427, longitude: -79.38180919687524)),
        Restaurants(openTime: "11:45 a.m.", closingTime: "2 a.m.", rating: "4.0", restName: "Jack's Dundas Square", address: "10 Dundas St E, Toronto, ON M5B 2G9", coordinate: CLLocationCoordinate2D(latitude: 43.65717032975361,  longitude: -79.3803071598091)),
        Restaurants(openTime: "12 a.m.", closingTime: "11 p.m.", rating: "4.4", restName: "Trattoria Nervosa", address: "75 Yorkville Ave, Toronto, ON M5R 1B8", coordinate: CLLocationCoordinate2D(latitude: 43.67169823915426,  longitude: -79.3909627339347)),
        Restaurants(openTime: "11:30 a.m.", closingTime: "10:30 p.m.", rating: "4.1", restName: "Thai on Yonge", address: "370 Yonge St, Toronto, ON M5B 1S5", coordinate: CLLocationCoordinate2D(latitude: 43.65980742373719,  longitude: -79.38129942356892))
    ]
    
    var body: some View {
        VStack {
            Map(initialPosition: .region(toronto), selection: $selection) {
                ForEach(restaurants.indices, id: \.self) { index in
                    Annotation(coordinate: restaurants[index].coordinate,
                        content: {
                            ZStack(content: {
                                
                                Image(systemName: "circle.fill")
                                    .padding()
                                    .foregroundStyle(Gradient(colors: [.orange, .white]))
                                    .scaleEffect(selection == index ? 4 : 2)
                                    .tag(index)
                                    .overlay(
                                        Image(systemName: "fork.knife")
                                            .padding()
                                            .foregroundStyle(.black)
                                            .scaleEffect(selection == index ? 2 : 1)
                                    )
                                    
                            })
                            .tag(index)
                            .onTapGesture {
                                //print(restaurants[index].restName)
                                selectedAnnotation = RestaurantAnnotation(restaurant: restaurants[index])
                                isPresent = true
                            }
                        },
                        label: {
                            Text(restaurants[index].restName)
                        })
                }
            }
            .onTapGesture {
                selectedAnnotation = nil
                isPresent = false
            }
        }
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "star.fill")
                        .resizable()
                        .foregroundColor(.yellow)
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                        .onTapGesture {
                            print("Favourites tapped")
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
                }
                Spacer()
            }
        }
        .sheet(isPresented: $isPresent) {
            if currentDetent == .fraction(0.3) {
                SheetViewSmall(favs: favs, selectedRest: $selectedAnnotation)
                    .presentationDetents([.fraction(0.3), .large], selection: $currentDetent)
            }
        }
    }
    
}

struct RestaurantAnnotation {
    let restaurant: Restaurants
}

struct SheetViewSmall: View {
    @ObservedObject var favs: favRestaurants
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRest: RestaurantAnnotation?
    @State var starIcon = "star"
    
    var body: some View {
        Color.white
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 20) {
                        Text(selectedRest!.restaurant.restName)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: starIcon)
                            .onTapGesture {
                                if (starIcon == "star") {
                                    starIcon = "star.fill"
                                    favs.favourites.append(selectedRest!.restaurant)
                                }
                                else {
                                    starIcon = "star"
                                    if let index = favs.favourites.firstIndex(of: selectedRest!.restaurant) {
                                        favs.favourites.remove(at: index)
                                    }
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 0))
                    HStack {
                        Text(selectedRest!.restaurant.rating)
                        Image(systemName: "star.fill")
                    }
                    Text("\(selectedRest!.restaurant.openTime) - \(selectedRest!.restaurant.closingTime)")
                    Text(selectedRest!.restaurant.address)
                    Spacer()
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
    }
}

class Restaurants: NSObject, MKAnnotation {
    let restName, address, openTime, closingTime, rating: String
    var coordinate: CLLocationCoordinate2D
    
    init(openTime: String, closingTime: String, rating: String, restName: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.openTime = openTime
        self.closingTime = closingTime
        self.coordinate = coordinate
        self.restName = restName
        self.address = address
        self.rating = rating
    }
    
}

#Preview {
    ContentView()
}
