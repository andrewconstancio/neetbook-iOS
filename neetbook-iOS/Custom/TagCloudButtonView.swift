//
//  TagCloudView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/5/23.
//

import SwiftUI

struct TagCloudButtonView: View {
    var tags: [String]
    @Binding var selectedGenres: [String]
    @Binding var threeOrMoreGenresSelected: Bool

    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 7)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String) -> some View {
        Button {
            if !selectedGenres.contains(text) {
                selectedGenres.append(text)
            } else {
                selectedGenres.removeAll { value in
                    return value == text
                }
            }
            
            if selectedGenres.count >= 3 {
                threeOrMoreGenresSelected = true
            }
            
        } label: {
            Text(text)
                .padding(.all, 10)
                .font(.body)
                .background(selectedGenres.contains(text) ? Color.appColorRed : Color.appColorRed.opacity(0.4))
                .foregroundColor(selectedGenres.contains(text) ? Color.white : Color.white.opacity(0.4))
                .cornerRadius(5)
        }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
