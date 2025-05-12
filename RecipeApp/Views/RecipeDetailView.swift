import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let photoData = recipe.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                Text("Category: \(recipe.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(recipe.description)
                    .font(.body)
                    .padding(.vertical, 8)
                Divider()
                Text("Ingredients")
                    .font(.headline)
                ForEach(recipe.ingredients) { ingredient in
                    Text("- \(ingredient.quantity) \(ingredient.name)")
                        .padding(.vertical, 2)
                }
                Divider()
                Text("Instructions")
                    .font(.headline)
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                        .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
