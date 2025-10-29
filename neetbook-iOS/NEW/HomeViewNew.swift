import SwiftUI
import SwiftfulLoadingIndicators

struct HomeViewNew: View {
    @EnvironmentObject var authVM: AuthViewModelNew
    
    @StateObject var homeVM = HomeViewModelNew()
    
    @State var searchText = ""
    
    @State var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        // Title
                        Text("Hello,")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                        
                        // Display name
                        if let displayname = authVM.authState.currentUser?.displayname {
                            Text(displayname)
                                .foregroundColor(.primary)
                                .bold()
                                .font(.system(size: 24))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Search bar
                SearchBarView(
                    searchText: $homeVM.searchText,
                    isEditing: $isEditing,
                    searchFunction: homeVM.searchAction
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                if isEditing {
                    // Search type buttons
                    HStack {
                        // Books & Authors button
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                homeVM.searchType = .booksAndAuthors
                                homeVM.searchText = ""
                            }
                        } label: {
                            Text("Books & Authors")
                                .fontWeight(.bold)
                                .foregroundColor(
                                    homeVM.searchType == .booksAndAuthors ? Color.white : Color.black.opacity(0.5)
                                )
                                .padding(10)
                        }
                        .background(homeVM.searchType == .booksAndAuthors ? Color.appColorOrange : Color.white)
                        .cornerRadius(15)
                        
                        // User Button
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                homeVM.searchType = .users
                                homeVM.searchText = ""
                            }
                        } label: {
                            Text("Users")
                                .fontWeight(.bold)
                                .foregroundColor(
                                    homeVM.searchType == .users ? Color.white : Color.black.opacity(0.5)
                                )
                                .padding(10)
                        }
                        .background(
                            homeVM.searchType == .users ? Color.appColorOrange : Color.white
                        )
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Search
                    
                    // Book search Results
                    switch homeVM.searchingState {
                    case .notSearching:
                        EmptyView()
                    case .startedSearch:
                        EmptyView()
                    case .noResults:
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.primary)
                    case .loading:
                        LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    case .searchedBooks(let array):
                        ForEach(array) { book in
                            NavigationLink(value: book) {
                                HStack {
                                    if let url = URL(string: book.coverURL) {
                                        AsyncCachedImage(url: url) { image in
                                            image
                                                .resizable()
                                                .frame(width: 60, height: 100)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }

                                    VStack(alignment: .leading) {
                                        Text(book.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)

                                        Text(book.author)
                                            .font(.subheadline)
                                            .foregroundColor(.primary.opacity(0.5))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                            }
                        }
                    case .searchedUser(let array):
                        ForEach(array) { user in
                            NavigationLink {
                                TwitterProfileView(userId: user.id)
                            } label: {
                                HStack {
                                    Image(uiImage: user.profilePicture)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                    VStack(alignment: .leading) {
                                        Text(user.displayName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(user.username)#\(user.hashcode)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                            }
                        }
                    }

                } else {
                    Text("Whats popular ✨")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal)
                    
                    ForEach(HomeCategories.allCases, id: \.self) { value in
                        HomeRowView(homeVM: homeVM, category: value)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
    }
}
