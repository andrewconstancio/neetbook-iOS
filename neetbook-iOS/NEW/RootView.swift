import SwiftUI
import SwiftfulLoadingIndicators

struct RootView: View {
    
    @StateObject var authVM = AuthViewModelNew()
    
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
            }
            
            // The book details view navigation destination.
            .navigationDestination(for: Book.self) { book in
                BookViewNew(book: book)
            }
        }
    }
}

#Preview {
    HomeViewNew()
        .environmentObject(AuthViewModelNew())
}
