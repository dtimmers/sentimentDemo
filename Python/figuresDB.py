from google.appengine.ext import db

class FigureDetails(db.Model):
	plot_type = db.StringProperty()
	search_term = db.StringProperty()
	date = db.StringProperty()
	figure = db.BlobProperty()