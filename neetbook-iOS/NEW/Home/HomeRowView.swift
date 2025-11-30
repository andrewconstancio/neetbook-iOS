import SwiftUI
import SkeletonUI

struct HomeRowView: View {
    
    /// The home viewmodel.
    @ObservedObject var homeVM: HomeViewModelNew
    
    /// The books row genre.
    let genre: BookGenresNewYorkTimes
    
    /// An array of `Book` this fills on the row of books fetched.
    @State var books = [Book]()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            genreTitle
            scrollViewBooks
        }
        .task {
            books = await homeVM.getNYTBooks(for: genre.nytBestSellersEndpoint)
        }
    }
    
    /// The genres title.
    private var genreTitle: some View {
        // The home rows book category title.
        Text(genre.title)
            .font(.title2)
            .foregroundColor(.primary)
            .bold()
            .padding(.horizontal)
    }
    
    /// A horizontal scroll view for the books fetched for the genre.
    private var scrollViewBooks: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                if books.isEmpty {
                    ForEach(1..<15, id: \.self) { _ in
                        Rectangle()
                            .frame(width: 140, height: 210)
                            .redacted(reason: .placeholder)
                            .shimmering()
                            .opacity(0.2)
                    }
                } else {
                    ForEach(books) { book in
                        if let url = URL(string: book.coverURL) {
                            NavigationLink(value: book) {
                                VStack(alignment: .leading, spacing: 8) {
                                    AsyncCachedImage(url: url) { image in
                                        image
                                            .resizable()
                                            .frame(width: 140, height: 210)
                                            .shadow(radius: 10)
                                        
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 140, height: 210)
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                            .opacity(0.2)
                                    }
                                    
                                    
                                    Text(book.title)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: 140)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
//        .background(.green)
    }
}
