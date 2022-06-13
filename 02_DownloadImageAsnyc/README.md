## Lesson 2 - Download images with Async/Await, @escaping, and Combine  

This lessons runs through all the different ways asynchronous code can be handled in swift. It first covers the ways used before swift concurrency existed, namely @escaping and the combine framework.  

@escaping and combine are handled as so in the ImageLoader class. 

```
class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300
        else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completion(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
}    
```
And then implemented in the View Model as such.

@escaping
```
class DownloadImageAsyncViewModel: ObservableObject {

    let loader = DownloadImageAsyncImageLoader()
    @Published var image: UIImage? = nil
    
    func fetchImage() {
        
        loader.downloadWithEscaping { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    } 
}
```

Combine
```
class DownloadImageAsyncViewModel: ObservableObject {

    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    @Published var image: UIImage? = nil
    
    func fetchImage() {
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }
}
```
Add notes here

```
class DownloadImageAsyncImageLoader {
    ....
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
}
```
View Model
```
class DownloadImageAsyncViewModel: ObservableObject {

    let loader = DownloadImageAsyncImageLoader()
    @Published var image: UIImage? = nil
    
    func fetchImage() async {
        
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }  
}
```
SwiftUI View
```
struct DownloadImageAsync: View {
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}
```