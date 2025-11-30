import SwiftUI
import SwiftfulLoadingIndicators

struct HomeViewNew: View {
    /// The environment auth view model.
    @EnvironmentObject var authVM: AuthViewModelNew
    
    /// The home view model.
    @StateObject var homeVM = HomeViewModelNew()
    
    /// The search text for the home view.
    @State var searchText = ""
    
    /// Flag if the search bar is being typed into.
    @State var isEditingSearch = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if isEditingSearch {
                    searchTypeButtons
                    searchResults

                } else {
                    bookGenres
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
    }
    
    /// The header for this view that includes the name of the user and search bar.
    @ViewBuilder
    private var header: some View {
        HStack(spacing: 5) {
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
            
            Spacer()
            
            NavigationLink {
                // TODO: Refactor this view
//                NotificationView()
//                    .environmentObject(userStateViewModel)
            } label: {
                Image(systemName: "bell")
                   .resizable()
                   .frame(width: 20, height: 20)
                   .foregroundColor(Color.primary)
                   .padding(.trailing, 30)
                   .padding(.top, 10)
            }
            
            if let user = authVM.authState.currentUser {
                NavigationLink {
                    ProfileView(userID: user.userId)
                        .environmentObject(authVM)
                } label: {
                    if let photoURL = authVM.authState.currentUser?.photoUrl,
                       let url = URL(string: photoURL) {
                        AsyncCachedImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .offset(x: -5, y: 0)
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        
        // Search bar
        SearchBarView(
            searchText: $homeVM.searchText,
            isEditing: $isEditingSearch,
            searchFunction: homeVM.searchAction
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    /// The search type buttons (e.g. Books & Authors or Users)
    private var searchTypeButtons: some View {
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
    }
    
    /// The search results for this view.
    @ViewBuilder
    private var searchResults: some View {
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
                    ProfileView(userID: user.id)
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
    }
    
    /// The home contents book genres row.
    @ViewBuilder
    private var bookGenres: some View {
        Text("Whats popular ✨")
            .font(.title2)
            .bold()
            .padding(.horizontal)
        
        ForEach(BookGenresNewYorkTimes.allCases, id: \.self) { value in
            HomeRowView(homeVM: homeVM, genre: value)
        }
    }
}
