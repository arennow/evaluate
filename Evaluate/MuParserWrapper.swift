//
//  MuParserWrapper.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import Foundation
import RegexKitLite

extension MuParserWrapper {
	struct EvaluationResult {
		let result: Double
		let mangledExpression: String
	}
	
	func evaluate(_ expression: String) throws -> EvaluationResult {
		let mangledExpression = MuParserWrapper.mangleInputString(expression)
		
		var result: Double = 0
		try self.evaluate(mangledExpression, result: &result)
		
		return EvaluationResult(result: result, mangledExpression: mangledExpression)
	}

	fileprivate static func mangleInputString(_ str: String) -> String {
		func innerMangler(_ str: NSMutableString) -> NSMutableString {
			let mangledString = NSMutableString(string: str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
			
			mangledString.replaceOccurrences(of: "**", with: "^", options: .literal, range: NSRange(location: 0, length: mangledString.length))
			
			mangledString.replaceOccurrences(ofRegex: "^([\\-\\+\\/\\*^])", with: "P$1")
			
			mangledString.replaceOccurrences(ofRegex: "([\\d\\)P])\\(", with: "$1*(")
			mangledString.replaceOccurrences(ofRegex: "\\)([\\d\\(P])", with: ")*$1")
			mangledString.replaceOccurrences(ofRegex: "P([\\dP]+)", with: "P*$1")
			mangledString.replaceOccurrences(ofRegex: "([\\dL]+)P", with: "$1*P")
			
			return mangledString
		}
		
		let mutStr = NSMutableString(string: str)
		
		var stringToMangle = mutStr
		var first: NSMutableString?
		var second: NSMutableString?
		
		repeat {
			first = innerMangler(stringToMangle)
			second = innerMangler(first!)
			
			stringToMangle = second!
		} while (first != second)
		
		return second! as String
	}
}
