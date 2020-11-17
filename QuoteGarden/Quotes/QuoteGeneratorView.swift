//
//  QuoteGeneratorView.swift
//  QuoteGarden
//
//  Created by Master Family on 25/10/2020.
//

import SwiftUI
import Foundation
import Reachability
import SystemConfiguration

struct QuoteGeneratorView: View {
    
    static let tag: String? = "Home"
    
    @StateObject var viewModel = QuoteViewModel()
     
    var addToFavorites: (_ id: String, _ text: String, _ author: String, _ genre: String) -> Void
    
    @Binding var addedToFavorites: Bool
    @Binding var showingShareSheetView: Bool
    
    @State private var addedToClipboard = false
    @State private var showingNetworkAlert = false
    
    @State private var rect1: CGRect = .zero
    @State private var uiimage: UIImage?
    
    let reachability = try! Reachability()
    
    @State var viewState = CGSize.zero
    
    var body: some View {
        
        VStack {
            
            Color.clear.overlay(
                
                QuoteView(genre: "\(viewModel.quoteGenre)", text: "\(viewModel.quoteText)", author: "\(viewModel.quoteAuthor)")
                    .background(Color.pink.clipShape(RoundedRectangle(cornerRadius: 10)))
                    .gesture(
                        LongPressGesture().onChanged { _ in
                            
                            reachability.whenUnreachable = { _ in
                                showingNetworkAlert = true
                                print("Not reachable")
                            }
                            
                            do {
                                try reachability.startNotifier()
                            } catch {
                                print("Unable to start notifier")
                            }
                            
                            QuoteGardenApi().getRandomQuote { quote in
                                
                                self.viewModel.update(quote.id, quote.quoteText, quote.quoteAuthor, quote.quoteGenre)
                                addedToFavorites = false
                                addedToClipboard = false
                            }
                        }
                    )
                    .offset(x: viewState.width, y: viewState.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewState = value.translation
                            }
                            .onEnded { _ in
                                viewState = .zero
                            }
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0))
                
            ).getRect($rect1)
            .onChange(of: uiimage) {_ in self.uiimage = self.rect1.uiImage }
            
            HStack {
                Button(action: {
                    self.uiimage = self.rect1.uiImage
                    if self.uiimage != nil {
                        showingShareSheetView = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                    
                }.buttonStyle(ColoredButtonStyle())
                .accessibilityLabel(Text("Share quote"))
                
                Button(action: {
                    addToFavorites(self.viewModel.id, self.viewModel.quoteText, self.viewModel.quoteAuthor, self.viewModel.quoteGenre)
                }) {
                    Image(systemName: addedToFavorites ? "heart.fill" : "heart")
                    
                }.buttonStyle(ColoredButtonStyle())
                .accessibilityLabel(Text("Add quote to your favorites"))
                
                Button(action: {
                    copyToClipboard(quoteGenre: viewModel.quoteGenre, quoteText: viewModel.quoteText, quoteAuthor: viewModel.quoteAuthor)
                }) {
                    Image(systemName: addedToClipboard ? "doc.on.doc.fill" : "doc.on.doc")
                    
                }.buttonStyle(ColoredButtonStyle())
                .accessibilityLabel(Text("Copy quote"))
                
            }
            
        }
        .sheet(isPresented: $showingShareSheetView) {
            if uiimage != nil {
                ShareSheetView(activityItems: [
                    self.uiimage!
                ])
            }
        }
        .alert(isPresented: $showingNetworkAlert) {
            Alert(title: Text("No internet connection"), message: Text("Please connect to the internet!"))
        }
        
    }
    func copyToClipboard(quoteGenre: String, quoteText: String, quoteAuthor: String) {
        let quoteString = """
        \(quoteGenre)

        \(quoteText)

        \(quoteAuthor)
        """
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = quoteString
        
        if pasteboard.string != nil {
            print(quoteText)
        }
        
        addedToClipboard = true
    }
    
}

//struct QuoteGeneratorView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuoteGeneratorView()
//    }
//}
