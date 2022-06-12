//
//  DoCatchTryThrowsBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Dean Thompson on 2022/06/12.
//

import SwiftUI

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT", nil)
        } else {
            return (nil, URLError(.badURL))
        }
        
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "New Text!"
//        } else {
            throw URLError(.badURL)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text!"
        } else {
            throw URLError(.badURL)
        }
    }
}


class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    @Published var text: String = "Starting Text"
    
    
    func fetchTitle() {
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
        
        
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
    
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch let error {
            self.text = error.localizedDescription
        }
        
        
        //        let result = manager.getTitle2()
        //        switch result {
        //        case .success(let newTitle):
        //            self.text = newTitle
        //        case .failure(let error):
        //            self.text = error.localizedDescription
        
        //        let returnedValue =  manager.getTitle()
        //        if let newTitle = returnedValue.title {
        //            self.text = newTitle
        //        } else if let error = returnedValue.error {
        //            self.text = error.localizedDescription
        //        }
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
