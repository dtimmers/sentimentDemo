from google.appengine.ext import db

class Figure(db.Model):
	plot_type = db.StringProperty()
	search_term = db.StringProperty()
	# TODO: change this into an honest date instead of text
	date = db.StringProperty()
	figure = db.BlobProperty()