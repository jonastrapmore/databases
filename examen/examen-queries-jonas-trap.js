use examen
db.createCollection('Docenten')
db.Docenten.insertMany([
  {name: 'Niels Mangelschots', opo: 'IT Challenges', actief: 'true'},
  {name: 'joske Vermeulen', opo: 'Eisenanalyse', actief: 'false'},
])
db.Docenten.updateOne({opo: 'IT Challenges'}, {set: {opo: 'Websites'}})