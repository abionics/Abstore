//
//  Parser.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

class Parser {
    typealias VariablesCode = [Character: Set<Infile>]

    //non-static for multy-thread use (you can run Parser instance in several threads)
    private let operators: [Character: (priority: Int, action: (Set<Infile>, Set<Infile>) -> Set<Infile>)] =
        [Character(" "): (1, { $0.intersection($1) }),
         Character(","): (2, { $0.union($1) })]
    private static let replaces = ["&&": " ",
                           "||": ",",
                           ", ": ","]
    static var reserved: [String] {
        get {
            var reserved = [String](Parser.replaces.keys) + [String](Parser.replaces.values)
            reserved.remove(object: " " as AnyObject)
            return reserved
        }
    }
    private let reserved = 128
    private let endline: Character = "\n"
    
    func parse(expression: String, tags: TagsKeeper) throws -> Set<Infile> {
        var expression = compress(expression);
        let variables: VariablesCode
        (expression, variables) = try detect(expression, tags);
        
        return try calculate(try translate(expression), variables);
    }
    
    func compress(_ expression: String) -> String {
        var result = expression.trimAndClean()
        for replace in Parser.replaces {
            result = result.replacingOccurrences(of: replace.key, with: replace.value)
        }
        return result
    }
    
    func detect(_ expression: String, _ tags: TagsKeeper) throws -> (expression: String, variables: VariablesCode) {
        let expression = expression + String(endline)
        var word = ""
        var result = ""
        var variables = VariablesCode()
        for letter in expression {
            if letter == "(" || letter == ")" || letter == endline || operators.keys.contains(letter) {
                let name = word.trimmingCharacters(in: .whitespacesAndNewlines)
                if (!name.isEmpty) {
                    guard let tag = tags.get(name: name) else {
                        if letter == " " {
                            word.append(" ")
                            continue
                        } else {
                            throw ParserError.invalidTagName(name)
                        }
                    }
                    let unicode = UnicodeScalar(reserved + variables.count)
                    let code: Character = Character(unicode!) //code - char values, which begin from @reserved
                    let infiles = tag.infiles as! Set<Infile> //infiles - duplicated (new pointer) for safe changes
                    variables[code] = infiles
                    result.append(code)
                }
                if letter == endline {
                    break
                }
                result.append(letter);
                word = ""
            } else {
                word.append(letter)
            }
        }
        return (result, variables)
    }
    
    func translate(_ expression: String) throws -> String {
        var stack = [Character]()
        var result = ""
        for token in expression {
            if (token.unicode >= reserved) {
                result.append(token);
                continue;
            }
            if token == "(" {
                stack.append(token)
                continue
            }
            if let prior = operators[token]?.priority {
                while !stack.isEmpty && stack.last != "(" {
                    let last = stack.last!
                    if (operators[last]!.priority > prior) {
                        result.append(last)
                        stack.removeLast()
                    } else {
                        break
                    }
                }
                stack.append(token)
                continue
            }
            if token == ")" {
                while !stack.isEmpty && stack.last != "(" {
                    result.append(stack.last!);
                    stack.removeLast()
                }
                if stack.isEmpty {
                    throw ParserError.parseError("Mistake in \"(\" or \")\", or incorrect order of priority in token = '" + token + "'")
                }
                stack.removeLast()
                continue
            }
            if (token == " ") {
                continue
            }
            throw ParserError.parseError("Mistake in \"(\" or \")\", or incorrect order of priority in token = '" + token + "'");
        }
        
        while !stack.isEmpty {
            if stack.last == "(" {
                throw ParserError.parseError("Missing \")\" or extra \"(\"");
            }
            result.append(stack.last!);
            stack.removeLast();
        }
        
        return result
    }
    
    func calculate(_ expression: String, _ values: VariablesCode) throws -> Set<Infile> {
        if expression.isEmpty {
            throw ParserError.parseError("Empty expression \"\"");
        }
        
        var stack = [Set<Infile>]()
        for token in expression {
            if let variable = values[token] {
                stack.append(variable)
                continue
            }
            if operators[token]?.priority != nil {
                if stack.count < 2 {
                    throw ParserError.parseError("Operation (token = '" + token + "') dont have enough arguments");
                }
                let first = stack.removeLast()
                let second = stack.removeLast()
                stack.append((operators[token]!.action(first, second)))
                continue
            }
            throw ParserError.parseError("Undefined operator, token = '" + token + "'");
        }
        
        if stack.count != 1 {
            throw ParserError.parseError("Wrong count of elements in stack = " + String(stack.count));
        }
        
        return stack.last!
    }
}

enum ParserError: Error {
    case invalidTagName(String)
    case parseError(String)
    
    var localizedDescription: String {
        switch self {
            case .invalidTagName(let name): return "No tag with name " + name
            case .parseError(let reason): return reason
        }
    }
}
