import sys
import os
import jinja2
import webapp2
from re import search as regexp_search

from google.appengine.ext import db
import figuresDB

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'])

class MainPage(webapp2.RequestHandler):

    def get(self):
        active = 'home'

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'active': active}))        

        content = '<h3> Welcome to my Google App Engine website.</h3>\n'
        content += '</br>\n'
        content += 'I have been learning Python and decided to publish some of my apps on the Google App Engine. '
        content += 'The first app is a sentiment app I created using the programming language R. </p>'

        self.response.write( content )

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

class Sentiment(webapp2.RequestHandler):

    def get(self):
        active = 'sentiment'

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'active': active}))


        content = "<p> I wrote a program in R which downloads tweets from Twitter on a given topic (tried 'obamacare' and 'biking' sofar). These tweets are used to do a sentiment analysis on the given topics usig the <a href='http://mpqa.cs.pitt.edu/lexicons/subj_lexicon/' target='_blank'> MPQA Subjectivity Lexicon </a>. The Subjectivity Lexicon is a list of words which are scored between -1 and +1. A score of -1 corresponds to a negative sentiment while +1 corresponds to a positive sentiment. By downloading tweets in every state of the US and using the Subjectivity Lexicon to compute the average score, you get a sentiment score per topic per state. The average scores are mapped into a heatmap of the US.</p>"

        content += '<h4> Heatmap of the states </h4>\n'

        self.response.write( content )

        q_term = db.GqlQuery("SELECT DISTINCT search_term FROM Figure")

        options = []
        for f in q_term:
            options.append({'value': f.search_term.replace(" ","#"), 'name': f.search_term})
        active_topic = options[0]['name']

        select_tmpl = JINJA_ENVIRONMENT.get_template('templates/select_term.html')
        self.response.write(select_tmpl.render({'options': options, 'active': active_topic}))

        # select all sentiment figures from the active topic
        q_sentfigs = db.GqlQuery("SELECT * FROM Figure WHERE search_term = :search_term ORDER BY date", search_term=active_topic)

        
        active_id = q_sentfigs[0].search_term + q_sentfigs[0].date
        
        for f in q_sentfigs:
            fig_id = f.search_term + f.date
            img_tmpl = JINJA_ENVIRONMENT.get_template('templates/sent_img.html')
            self.response.write(img_tmpl.render({'figurekey': f.key(), 'active': active_id, 'id':fig_id}))

        self.response.write("""<div class="buttonWrapper">""")
        for f in q_sentfigs:
            value = f.search_term + f.date
            radio_tmpl = JINJA_ENVIRONMENT.get_template('templates/sent_radio.html')
            self.response.write(radio_tmpl.render({'value': value, 'checked':active_id, 'date':f.date}))
        self.response.write("</div>")

        

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

    def post(self):
        active = 'sentiment'
        active_topic = self.request.get('searchTerm').replace('#', ' ')
        print(active_topic)

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'active': active}))


        content = "<p> I wrote a program in R which downloads tweets from Twitter on a given topic (tried 'obamacare' and 'biking' sofar). These tweets are used to do a sentiment analysis on the given topics usig the <a href='http://mpqa.cs.pitt.edu/lexicons/subj_lexicon/' target='_blank'> MPQA Subjectivity Lexicon </a>. The Subjectivity Lexicon is a list of words which are scored between -1 and +1. A score of -1 corresponds to a negative sentiment while +1 corresponds to a positive sentiment. By downloading tweets in every state of the US and using the Subjectivity Lexicon to compute the average score, you get a sentiment score per topic per state. The average scores are mapped into a heatmap of the US.</p>"

        content += '<h4> Heatmap of the states </h4>\n'

        self.response.write( content )

        q_term = db.GqlQuery("SELECT DISTINCT search_term FROM Figure")

        options = []
        for f in q_term:
            options.append({'value': f.search_term.replace(" ","#"), 'name': f.search_term})

        select_tmpl = JINJA_ENVIRONMENT.get_template('templates/select_term.html')
        self.response.write(select_tmpl.render({'options': options, 'active': active_topic}))

        # select all sentiment figures from the active topic

        q_sentfigs = db.GqlQuery("SELECT * FROM Figure WHERE search_term = :search_term ORDER BY date", search_term=active_topic)

        
        active_id = q_sentfigs[0].search_term + q_sentfigs[0].date
        
        for f in q_sentfigs:
            fig_id = f.search_term + f.date
            img_tmpl = JINJA_ENVIRONMENT.get_template('templates/sent_img.html')
            self.response.write(img_tmpl.render({'figurekey': f.key(), 'active': active_id, 'id':fig_id}))

        self.response.write("""<div class="buttonWrapper">""")
        for f in q_sentfigs:
            value = f.search_term + f.date
            radio_tmpl = JINJA_ENVIRONMENT.get_template('templates/sent_radio.html')
            self.response.write(radio_tmpl.render({'value': value, 'checked':active_id, 'date':f.date}))
        self.response.write("</div>")

        

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

class PostFigures(webapp2.RequestHandler):

    def get(self):
        active = 'postfigures'

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'active': active}))

        figure_form_tmpl = JINJA_ENVIRONMENT.get_template('templates/figure_form.html')
        self.response.write(figure_form_tmpl.render())

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

    def post(self):
        active = 'postfigures'
        file_list = self.request.get('figures')

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'active': active}))

        for file_data in self.request.POST.getall('figures'):
            new_figure = figuresDB.Figure()
        
            plot_type = regexp_search('^\w+(?=-)', file_data.filename).group(0)
            new_figure.plot_type = plot_type
            
            term = regexp_search('(?<=-)(\w\s*)+(?=-)', file_data.filename).group(0)
            new_figure.search_term = term

            # TODO: change this into an honest date instead of text
            day = regexp_search('(?<=-)[0-9]{4}-[0-9]{2}-[0-9]{2}(?=.)', file_data.filename).group(0)
            new_figure.date = day

            new_figure.figure = file_data.value

            #new_figure.put()

            self.response.write("Successfully uploaded " + file_data.filename + "</br>")

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

class GetImage(webapp2.RequestHandler):
    def get(self):
        fig = db.get(self.request.get('entity_id'))
        if fig.figure:
            self.response.headers['Content-Type'] = "image/png"
            self.response.out.write(fig.figure)



application = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/sentiment', Sentiment),
    ('/postfigures', PostFigures),
    ('/img', GetImage)
], debug=True)