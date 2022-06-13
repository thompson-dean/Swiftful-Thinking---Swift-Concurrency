## Lesson 2 - Download images with Async/Await, @escaping, and Combine

This lessons runs through different ways to handle asynchronous code / API Calls in swift. In this lesson we are trying to take a random photo from an API and show it on our screen. It first covers the ways to do this that were commonly used before Swift Concurrency(async / await) existed - namely completion handler with @escaping and the combine framework (Publishers).

@escaping and combine are handled as below in an ImageLoader class.

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

The fetchImage() function is called in an .onAppear block in a swiftUI view.

Ok, So I am sure you have seen Combine and @espacing before, let's get into async / await!

The first thing you will notice when attempting to use Swift Concurrency is that the autocomplete function will be greyed out. It is paramount to add async after the () like this: func doSomething() async { } other wise it will not be able to be chosen.

URLSession.shared.data(from: , delegate: ) also throws, so the try keyword will be needed. Since the function is al asynchronous in nature we need to add the await keyword after try - we will literally be waiting for the result / response.

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

Let's run the loader in the View Model.

You'll notice your downloadWithAsync() function will not be able to enter auto complete. It is for the same reason above. you will need to add async afteer the fetchImage() function.

As above you will need to add await after the try keyword. This is a suspension point and it could take time to receive the result.

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

Add this to your .onAppear on the SwiftUI view.
A whole host of errors will appear. These reason that it does not work is that inorder to use an async function you need to enter a Task to get into an asynchronous context. once the function call is placed in the Task { } then use the keyword await before the function and all will work.

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

You will notice in the View Model we are not using DispatchQueue.main.async { } to get back on to the main thread. If we are using swift concurrency we will use await MainActor.run { }.

```
await MainActor.run {
            self.image = image
        }
```

This will be explain in more detail in later lessons.
