## Lesson 4 - How to use Task and .task in Swift

In this lesson we quickly set up a async func to fetch an image and display it on the screen. It is very similar to the code used in lesson 2, so I will not post it here. This lesson focuses on the use of Tasks.
Task will run all functions marked with await in order from top to bottom like so:

```
Task {
    await viewModel.fetchImage()
    await viewModel.fetchImage2()
}
```

The first fetchImage() will be fetched first then the fetchImage2() will be processed.

One way to run these calls at the same time is by using two separate tasks.

```
Task {
    await viewModel.fetchImage()
}
Task {
    await viewModel.fetchImage2()
}
```

This will now run at the almost same time.

For Tasks running on the same thread they can be prioritised.
The priority key words are in order from top priority to lowest priority in the code below.

```
Task(priority: .high) {
    print("high: \(Thread.current) : \(Task.currentPriority)")
}
Task(priority: .userInitiated) {
    print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
}
Task(priority: .medium) {
    print("medium: \(Thread.current) : \(Task.currentPriority)")
}
Task(priority: .low) {
    print("low: \(Thread.current) : \(Task.currentPriority)")
}
Task(priority: .utility) {
    print("utility: \(Thread.current) : \(Task.currentPriority)")
}
Task(priority: .background) {
    print("background: \(Thread.current) : \(Task.currentPriority)")
}
```

In the last lesson we learnt try? await Task.sleep(nanoseconds: ) if we want a Task to stop for 2 seconds. If you don't want to specifiy a time, you can also yield a Task like so:

```
Task(priority: .high) {
    await Task.yield()
    print("high: \(Thread.current) : \(Task.currentPriority)")
}
```

Child Tasks take on the same priority as their parent Task.

```
Task(priority: .low) {
    print("userInitiated: \(Thread.current) : \(Task.currentPriority)")

    Task {
        print("userInitiated2: \(Thread.current) : \(Task.currentPriority)")
    }
}
```

```
userInitiated: <_NSMainThread: 0x600003a484c0>{number = 1, name = main} : TaskPriority(rawValue: 25)
userInitiated2: <_NSMainThread: 0x600003a484c0>{number = 1, name = main} : TaskPriority(rawValue: 25)
```

The last part of this lesson focuses on the ways to cancel Tasks. this can be done by declaring a @State task variable. Have it initialised on .onAppear ans then cancelled on .onDisappear as below.

```
struct TaskBootcamp: View {

    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
        }
        .onDisappear {
            fetchImageTask?.cancel()
        }
        .onAppear {
            self.fetchImageTask = Task {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage()
            }
        }
    }
}
```

The way to do this above i actually redundant as Apple rpovides use with a .task modifier will will automatically start and cancel tasks for us when a view appears or disappears. it works like this:

```
struct TaskBootcamp: View {
    @StateObject private var viewModel = TaskBootcampViewModel()

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
    }
}
```

Insanely simple and works the same as the .onAppear / .ondisAppear solution.
