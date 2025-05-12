import SwiftUI
import PhotosUI
import FirebaseStorage

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecipeViewModel
    
    @State private var name = ""
    @State private var category = Recipe.categories[0]
    @State private var description = ""
    @State private var ingredients: [Ingredient] = [Ingredient(name: "", quantity: "")]
    @State private var instructions: [String] = [""]
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Photo Section
                Section {
                    Button(action: { showingImagePicker = true }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        } else {
                            HStack {
                                Image(systemName: "photo")
                                Text("Add Photo")
                            }
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Basic Info Section
                Section(header: Text("Basic Information")) {
                    TextField("Recipe Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Recipe.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Description")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Ingredients Section
                Section(header: Text("Ingredients")) {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            TextField("Name", text: $ingredient.name)
                            TextField("Amount", text: $ingredient.quantity)
                                .frame(width: 100)
                        }
                    }
                    .onDelete(perform: deleteIngredient)
                    
                    Button(action: addIngredient) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Ingredient")
                        }
                    }
                }
                
                // Instructions Section
                Section(header: Text("Instructions")) {
                    ForEach($instructions) { $instruction in
                        TextEditor(text: $instruction)
                            .frame(height: 60)
                    }
                    .onDelete(perform: deleteInstruction)
                    
                    Button(action: addInstruction) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Step")
                        }
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveRecipe) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        !ingredients.isEmpty &&
        ingredients.allSatisfy { !$0.name.isEmpty && !$0.quantity.isEmpty } &&
        !instructions.isEmpty &&
        instructions.allSatisfy { !$0.isEmpty }
    }
    
    private func addIngredient() {
        ingredients.append(Ingredient(name: "", quantity: ""))
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func addInstruction() {
        instructions.append("")
    }
    
    private func deleteInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
    }
    
    private func saveRecipe() {
        isLoading = true
        
        let recipe = Recipe(
            name: name,
            category: category,
            description: description,
            ingredients: ingredients.filter { !$0.name.isEmpty },
            instructions: instructions.filter { !$0.isEmpty }
        )
        
        // If there's an image, upload it first
        if let image = selectedImage {
            uploadImage(image, for: recipe)
        } else {
            saveRecipeToFirebase(recipe)
        }
    }
    
    private func uploadImage(_ image: UIImage, for recipe: Recipe) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            showError("Failed to process image")
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("recipe_images/\(imageName)")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                guard let downloadURL = url else {
                    showError("Failed to get download URL")
                    return
                }
                
                var recipeWithImage = recipe
                recipeWithImage.photoURL = downloadURL.absoluteString
                saveRecipeToFirebase(recipeWithImage)
            }
        }
    }
    
    private func saveRecipeToFirebase(_ recipe: Recipe) {
        viewModel.addRecipe(recipe) { error in
            isLoading = false
            
            if let error = error {
                showError(error.localizedDescription)
            } else {
                dismiss()
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        isLoading = false
    }
}

#Preview {
    AddRecipeView(viewModel: RecipeViewModel())
}
