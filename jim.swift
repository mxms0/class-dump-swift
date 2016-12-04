#!/usr/bin/swift
import Foundation

class NestA {
	class NestB {
		class NestC {
			
			init(_ a: String) {
				self.ABC = [""]
			}
			
			let ABC:[String]
		}
		
	}
	
}

class State {
	
	init(_ affairs:[String:AnyObject]) {
		self.💩 = affairs
	}
	
	func mutate(_ like:(([String:AnyObject]) -> [String:AnyObject])) -> State {
		return State(like(self.💩))
	}
	
	var description:String {
		return 💩.description
	}
	
	private
	let 💩:[String:AnyObject]
}

protocol Aggitatable {
	var state:State { get set }
}

class Aggitator {
	
	static let attributes:[String] = ["FartCapacitance", "ElectrostaticReactance", "ElectrostaticResistance", "HealthPoints"]
	
	var aggitatees:[Aggitatable]
	
	init(_ aggitatee: Aggitatable) {
		self.aggitatees = [aggitatee]
	}
	
	init(_ aggitatees: [Aggitatable]) {
		self.aggitatees = aggitatees
	}
	
	func aggitate(_ like:((Aggitatable) -> Aggitatable)) -> [Aggitatable] {
		for (index, _) in aggitatees.enumerated() {
			aggitatees[index] = like(aggitatees[index])
		}
		return aggitatees
	}
}

class Max : Aggitatable, CustomStringConvertible {
	var state:State
	
	var description:String {
		return self.state.description
	}
	
	required init(_ state:State = State([:])) {
		self.state = state
	}
}

func main() {
	var max = Max()
	let agg = Aggitator(max)
	
	let 😂 = { (aggitatee: Aggitatable) -> Aggitatable in
		if let max = aggitatee as? Max {
			return type(of:max).init(max.state.mutate() { (before) in
				var after = before
				let random = Int(arc4random_uniform(UInt32(Aggitator.attributes.count)))
				if random >= before.count {
					after[Aggitator.attributes[random]] = arc4random_uniform(100) as AnyObject
				} else if random < before.count {
					after[Aggitator.attributes[random]] = nil
				}
				return after
			})
		} else {
			return aggitatee
		}
	}
	
	print(max)
	let 🐸s = agg.aggitate(😂)
	if let 🐸 = 🐸s[0] as? Max {
		max = 🐸
	}
	print(max)
}

main()
