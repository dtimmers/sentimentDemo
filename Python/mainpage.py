import os
import jinja2
import webapp2

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'])

menu = [ ('Home','/'), ('Sentiment','/sentiment') ]

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
        content += 'So far I have published an app which can be used as a feature selection tool. '
        content += 'I am working on extending this tool and over time will publish more tools. </p>'

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

        content = '<h3> Who gets the blame: Republicans or Democrats?</h3>\n'
        content += '</br>\n'
        content += '<p>During the 2013 shutdown we collected tweets which have either a democratic or republican hashtag during the 2013 shutdown. '
        content += 'Over a period of time we did a simple sentiment analysis of these tweets i.e. we test whether the tweets are positive or negative. '
        content += 'The sentiment scores are graphically displayed in a heatmap of the USA. '
        content += 'Furthermore, every day we also created a word cloud out of these tweets.</p>'

        content += '<h4> Heatmap of the states </h4>\n'

        self.response.write( content )

        self.response.write( "<div class=centered>")

        self.response.write("<img id=heatmap class=centered width=600 src=img/sentiment/sentiment01.png>")

        self.response.write("<img id=repCloud class=left width=290 src=img/sentiment/bigdata01.png>")

        self.response.write("<img id=repCloud class=right width=290 src=img/sentiment/bigdata01.png>")

        self.response.write("</div>")

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

class FeatureSelector(webapp2.RequestHandler):

    def get(self):        
        active = 'Feature Selection'

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'menu': menu, 'active': active}))

        content = '<h3> Feature Selection Tool </h3>'
        content += '<p> The Feature Selection Tool uses linear regression and logistic regression to visualize the most important features. In particular it computes a significance level for each feature. These scores are visualized in a bar chart: the higher the bar the more significant the feature (the levels are plotted on a log-scale). The linear regression and logistic regression scores are combined to get a more powerful prediction.'
        content += "You can <a href='/featureselectorcustom'>upload</a> your own data or find a more <a href='featureselectorexplain'> elaborate explanation </a> about the significance levels.</p>"

        self.response.write( content )

        script = "<script type='text/javascript'>function swapPlot(){var image = document.getElementById('significancePlot');var dropd = document.getElementById('plotSelect');image.src = dropd.value;};</script>"

        self.response.write(script)

        options = []
        options.append({'value':'img/OLS_pvals.png', 'name': 'Linear Score'})
        options.append({'value':'img/Logit_pvals.png', 'name': 'Logistic Score'})
        options.append({'value':'img/Overall_pvals.png','name': 'Combined Score'})

        self.response.write("<a id='plot'></a>")
        select_tmpl = JINJA_ENVIRONMENT.get_template('templates/select.html')
        self.response.write(select_tmpl.render( {'options': options } ))
        self.response.write("<img id=significancePlot class=centered src=img/OLS_pvals.png>")

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())

class FeatureSelectorCustom(webapp2.RequestHandler):

    def get(self):        
        active = 'Feature Selection'

        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'menu': menu, 'active': active}))

        content = '<h3> Feature Selection Tool </h3>'
        content += '<p> The Feature Selection Tool uses linear regression and logistic regression to visualize the most important features. These significance levels can be combined to obtain an Combined Significance score. The significance of each variable is computed and displayed in a chart bar. The taller the bar the more significant the variable. </p>'

        self.response.write( content )

        csv_form_tmpl  = JINJA_ENVIRONMENT.get_template('templates/csv_form.html')
        self.response.write(csv_form_tmpl.render())

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())        

    def post(self):
        active = 'Feature Selection'
        head_tmpl = JINJA_ENVIRONMENT.get_template('templates/header.html')
        self.response.write(head_tmpl.render())

        menu_tmpl = JINJA_ENVIRONMENT.get_template('templates/menu.html')
        self.response.write(menu_tmpl.render({'menu': menu, 'active': active}))

        y = []
        X = []
        try:
            data = self.request.get('csvfile').split('\n')
            for line in data:
                data_entry = line.strip().split(',')
                y.append(data_entry.pop(-1))
                X.append([float(x) for x in data_entry])
        except ValueError as verr:
                float_msg = "Problem occurred while importing the data.\\nNot all data could be converted to floats:\\n    " + str(verr)
                self.response.write('<script type="text/javascript">alert("' + float_msg + '");</script>')
                self.redirect("/featureselectorcustom")
        
        # fs = fsmod.FeatureSelection(X,y)
        # fs.createPlots()
        

        content = '<h3> Feature Selection </h3>'
        self.response.write( content )

        options = []
        options.append({'value':'img/custom_OLS_pvals.png', 'name': 'Linear Score'})
        options.append({'value':'img/custom_Logit_pvals.png', 'name': 'Logistic Score'})
        options.append({'value':'img/custom_Overall_pvals.png','name': 'Combined Score'})

        self.response.write("<a id='plot'></a>")
        select_tmpl = JINJA_ENVIRONMENT.get_template('templates/select.html')
        self.response.write(select_tmpl.render( {'options': options } ))
        self.response.write("<img id=significancePlot class=centered src=img/custom_OLS_pvals.png>")

        end_content_tmpl = JINJA_ENVIRONMENT.get_template('templates/end_content.html')
        self.response.write(end_content_tmpl.render())

        sidebar_tmpl = JINJA_ENVIRONMENT.get_template('templates/sidebar.html')
        self.response.write(sidebar_tmpl.render())

        footer_tmpl = JINJA_ENVIRONMENT.get_template('templates/footer.html')
        self.response.write(footer_tmpl.render())



application = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/sentiment', Sentiment),
], debug=True)