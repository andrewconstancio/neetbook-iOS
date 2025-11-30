enum BookGenresNewYorkTimes: CaseIterable {
    case bestSellers, nonFiction, selfImprovment
    
    var title: String {
        switch self {
        case .bestSellers:
            return "Best Sellers"
        case .nonFiction:
            return "Non Fiction"
        case .selfImprovment:
            return "Self Improvment"
        }
    }
    
    var nytBestSellersEndpoint: String {
        switch self {
        case .bestSellers:
            return "mass-market-monthly"
        case .nonFiction:
            return "paperback-nonfiction"
        case .selfImprovment:
            return "advice-how-to-and-miscellaneous"
        }
    }
}
