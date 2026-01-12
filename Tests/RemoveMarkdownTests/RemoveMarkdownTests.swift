import XCTest
@testable import RemoveMarkdown

final class RemoveMarkdownTests: XCTestCase {

    func testLeaveStringAloneWithoutMarkdown() {
        let string = "Javascript Developers are the best."
        XCTAssertEqual(removeMarkdown(string), string)
    }

    func testStripOutRemainingMarkdown() {
        let string = "*Javascript* developers are the _best_."
        let expected = "Javascript developers are the best."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testLeaveNonMatchingMarkdown() {
        let string = "*Javascript* developers* are the _best_."
        let expected = "Javascript developers* are the best."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testLeaveNonMatchingMarkdownButStripEmptyAnchors() {
        let string = "*Javascript* [developers]()* are the _best_."
        let expected = "Javascript developers* are the best."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripHTML() {
        let string = "<p>Hello World</p>"
        let expected = "Hello World"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripAnchors() {
        let string = "*Javascript* [developers](https://engineering.condenast.io/)* are the _best_."
        let expected = "Javascript developers* are the best."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripImgTags() {
        let string = "![](https://placebear.com/640/480)*Javascript* developers are the _best_."
        let expected = "Javascript developers are the best."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testUseAltTextOfImage() {
        let string = "![This is the alt-text](https://www.example.com/images/logo.png)"
        let expected = "This is the alt-text"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripCodeTags() {
        let string = "In `Getting Started` we set up `something` foo."
        let expected = "In Getting Started we set up something foo."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripSimpleMultilineCodeTags() {
        let string = "```\ncode\n```"
        let expected = "code"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripComplexMultilineCodeBlocksWithLanguage() {
        let string = "```javascript\nconst x = 1;\nconst y = 2;\nconsole.log(x + y);\n```"
        let expected = "const x = 1;\nconst y = 2;\nconsole.log(x + y);"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripMultilineCodeBlocksWithMultipleParagraphs() {
        let string = "Text before\n\n```\ncode line 1\n\ncode line 2\n```\n\nText after"
        let expected = "Text before\n\ncode line 1\n\ncode line 2\n\nText after"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testLeaveHashtagsInHeadings() {
        let string = "## This #heading contains #hashtags"
        let expected = "This #heading contains #hashtags"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveEmphasis() {
        let string = "I italicized an *I* and it _made_ me *sad*."
        let expected = "I italicized an I and it made me sad."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveEmphasisOnlyWithoutSpace() {
        let string = "There should be no _space_, *before* *closing * _ephasis character _."
        let expected = "There should be no space, before *closing * _ephasis character _."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveUnderscoreEmphasisWithSpaceRules() {
        let string = "._Spaces_ _ before_ and _after _ emphasised character results in no emphasis."
        let expected = ".Spaces _ before_ and _after _ emphasised character results in no emphasis."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveDoubleEmphasis() {
        let string = "**this sentence has __double styling__**"
        let expected = "this sentence has double styling"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testNotMistakeHorizontalRuleWhenSymbolsMixed() {
        let string = "Some text on a line\n\n--*\n\nA line below"
        let expected = "Some text on a line\n\n--*\n\nA line below"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveHorizontalRules() {
        let string = "Some text on a line\n\n---\n\nA line below"
        let expected = "Some text on a line\n\nA line below"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveHorizontalRulesWithSpaceSeparatedAsterisks() {
        let string = "Some text on a line\n\n* * *\n\nA line below"
        let expected = "Some text on a line\n\nA line below"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveBlockquotes() {
        let string = ">I am a blockquote"
        let expected = "I am a blockquote"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveBlockquotesWithSpaces() {
        let string = "> I am a blockquote"
        let expected = "I am a blockquote"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveIndentedBlockquotes() {
        let tests = [
            (" > I am a blockquote", "I am a blockquote"),
            ("  > I am a blockquote", "I am a blockquote"),
            ("   > I am a blockquote", "I am a blockquote"),
        ]
        for (string, expected) in tests {
            XCTAssertEqual(removeMarkdown(string), expected)
        }
    }

    func testRemoveBlockquotesOverMultipleLines() {
        let string = "> I am a blockquote firstline  \n>I am a blockquote secondline"
        let expected = "I am a blockquote firstline  \nI am a blockquote secondline"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveBlockquotesFollowingOtherContent() {
        let string = "## A headline\n\nA paragraph of text\n\n> I am a blockquote"
        let expected = "A headline\n\nA paragraph of text\n\nI am a blockquote"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testNotRemoveGreaterThanSigns() {
        let tests = [
            ("100 > 0", "100 > 0"),
            ("100 >= 0", "100 >= 0"),
            ("100>0", "100>0"),
            ("> 100 > 0", "100 > 0"),
            ("1 < 100", "1 < 100"),
            ("1 <= 100", "1 <= 100"),
        ]
        for (string, expected) in tests {
            XCTAssertEqual(removeMarkdown(string), expected)
        }
    }

    func testStripUnorderedListLeaders() {
        let string = "Some text on a line\n\n* A list Item\n* Another list item"
        let expected = "Some text on a line\n\nA list Item\nAnother list item"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripOrderedListLeaders() {
        let string = "Some text on a line\n\n9. A list Item\n10. Another list item"
        let expected = "Some text on a line\n\nA list Item\nAnother list item"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStripListItemsWithBoldWordInBeginning() {
        let string = "Some text on a line\n\n- **A** list Item\n- **Another** list item"
        let expected = "Some text on a line\n\nA list Item\nAnother list item"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testHandleParagraphsWithMarkdown() {
        let paragraph = "\n## This is a heading ##\n\nThis is a paragraph with [a link](http://www.disney.com/).\n\n### This is another heading\n\nIn `Getting Started` we set up `something` foo.\n\n  * Some list\n  * With items\n    * Even indented"
        let expected = "\nThis is a heading\n\nThis is a paragraph with a link.\n\nThis is another heading\n\nIn Getting Started we set up something foo.\n\n  Some list\n  With items\n    Even indented"
        XCTAssertEqual(removeMarkdown(paragraph), expected)
    }

    func testRemoveLinks() {
        let string = "This is a [link](http://www.disney.com/)."
        let expected = "This is a link."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testRemoveLinksWithSquareBrackets() {
        let string = "This is a [link [with brackets]](http://www.disney.com/)."
        let expected = "This is a link [with brackets]."
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testNotStripParagraphsWithoutContent() {
        let paragraph = "\n#This paragraph\n##This paragraph#"
        let expected = paragraph
        XCTAssertEqual(removeMarkdown(paragraph), expected)
    }

    func testNotTriggerReDoSWithAtxHeaders() {
        let start = Date()
        let paragraph = "\n## This is a long \"\(String(repeating: " ", count: 200))\" heading ##\n"
        let result = removeMarkdown(paragraph)
        let duration = Date().timeIntervalSince(start)

        XCTAssertTrue(result.contains("This is a long"))
        XCTAssertLessThan(duration, 1.0)
    }

    func testWorkFastEvenWithLotsOfWhitespace() {
        let string = "Some text with lots of                                                                                                                                                                                                       whitespace"
        let expected = "Some text with lots of                                                                                                                                                                                                       whitespace"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testStillRemoveEscapedMarkdownSyntax() {
        let string = "\\# Heading in _italic_"
        let expected = "Heading in italic"
        XCTAssertEqual(removeMarkdown(string), expected)
    }

    func testSkipSpecifiedHTMLTagsWhenHtmlTagsToSkipOptionProvided() {
        let markdown = "<div>HTML content <sub>Superscript</sub> <span>span text</span></div>"

        let result1 = removeMarkdown(markdown, options: RemoveMarkdownOptions(htmlTagsToSkip: ["sub"]))
        XCTAssertEqual(result1, "HTML content <sub>Superscript</sub> span text")

        let result2 = removeMarkdown(markdown, options: RemoveMarkdownOptions(htmlTagsToSkip: ["sub", "span"]))
        XCTAssertEqual(result2, "HTML content <sub>Superscript</sub> <span>span text</span>")
    }
}
