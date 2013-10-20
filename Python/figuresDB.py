from google.appengine.ext import db

class FigureDetails(db.Model):
	name = db.StringProperty()
	date = db.StringProperty()
	search_term = db.StringProperty()
	figure = db.BlobProperty()