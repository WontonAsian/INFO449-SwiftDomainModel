import Foundation

struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//

public struct Money {
    var amount: Int
    var currency: String
    
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    func convert(_ to: String) -> Money {
        var convertedAmount = Double(amount)
        
        let conversionRates: [String: Double] = [
            "USD": 1.0,
            "GBP": 0.5,
            "EUR": 1.5,
            "CAN": 1.25
        ]
        
        if let rate = conversionRates[currency], rate != 1.0 {
            convertedAmount /= rate
        }
        
        if let rate = conversionRates[to], rate != 1.0 {
            convertedAmount *= rate
        }
        
        return Money(amount: Int(convertedAmount.rounded()), currency: to)
    }

    func add(_ other: Money) -> Money {
        let convertedSelf = convert(other.currency)
        return Money(amount: convertedSelf.amount + other.amount, currency: other.currency)
    }
    
    func subtract(_ other: Money) -> Money {
        let convertedSelf = convert(other.currency)
        return Money(amount: convertedSelf.amount - other.amount, currency: other.currency)
    }
}




////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    var title: String
    var type: JobType
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hours: Int = 2000) -> Int {
        switch type {
        case .Hourly(let hourlyRate):
            return Int(hourlyRate * Double(hours))
        case .Salary(let yearlySalary):
            return Int(yearlySalary)
        }
    }
    
    func raise(byAmount amount: Double) {
        switch type {
        case .Hourly(let rate):
            type = .Hourly(rate + amount)
        case .Salary(let salary):
            type = .Salary(UInt(Double(salary) + amount))
        }
    }
    
    func raise(byPercent percentage: Double) {
        switch type {
        case .Hourly(let rate):
            type = .Hourly(rate * (1.0 + percentage))
        case .Salary(let salary):
            type = .Salary(UInt(Double(salary) * (1.0 + percentage)))
        }
    }
}


////////////////////////////////////
// Person
//
public class Person {
    var firstName: String?
    var lastName: String?
    var age: Int
    var job: Job? {
        didSet {
            if age < 16 {
                print("Person is too young to have a job.")
                job = nil
            }
        }
    }
    var spouse: Person? {
        didSet {
            if age < 18 {
                print("Person is too young to have a spouse.")
                spouse = nil
            }
        }
    }
    
    init(firstName: String? = nil, lastName: String? = nil, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    func toString() -> String {
        var description = "[Person: "
        if let fName = firstName {
            description += "firstName:\(fName) "
        }
        if let lName = lastName {
            description += "lastName:\(lName) "
        }
        description += "age:\(age) "
        let jobDescription = job?.title ?? "nil"
        let spouseName = spouse?.firstName ?? "nil"
        description += "job:\(jobDescription) spouse:\(spouseName)]"
        return description
    }

}



////////////////////////////////////
// Family
//
public class Family {
    private var members: [Person]

    public init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil, spouse2.spouse == nil else {
            fatalError("Both spouses must not already be married.")
        }
        
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        members = [spouse1, spouse2]
    }

    public func haveChild(_ child: Person) -> Bool {
        if members.contains(where: { $0.age > 21 }) {
            members.append(child)
            return true
        } else {
            return false
        }
    }

    public func householdIncome() -> Int {
        members.reduce(0) { $0 + ($1.job?.calculateIncome() ?? 0) }
    }
}


// Convert hourly to Salary

extension Job {
    func convertToSalary() {
        switch type {
        case .Hourly(let rate):
            let salaryEquivalent = Int(ceil(rate * 2000 / 1000) * 1000)
            type = .Salary(UInt(salaryEquivalent))
        case .Salary:
            print("Job is already a salary position.")
        }
    }
}



