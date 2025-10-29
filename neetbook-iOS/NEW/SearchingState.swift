enum SearchingState {
    case notSearching
    case startedSearch
    case loading
    case searchedBooks([Book])
    case searchedUser([UserSearchResult])
    case noResults
}
