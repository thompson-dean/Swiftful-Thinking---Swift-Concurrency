## Lesson 6 - How to use TaskGroup to perform concurrent tasks in Swift.

In this lesson we will learn an efficient way to deal with many API calls in a neat manner.

There are a couple of types of TaskGroups, mainly being withThrowingTaskGroup(of: , body:) and withTaskGroup(of: , body: ). If you are inside an async throws function then use the former, if not use the latter.

You can loop through all your API Calls by placing them in an array. Each call will be added to the group and then simply after they have all been added to the group loop through the group and append them to the images. Simple and efficient! Take a look at the code below!

```
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
```
