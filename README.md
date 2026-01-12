# swift-remove-markdown

[![Swift Version](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://github.com/Yvent/swift-remove-markdown)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> 📝 **Swift port of the popular [remove-markdown](https://github.com/zuchka/remove-markdown) package**
> Maintains 100% feature parity with the original Node.js implementation

A Swift package that removes (strips) Markdown formatting from text.

## What is it?

**RemoveMarkdown** is a Swift package that will remove Markdown formatting from text. *Markdown formatting* means pretty much anything that doesn't look like regular text, like square brackets, asterisks, etc.

## When do I need it?

The typical use case is to display an excerpt from some Markdown text, without any of the actual Markdown syntax - for example in a list of posts.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Yvent/swift-remove-markdown.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Package Dependencies...
2. Enter the repository URL
3. Select your version requirements

## Usage

### Basic Usage

```swift
import RemoveMarkdown

let markdown = """
# This is a heading

This is a paragraph with [a link](http://www.disney.com/) in it.
"""

let plainText = removeMarkdown(markdown)
// Result: "This is a heading\n\nThis is a paragraph with a link in it."
```

### With Options

You can customize the behavior by passing an `RemoveMarkdownOptions` struct:

```swift
import RemoveMarkdown

let options = RemoveMarkdownOptions(
    stripListLeaders: true,    // strip list leaders (default: true)
    listUnicodeChar: nil,      // char to insert instead of stripped list leaders (default: nil)
    gfm: true,                 // support GitHub-Flavored Markdown (default: true)
    useImgAltText: true,       // replace images with alt-text, if present (default: true)
    abbr: false,               // remove abbreviations (default: false)
    replaceLinksWithURL: false, // replace links with URL instead of text (default: false)
    htmlTagsToSkip: [],        // HTML tags to preserve (default: [])
    throwError: false          // throw errors instead of returning original text (default: false)
)

let plainText = removeMarkdown(markdown, options: options)
```

### Options Explained

- **`stripListLeaders`**: When `true`, removes list markers like `*`, `-`, `+`, and numbered lists like `1.`
- **`listUnicodeChar`**: If provided, replaces list leaders with this character instead of removing them entirely
- **`gfm`**: Enables GitHub-Flavored Markdown support (strikethrough, fenced code blocks, etc.)
- **`useImgAltText`**: When `true`, replaces image syntax with the alt text; when `false`, removes images entirely
- **`abbr`**: Removes abbreviation definitions when `true`
- **`replaceLinksWithURL`**: When `true`, replaces `[text](url)` with `url` instead of `text`
- **`htmlTagsToSkip`**: Array of HTML tag names to preserve in the output
- **`throwError`**: When `true`, throws errors; when `false`, prints error and returns original text

## Examples

### Stripping Emphasis

```swift
let text = "I italicized an *I* and it _made_ me *sad*."
let result = removeMarkdown(text)
// Result: "I italicized an I and it made me sad."
```

### Removing Headers

```swift
let text = "## This is a heading"
let result = removeMarkdown(text)
// Result: "This is a heading"
```

### Handling Lists

```swift
let text = """
* Item 1
* Item 2
* Item 3
"""
let result = removeMarkdown(text)
// Result: "Item 1\nItem 2\nItem 3"
```

### Preserving Specific HTML Tags

```swift
let text = "<div>Content <sub>subscript</sub> <span>text</span></div>"
let options = RemoveMarkdownOptions(htmlTagsToSkip: ["sub"])
let result = removeMarkdown(text, options: options)
// Result: "Content <sub>subscript</sub> text"
```

## Platform Support

- macOS 10.15+
- iOS 13.0+
- tvOS 13.0+
- watchOS 6.0+

## Testing

Run tests using Swift Package Manager:

```bash
cd swift-remove-markdown
swift test
```

Or in Xcode:
1. Open `Package.swift`
2. Press `⌘U` to run tests

## Credits

This is a Swift port of the **[remove-markdown](https://github.com/zuchka/remove-markdown)** package:

- **Original JavaScript implementation**: [Stian Grytøyr](https://github.com/stiang) (creator)
- **Current maintainer**: [zuchka](https://github.com/zuchka)
- **Original inspiration**: [Markdown Service Tools](http://brettterpstra.com/2013/10/18/a-markdown-service-to-strip-markdown/) by Brett Terpstra

All regex patterns and test cases are ported from the original package to ensure behavioral consistency.

## License

MIT License - see [LICENSE](LICENSE) file for details.

This Swift port maintains the same MIT License as the original [remove-markdown](https://github.com/zuchka/remove-markdown) package.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development

To work on this package:

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Make your changes
4. Run tests to ensure everything works
5. Submit a pull request

## Future Enhancements

- Allow customization of regex patterns per rule
- Support for more edge cases
- Additional comprehensive tests
- Performance optimizations
