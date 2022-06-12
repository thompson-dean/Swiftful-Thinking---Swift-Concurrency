# Swiftful Thinking 

## Swift Concurrency

#### Studying through Swiftful Thinkings's "Swift Concurrency". 
Studying the latest in Swift Concurrency.

https://www.youtube.com/playlist?list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM

## Status

| Type               | Completion |
| :----------------- | :--------: |
| Lessons           |   1/12    |

## Lessons

#### Lesson 1 - Do, Try, Catch, and Throws  

This lesson is all about how to deal errors in swift with particular focus on functions that "throw": 
``` 
func getTitle() throws -> String { } 
``` 
The lesson first goes through ways of dealing with errors using tuples and swift's Result type which looks like this: 

Using tuples
```
func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
```

Using Result Type
```  
    
func getTitle() -> Result<String, Error> {
    if isActive {
        return .success("New Text")
    } else {
        return .failure(URLError(.badURL))
    }
}  
``` 
Instead of having to return 2 values or having to switch through 2 values, we can use functions that use the "throws" keyword. 
``` 
func getTitle() throws -> String {
    if isActive {
        return "Final Text!"
    } else {
        throw URLError(.badURL)
    }
}
``` 
It is important to have a clear understanding of "throws" functions as they are commonly used in asynchronous code in swift. A great way to handle "throws" is to use a do catch block. When referencing the "throws" is very import to place a "try" before it other wise your code will not compile. 
The Code below is an implementation of the getTitle() function in ViewModel.
``` 
func fetchTitle() {
    do {
        let newTitle = try manager.getTitle()
        self.text = newTitle
    } catch let error {
        self.text = error.localizedDescription
    }
}

```
try can also be made an optional, in which case it is not necessary to use do and catch as it will either return nil or a String. 
```
func fetchTitle() {
    let newTitle = try? manager.getTitle3()
    if let newTitle = newTitle {
        self.text = newTitle
    }
}
```


