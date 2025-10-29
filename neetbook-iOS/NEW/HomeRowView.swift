import SwiftUI

struct HomeRowView: View {
    
    @ObservedObject var homeVM: HomeViewModelNew
    
    let category: HomeCategories
    
    @State var books = [Book]()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // The home rows book category title.
            Text(category.title)
                .font(.title2)
                .foregroundColor(.primary)
                .bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if books.isEmpty {
                        ForEach(1..<15, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 140, height: 210)
                                .opacity(0.5)
                                .shimmering()
                        }
                    } else {
                        ForEach(books) { book in
                            if let url = URL(string: book.coverURL) {
                                NavigationLink(value: book) {
                                    AsyncCachedImage(url: url) { image in
                                        image
                                            .resizable()
                                            .frame(width: 140, height: 210)
                                            .shadow(radius: 8)
                                            .cornerRadius(16)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 16)
                                            .frame(width: 140, height: 210)
                                            .opacity(0.5)
                                            .shimmering()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .task {
            books = await homeVM.getNYTBooks(for: category.nytBestSellersEndpoint)
        }
    }
}
