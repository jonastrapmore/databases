// Oefening 1.1.1

db.library.estimatedDocumentCount()

// Oefening 1.1.2

db.library.find({language: 'Spanish'})

// Oefening 1.1.3

db.library.find({author: 'William Faulkner', year: 1929})

// Oefening 1.1.4

db.library.find({}, {author: 1, language: 1, title: 1, _id: 0})

// Oefening 1.1.5

db.library.find({author: 'Unknown'}, {pages: 1, title: 1, year: 1, _id: 0})

// Oefening 1.1.6

db.library.find({language: 'Old Norse'}).count()

// Oefening 1.1.7

db.library.distinct('year')

// Oefening 1.1.8

db.library.find({language: 'French'}, {pages: 1, title: 1, _id: 0}).sort('pages')

// Oefening 1.1.9

db.library.distinct('title', {language: 'French'})

// Oefening 1.1.10

db.library.find({title: 'In Search of Lost Time'}, {author: 1, _id: 0})

// Oefening 1.2.1

db.titanic.find({ticket: 'PC 17612'}, {fare: 1, _id: 0})

// Oefening 1.2.2

db.titanic.distinct('passengerClass')

// Oefening 1.2.3

db.titanic.find({survived: 1}, {name: 1, sex: 1, age: 1, _id: 0})

// Oefening 1.2.4

db.titanic.find({passengerClass: 1, survived: 0, sex: 'female'}, {fare: 1, age: 1, name: 1, _id: 0})

// Oefening 1.2.5

db.titanic.find({embarked: 'S', passengerClass: 3, survived: 1}, {name: 1, age: 1, ticket: 1, fare: 1, _id: 0}).sort({age: -1})

// Oefening 1.2.6

db.titanic.find({fare: 8.05, passengerClass: 3}).count()

// Oefening 1.2.7

db.titanic.find({sex: 'male', survived: 1}, {name: 1, age: 1, fare: 1, _id: 0}).sort({fare: 1, age: 1})

// Oefening 1.2.8

db.titanic.find({cabin: 'B102'})

// Oefening 1.2.9

db.titanic.find({age: 18, sex: 'female', passengerClass: 1}, {name: 1, cabin: 1, _id: 0}).sort({name: 1})

// Oefening 1.2.10

db.titanic.distinct('fare', {sex: 'male', passengerClass: 3, siblingsOrSpouse: 2})

// Oefening 2.1

use school
db.createCollection('students')
db.createCollection('courses')

// Oefening 2.2

db.students.insertOne({firstName: "Sebastiaan", lastName: "Henau", email: "r0636326@student.thomasmore.be", studentNumber: "r0636326"})

// Oefening 2.3

db.courses.insertMany([
    {name: "JavaScript", credits: 6, phase: 1, term:2},
    {name: "Frontend Frameworks", credits: 6, phase: 2, term: 1},
    {name: "Backend Frameworks", credits: 6, phase: 2, term: 1},
    {name: "Mobile Development", credits: 3, phase: 2, term: 1}
])

// Oefening 2.4

db.courses.find({phase: 2}, {name: 1, _id: 0})

// Oefening 2.5

db.courses.updateOne({name: 'JavaScript'}, {$set: {name: 'JS'}})

// Oefening 2.6

db.courses.find({name: 'JS'})

// Oefening 2.7

db.courses.find({phase: 2}, {name: 1, credits: 1, term: 1, _id: 0})

// Oefening 2.8

db.courses.deleteMany({phase: 2})

// Oefening 2.9

db.courses.drop()
db.students.drop()
db.dropDatabase('school')