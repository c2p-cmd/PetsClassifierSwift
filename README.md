# PetsClassifier Demo App

![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgoogle%2Fgenerative-ai-swift%2Fbadge%3Ftype%3Dswift-versions)

<img src="https://developer.apple.com/assets/elements/icons/create-ml/create-ml-96x96_2x.png" height=50px>
</img>

### A multi-platform app for showcasing my [Pets Image Classifier CoreML Model](https://huggingface.co/c2p-cmd/PetsImageClassifier)

### Usage:
```swift
// create the model instance
let model = try PetsClassifier()

// prepare image
let uiImage: UIImage = .....
let nsImage: NSImage = .....

if let buffer = uiImage.colorPixelBuffer() { // or nsImage.colorPixelBuffer() 
    let input = PetsClassifierInput(image: buffer)
    let output = try await model.prediction(input: input)

    print(output.target) // cat
    print(output.targetProbability) // { "cat": 0.99, "dog": 0.1, "rabbit": 0.01 }
}

```
#### Image Conversion Method's Credits:
- UIImage -> CVPixelBuffer [francoismarceau29](https://gist.github.com/francoismarceau29/abac55c22f6e440800d1d73d72bf2225)
- NSImage -> CVPixelBuffer [DennisWeidmann](https://gist.github.com/DennisWeidmann/7c4b4bb72062bd1a40c714aa5d95a0d7)
