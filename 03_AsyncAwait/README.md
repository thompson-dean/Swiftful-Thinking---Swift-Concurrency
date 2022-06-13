## Lesson 3 - How to use async / await keywords in Swift.

This lesson goes deeper into the inner workings of async await. Before Swift Concurrency was introduced it was necessary to explicitly use DispatchQueue to choose when or not to be on a main or background thread. 

For example:
```
func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title 1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title2 = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title2)
                
                let title3 = "Title3: \(Thread.current)"
                self.dataArray.append(title3)
                
            }
        }
    }
```
Here title1 and title 3 are on the main thread and title2 is done on a background thread. Using async / await is not necessary to specify which thread you are on.

Also when dealing with delays with DispatchQueue one can use .asyncAfter(deadline: .now() + 2) { }. In SwiftConcurrency delays are dealt by refering to Tasks, as so:
```
func addAuthor() async {
        let author1 = "Author 1: \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author 2: \(Thread.current)"
        self.dataArray.append(author2)
    }
```
You will notice that we have also not explicitly told author2 to be on a background thread by async automatically did it by itself. Sometimes await will enter a background thread, sometimes it will not. await is just a suspension point in a Task. 

Of course that code above is not great, as changing the UI on a background thread is bad practice. 

add await MainActor.run()
```
 func addAuthor() async {
        let author1 = "Author 1: \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author 2: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)
        } 
    }
```
awaits are completed in top down order. 
```
.onAppear {
    Task {
        await viewModel.addAuthor()
        await viewModel.doSomething()
        
        let finalText = "FINAL TEXT: \(Thread.current)"
        viewModel.dataArray.append(finalText)
    }
}
```
viewModel.addAuthor() THEN await viewModel.doSomething() Then finaltext will be appended to dataArray. 