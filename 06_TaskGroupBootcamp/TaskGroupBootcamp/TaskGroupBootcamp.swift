//
//  TaskGroupBootcamp.swift
//  TaskGroupBootcamp
//
//  Created by Dean Thompson on 2022/06/15.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
    
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                group.addTask {
                    try await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await taskResult in group {
                images.append(taskResult)
            }
            
            return images
        }
    }
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        do {
            async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
            
            let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
            
            return [image1, image2, image3, image4]
            
        } catch {
            throw URLError(.badServerResponse)
        }
        
    }
   
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    
    let manager = TaskGroupBootcampDataManager()
    
    @Published var images: [UIImage] = []
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("TaskGroup")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
