//
//  ContentView.swift
//  QuoteGarden
//
//  Created by Master Family on 03/10/2020.
//

import SwiftUI
import Foundation


struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: QuoteCD.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \QuoteCD.quoteAuthor, ascending: true)]) var favoriteQuotes: FetchedResults<QuoteCD>
    
    @State private var quote: Quote = Quote(id: "", quoteText: "Tap the random button", quoteAuthor: "Nikola Franičević", quoteGenre: "knowledge")
    
    @State private var change = false
    
    #warning("Widgets with one of your favorite quote")
    
    
    var body: some View {
        
    
    TabView {
        
        
        VStack {
            
            
            QuoteView(quoteGenre: "\(quote.quoteGenre)", quoteText: "\(quote.quoteText)", quoteAuthor: "\(quote.quoteAuthor)")

            HStack {
                
                Button(action: { quoteGardenApi().getRandomQuote { (quote) in
                    withAnimation(.easeInOut(duration: 1)) {
                    change.toggle()
                    }
                    self.quote = quote
                } }) {
                    VStack {
                        Text("New quote")
                    }.padding()
                    .border(Color.accentColor)
                    
                }.padding()
                
                
                
                
                Button(action: { addToFavorites(_: self.quote.id, self.quote.quoteText, self.quote.quoteAuthor, self.quote.quoteGenre) }) {
                    
                    VStack {
                        Text("Add to favorites")
                        
                    }.padding()
                    .border(Color.accentColor)
                    
                }
            }
            
            
        }.tabItem {
            Image(systemName: "wand.and.stars")
            Text("Random")
        }
        
        
        NavigationView {
            
            List {
                ForEach(favoriteQuotes, id: \.id) { favoriteQuote in
                    NavigationLink(destination: QuoteDetailView(favoriteQuote: favoriteQuote)) {
                        Text(favoriteQuote.quoteText ?? "No Favorite Quote Yet")
                    }
                }.onDelete(perform: removeQuote)
                
                
            }.navigationTitle(Text("Your Favorites"))
            .navigationBarItems(trailing: EditButton())
            
            
        }.tabItem {
            Image(systemName: "star.fill")
            Text("Favorites")
        }
        
    }
}

func addToFavorites(_ id: String, _ text: String, _ author: String, _ genre: String) {
    let favoriteQuote = QuoteCD(context: self.moc)
    favoriteQuote.id = id
    favoriteQuote.quoteText = text
    favoriteQuote.quoteAuthor = author
    favoriteQuote.quoteGenre = genre
    
    try? self.moc.save()
}

func removeQuote(at offsets: IndexSet) {
    for index in offsets {
        let favoriteQuote = favoriteQuotes[index]
        moc.delete(favoriteQuote)
    }
    
    do {
        try moc.save()
    } catch  {
        return
    }
}
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


