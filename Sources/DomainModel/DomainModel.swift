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
        guard ["USD", "GBP", "EUR", "CAN"].contains(currency) else {
            fatalError("Unknown currency")
        }
        self.currency = currency
    }
    
    func convert(_ to: String) -> Money {
        guard ["USD", "GBP", "EUR", "CAN"].contains(to) else {
            fatalError("Unknown currency")
        }
        
        var usdAmount = amount
        
        switch currency {
        case "GBP":
            usdAmount = amount * 2
        case "EUR":
            usdAmount = Int(Double(amount) / 1.5)
        case "CAN":
            usdAmount = Int(Double(amount) / 1.25)
        default:
            break
        }
        
        switch to {
        case "GBP":
            return Money(amount: usdAmount / 2, currency: to)
        case "EUR":
            return Money(amount: Int(Double(usdAmount) * 1.5), currency: to)
        case "CAN":
            return Money(amount: Int(Double(usdAmount) * 1.25), currency: to)
        default:
            return Money(amount: usdAmount, currency: to)
        }
    }
    
    func add(_ money: Money) -> Money {
        let convertedMoney = money.convert(currency)
        return Money(amount: self.amount + convertedMoney.amount, currency: currency)
    }
    
    func subtract(_ money: Money) -> Money {
        let convertedMoney = money.convert(currency)
        return Money(amount: self.amount - convertedMoney.amount, currency: currency)
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
    
    // This method assumes the percentage is passed as a decimal (e.g., 0.1 for 10%)
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
    var firstName: String
    var lastName: String
    var age: Int
    var job: Job?
    var spouse: Person?
    
    init(firstName: String, lastName: String, age: Int, job: Job? = nil, spouse: Person? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.job = job
        self.spouse = spouse
    }
    
    func toString() -> String {
        var jobDescription = "nil"
        if let job = self.job {
            switch job.type {
            case .Hourly(let rate):
                jobDescription = "Hourly(\(rate))"
            case .Salary(let salary):
                jobDescription = "Salary(\(salary))"
            }
        }
        
        let spouseDescription = spouse?.firstName ?? "nil"
        return "[Person: firstName: \(firstName) lastName: \(lastName) age: \(age) job: \(jobDescription) spouse: \(spouseDescription)]"
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

