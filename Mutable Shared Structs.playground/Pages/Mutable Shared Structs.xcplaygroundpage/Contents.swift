struct Person {
    var first: String
    var last: String
}

let people = [
    Person(first: "Jo", last: "Smith"),
    Person(first: "Joanne", last: "Williams"),
    Person(first: "Annie", last: "Williams"),
    Person(first: "Robert", last: "Jones"),
    ]


final class Var<A> {
    private let _get: () -> A
    private let _set: (A) -> ()
    var value: A {
        get {
            return _get()
        }
        set {
            _set(newValue)
        }
    }
    init(initialValue: A, observe: @escaping (A) -> ()) {
        var value: A = initialValue {
            didSet {
                observe(value)
            }
        }
        _get = { value }
        _set = { newValue in value = newValue }
    }
    
    fileprivate init(get: @escaping () -> A, set: @escaping (A) -> ()) {
        _get = get
        _set = set
    }
    
    subscript<B>(keyPath: WritableKeyPath<A, B>) -> Var<B> {
        return Var<B>(get: {
            self.value[keyPath: keyPath]
        }, set: { newValue in
            self.value[keyPath: keyPath] = newValue
        })
    }
}

extension Var where A: MutableCollection {
    subscript(index: A.Index) -> Var<A.Element> {
        return Var<A.Element>(get: {
            self.value[index]
        }, set: { newValue in
            self.value[index] = newValue
        })
    }
}

final class PersonViewController {
    let person: Var<Person>
    
    init(person: Var<Person>) {
        self.person = person
    }
    
    func update() {
        let independentCopy = person.value
        person.value.last = "changed"
    }
}
let peopleVar: Var<[Person]> = Var(initialValue: people) { newValue in
    dump(newValue)
}

let vc = PersonViewController(person: peopleVar[0])
vc.update()
