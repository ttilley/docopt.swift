//
//  String.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal extension String {
    func partition(_ separator: String) -> (String, String, String) {
        let components = self.components(separatedBy: separator)
        if components.count > 1 {
            return (components[0], separator, components[1..<components.count].joined(separator: separator))
        }
        return (self, "", "")
    }
    
    func strip() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func findAll(_ regex: String, flags: NSRegularExpression.Options) -> [String] {
        let re = try! NSRegularExpression(pattern: regex, options: flags)
        let all = NSMakeRange(0, self.characters.count)
        let matches = re.matches(in: self, options: [], range: all)
        return matches.map {self[$0.rangeAt(1)].strip()}
    }
    
    func split() -> [String] {
        return self.characters.split(whereSeparator: {$0 == " " || $0 == "\n"}).map(String.init)
    }
    
    func split(_ regex: String) -> [String] {
        let re = try! NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
        let all = NSMakeRange(0, self.characters.count)
        var result = [String]()
        let matches = re.matches(in: self, options: [], range: all)
        if matches.count > 0 {
            var lastEnd = 0
            for match in matches {
                let range = match.rangeAt(1)
                if range.location != NSNotFound {
                    if (lastEnd != 0) {
                        result.append(self[lastEnd..<match.range.location])
                    } else if range.location == 0 {
                        // from python docs: If there are capturing groups in the separator and it matches at the start of the string,
                        // the result will start with an empty string. The same holds for the end of the string:
                        result.append("")
                    }
                    
                    result.append(self[range])
                    lastEnd = range.location + range.length
                    if lastEnd == self.characters.count {
                        // from python docs: If there are capturing groups in the separator and it matches at the start of the string,
                        // the result will start with an empty string. The same holds for the end of the string:
                        result.append("")
                    }
                } else {
                    result.append(self[lastEnd..<match.range.location])
                    lastEnd = match.range.location + match.range.length
                }
            }
            if lastEnd != self.characters.count {
                result.append(self[lastEnd..<self.characters.count])
            }
            return result
        }

        return [self]
    }
    
    func isupper() -> Bool {
        let charset = CharacterSet.uppercaseLetters.inverted
        return self.rangeOfCharacter(from: charset) == nil
    }
    
    subscript(i: Int) -> Character {
        return self[characters.index(startIndex, offsetBy: i)]
    }
    
    subscript(range: Range<Int>) -> String {
        return self[characters.index(startIndex, offsetBy: range.lowerBound)..<characters.index(startIndex, offsetBy: range.upperBound)]
    }

    subscript(range: NSRange) -> String {
        return self[range.location..<range.location + range.length]
    }
}
