//
//  CheckedContinuationBootcamp.swift
//  CheckContinuationBootcamp
//
//  Created by Dean Thompson on 2022/06/15.
//

import SwiftUI

class CheckedContinuationBootcampDataManager {
    
    func getData(with url: URL) async throws -> Data {
        do {
            let (data, _) =  try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw URLError(.badURL)
        }
    }
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    let manager = CheckedContinuationBootcampDataManager()
    
    @Published var image: UIImage? = nil
    
    func getImage() async {
        do {
            guard let url = URL(string: "https://picsum.photos/300") else { return }
            
            let data = try await manager.getData(with: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CheckedContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
