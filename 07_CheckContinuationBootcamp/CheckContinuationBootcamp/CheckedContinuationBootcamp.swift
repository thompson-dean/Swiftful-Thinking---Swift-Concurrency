//
//  CheckedContinuationBootcamp.swift
//  CheckContinuationBootcamp
//
//  Created by Dean Thompson on 2022/06/15.
//

import SwiftUI

class CheckedContinuationBootcampDataManager {
    
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    let manager = CheckedContinuationBootcampDataManager()
    
    @Published var image: UIImage? = nil
    
    func getImage() async {
        
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
