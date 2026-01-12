import RemoveMarkdown

// MARK: - Basic Examples

func basicExample() {
    let markdown = """
    # This is a heading

    This is a paragraph with [a link](http://www.disney.com/) in it.
    """

    let plainText = removeMarkdown(markdown)
    print(plainText)
    // Output: "This is a heading\n\nThis is a paragraph with a link in it."
}

// MARK: - Emphasis Removal

func emphasisExample() {
    let text = "I italicized an *I* and it _made_ me *sad*."
    let result = removeMarkdown(text)
    print(result)
    // Output: "I italicized an I and it made me sad."
}

// MARK: - List Handling

func listExample() {
    let markdown = """
    Shopping list:

    * Apples
    * Bananas
    * Oranges

    Steps:

    1. Go to store
    2. Buy items
    3. Come home
    """

    let result = removeMarkdown(markdown)
    print(result)
    // Output will have list items without markers
}

// MARK: - Custom Options

func customOptionsExample() {
    let markdown = "![Logo](https://example.com/logo.png)"

    // With alt text
    let withAlt = removeMarkdown(markdown, options: RemoveMarkdownOptions(useImgAltText: true))
    print(withAlt) // Output: "Logo"

    // Without alt text
    let withoutAlt = removeMarkdown(markdown, options: RemoveMarkdownOptions(useImgAltText: false))
    print(withoutAlt) // Output: ""
}

// MARK: - Preserving HTML Tags

func htmlTagsExample() {
    let markdown = "<div>Content with <sub>subscript</sub> and <sup>superscript</sup></div>"

    let options = RemoveMarkdownOptions(htmlTagsToSkip: ["sub"])
    let result = removeMarkdown(markdown, options: options)
    print(result)
    // Output: "Content with <sub>subscript</sub> and superscript"
}

// MARK: - Code Blocks

func codeBlockExample() {
    let markdown = """
    Here's some code:

    ```swift
    func hello() {
        print("Hello, World!")
    }
    ```

    And inline code: `let x = 5`
    """

    let result = removeMarkdown(markdown)
    print(result)
    // Code content is preserved but markdown syntax is removed
}

// MARK: - Complex Document

func complexExample() {
    let markdown = """
    # User Guide

    Welcome to **our application**!

    ## Features

    - Easy to use
    - *Fast* performance
    - **Reliable** results

    > This is an important note

    For more info, visit [our website](https://example.com).

    ### Installation

    Run the following command:

    ```bash
    npm install our-package
    ```

    That's it! You're ready to go.
    """

    let plainText = removeMarkdown(markdown)
    print(plainText)
    // All markdown syntax will be removed, leaving clean text
}

// MARK: - Usage in Real Application

class BlogPost {
    let title: String
    let content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    var excerpt: String {
        // Create a plain text excerpt from markdown content
        let plainText = removeMarkdown(content)
        let words = plainText.split(separator: " ")
        let first50Words = words.prefix(50).joined(separator: " ")
        return first50Words + (words.count > 50 ? "..." : "")
    }
}

func blogPostExample() {
    let post = BlogPost(
        title: "Getting Started",
        content: """
        # Introduction

        This is a **comprehensive guide** to getting started with *our service*.

        ## Prerequisites

        - Basic knowledge of programming
        - A computer with internet access

        Let's dive in!
        """
    )

    print("Title: \(post.title)")
    print("Excerpt: \(post.excerpt)")
}
