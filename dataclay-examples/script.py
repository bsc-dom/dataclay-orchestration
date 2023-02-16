import dataclay

client = dataclay.client(username="testuser", password="s3cret", dataset="testuser")
client.start()

from model.family import Dog, Person, Family


person = Person("Marc", 24)
person.make_persistent()
