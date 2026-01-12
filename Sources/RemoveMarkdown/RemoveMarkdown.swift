import Foundation

/// Options for configuring markdown removal behavior
public struct RemoveMarkdownOptions {
    /// Whether to strip list leaders (*, -, +, digits followed by .)
    public var stripListLeaders: Bool

    /// Unicode character to insert instead of stripped list leaders
    public var listUnicodeChar: String?

    /// Support GitHub-Flavored Markdown
    public var gfm: Bool

    /// Replace images with their alt-text, if present
    public var useImgAltText: Bool

    /// Remove abbreviations
    public var abbr: Bool

    /// Replace links with their URL instead of link text
    public var replaceLinksWithURL: Bool

    /// HTML tags to skip when removing HTML
    public var htmlTagsToSkip: [String]

    /// Whether to throw errors or return original text on error
    public var throwError: Bool

    public init(
        stripListLeaders: Bool = true,
        listUnicodeChar: String? = nil,
        gfm: Bool = true,
        useImgAltText: Bool = true,
        abbr: Bool = false,
        replaceLinksWithURL: Bool = false,
        htmlTagsToSkip: [String] = [],
        throwError: Bool = false
    ) {
        self.stripListLeaders = stripListLeaders
        self.listUnicodeChar = listUnicodeChar
        self.gfm = gfm
        self.useImgAltText = useImgAltText
        self.abbr = abbr
        self.replaceLinksWithURL = replaceLinksWithURL
        self.htmlTagsToSkip = htmlTagsToSkip
        self.throwError = throwError
    }
}

/// Removes Markdown formatting from text
public func removeMarkdown(_ markdown: String, options: RemoveMarkdownOptions = RemoveMarkdownOptions()) -> String {
    var output = markdown

    do {
        // Remove backslash escapes
        output = output.replacingOccurrences(of: "\\", with: "")

        // Remove horizontal rules (must be first to avoid conflict with stripListLeaders)
        output = try replaceAll(in: output, pattern: "^ {0,3}((?:-[\\t ]*){3,}|(?:_[ \\t]*){3,}|(?:\\*[ \\t]*){3,})(?:\\n+|$)", options: [.anchorsMatchLines], replacement: "")

        if options.stripListLeaders {
            if let unicodeChar = options.listUnicodeChar {
                output = try replaceAll(in: output, pattern: "^([\\s\\t]*)([\\*\\-\\+]|\\d+\\.)\\s+", options: [.anchorsMatchLines], replacement: "\(unicodeChar) $1")
            } else {
                output = try replaceAll(in: output, pattern: "^([\\s\\t]*)([\\*\\-\\+]|\\d+\\.)\\s+", options: [.anchorsMatchLines], replacement: "$1")
            }
        }

        if options.gfm {
            // Header underlines
            output = try replaceAll(in: output, pattern: "\\n={2,}", replacement: "\n")
            // Fenced codeblocks with tildes
            output = try replaceAll(in: output, pattern: "~{3}.*\\n", replacement: "")
            // Strikethrough
            output = try replaceAll(in: output, pattern: "~~", replacement: "")
            // Fenced codeblocks with backticks
            output = try replaceCodeBlocks(in: output)
        }

        if options.abbr {
            // Remove abbreviations
            output = try replaceAll(in: output, pattern: "\\*\\[.*\\]:.*\\n", replacement: "")
        }

        // Handle HTML tags
        let htmlReplacePattern: String
        if !options.htmlTagsToSkip.isEmpty {
            let joinedTags = options.htmlTagsToSkip.joined(separator: "|")
            htmlReplacePattern = "<(?!/?(\(joinedTags))(?=>|\\s[^>]*>))[^>]*>"
        } else {
            htmlReplacePattern = "<[^>]*>"
        }

        output = try replaceAll(in: output, pattern: htmlReplacePattern, replacement: "")

        // Remove setext-style headers
        output = try replaceAll(in: output, pattern: "^[=\\-]{2,}\\s*$", options: [.anchorsMatchLines], replacement: "")

        // Remove footnotes
        output = try replaceAll(in: output, pattern: "\\[\\^.+?\\](\\: .*?$)?", options: [.anchorsMatchLines], replacement: "")
        output = try replaceAll(in: output, pattern: "\\s{0,2}\\[.*?\\]: .*?$", options: [.anchorsMatchLines], replacement: "")

        // Remove images
        let imageReplacement = options.useImgAltText ? "$1" : ""
        output = try replaceAll(in: output, pattern: "\\!\\[(.*?)\\][\\[\\(].*?[\\]\\)]", replacement: imageReplacement)

        // Remove inline links
        let linkReplacement = options.replaceLinksWithURL ? "$2" : "$1"
        output = try replaceAll(in: output, pattern: "\\[([\\s\\S]*?)\\]\\s*[\\(\\[].*?[\\)\\]]", options: [.dotMatchesLineSeparators], replacement: linkReplacement)

        // Remove blockquotes
        output = try replaceAll(in: output, pattern: "^(\\n)?\\s{0,3}>\\s?", options: [.anchorsMatchLines], replacement: "$1")

        // Remove reference-style links
        output = try replaceAll(in: output, pattern: "^\\s{1,2}\\[(.*?)\\]: (\\S+)( \".*?\")?\\s*$", options: [.anchorsMatchLines], replacement: "")

        // Remove atx-style headers
        output = try replaceAll(in: output, pattern: "^(\\n)?\\s{0,}#{1,6}\\s*( (.+))? +#+$|^(\\n)?\\s{0,}#{1,6}\\s*( (.+))?$", options: [.anchorsMatchLines], replacement: "$1$3$4$6")

        // Remove * emphasis
        output = try replaceAll(in: output, pattern: "([\\*]+)(\\S)(.*?\\S)??\\1", replacement: "$2$3")

        // Remove _ emphasis (with whitespace rules)
        output = try replaceAll(in: output, pattern: "(^|\\W)([_]+)(\\S)(.*?\\S)??\\2($|\\W)", options: [.anchorsMatchLines], replacement: "$1$3$4$5")

        // Remove single-line code blocks
        output = try replaceAll(in: output, pattern: "(`{3,})(.*?)\\1", options: [.anchorsMatchLines], replacement: "$2")

        // Remove inline code
        output = try replaceAll(in: output, pattern: "`(.+?)`", replacement: "$1")

        // Replace strike through
        output = try replaceAll(in: output, pattern: "~(.*?)~", replacement: "$1")

    } catch {
        if options.throwError {
            print("remove-markdown encountered error: \(error)")
            return markdown
        }
        print("remove-markdown encountered error: \(error)")
        return markdown
    }

    return output
}

// MARK: - Helper Functions

private func replaceAll(in string: String, pattern: String, options: NSRegularExpression.Options = [], replacement: String) throws -> String {
    let regex = try NSRegularExpression(pattern: pattern, options: options)
    let range = NSRange(string.startIndex..., in: string)
    return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
}

private func replaceCodeBlocks(in string: String) throws -> String {
    let pattern = "```(?:.*)\\n([\\s\\S]*?)```"
    let regex = try NSRegularExpression(pattern: pattern, options: [])
    let nsString = string as NSString
    let range = NSRange(location: 0, length: nsString.length)

    var result = string
    var offset = 0

    regex.enumerateMatches(in: string, options: [], range: range) { match, _, _ in
        guard let match = match, match.numberOfRanges >= 2 else { return }

        let fullMatchRange = match.range
        let codeRange = match.range(at: 1)

        if codeRange.location != NSNotFound {
            let code = nsString.substring(with: codeRange).trimmingCharacters(in: .whitespacesAndNewlines)

            let adjustedRange = NSRange(location: fullMatchRange.location + offset, length: fullMatchRange.length)
            let resultNSString = result as NSString
            result = resultNSString.replacingCharacters(in: adjustedRange, with: code)

            offset += code.count - fullMatchRange.length
        }
    }

    return result
}
