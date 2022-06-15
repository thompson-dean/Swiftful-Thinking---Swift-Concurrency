## Lesson 5 - How to use Async Let to perform concurrent methods in swift.

In previous lessons we learnt how to use await to run tasks in order from top to bottom. We also learnt that you could have Task run concurrently by separating them into separate Tasks. In this lesson we learnt how to run async functions concurrently from a single Task using the keywords asynce let, an asychronous constant.

If we run the code below the pictures will append to the images array then show in a collection view (LazyVGrid in SwiftUI) . The images will show up one by one as each image waits for the previous one to load and then append to the list.

```
.onAppear {
    Task {
        do {

            let image1 = try await fetchImage()
            self.images.append(image1)

            let image2 = try await fetchImage()
            self.images.append(image2)

            let image3 = try await fetchImage()
            self.images.append(image3)

            let image4 = try await fetchImage()
            self.images.append(image4)

            let image5 = try await fetchImage()
            self.images.append(image5)

            } catch {
        }
    }
}
```

So how can we make it so that all of the pictures load THEN they are appended to the list and show at the same time. Let's look at the code below.

```
.onAppear {
    Task {
        do {
            async let fetchImage1 = fetchImage()
            async let fetchImage2 = fetchImage()
            async let fetchImage3 = fetchImage()
            async let fetchImage4 = fetchImage()

            let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)

            self.images.append(contentsOf: [image1, image2, image3, image4])

            } catch {
        }
    }
}
```

Async let allows to store asynchronous calls in a constant. we can simply assign variables to each call and use await on all of the calls so that they wait for each other. After all of the images have been loaded they will append to the list at the same time and show up in the LazyVGrid. The only problem with this method is if there were 10 or more calls needed to be made at the same time. Only use this method for a small amount of asychronous functions. TaskGroup will be the topic of the next lesson and in that we will be able to group together many calls.
