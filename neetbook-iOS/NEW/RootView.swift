import SwiftUI
import SwiftfulLoadingIndicators

struct RootView: View {
    
    /// The auth view model for this app.
    @StateObject var authVM = AuthViewModelNew()
    
    /// The feed view model that is injected.
    @StateObject var feedVM = FeedViewModel()
    
    var body: some View {
        switch authVM.authState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .unauthenticated:
            SignInView()
        case .requiresSetup(let user):
            Text("requiresSetup")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .authenticated(let databaseUser):
            homeView
        }
    }
    
    var homeView: some View {
        NavigationStack(path: $authVM.appPath) {
            TabView(selection: $authVM.mainTabSelected) {
                HomeViewNew()
                    .environmentObject(authVM)
                    .tabItem {
                        Label("", systemImage: "house")
                    }
                    .tag(0)
                
                FeedViewNew(viewModel: feedVM)
                    .environmentObject(authVM)
                    .tabItem {
                        Label("", systemImage: "person.2")
                    }
                    .tag(1)
            }
            
            // The book details view navigation destination.
            .navigationDestination(for: Book.self) { book in
                BookViewNew(book: book)
                    .environmentObject(authVM)
            }
            
            // The post view navigation destination.
            .navigationDestination(for: PostFeedInstance.self) { post in
                PostView(post: post, viewModel: PostViewModel())
                    .environmentObject(authVM)
            }
        }
    }
}

#Preview {
    HomeViewNew()
        .environmentObject(AuthViewModelNew())
}
