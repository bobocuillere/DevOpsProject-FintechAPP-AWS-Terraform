from flask import Flask
from extensions import db, login_manager
from models import User
from flask_migrate import Migrate
import os

def create_app():
    app = Flask(__name__)

    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')

    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URI')

    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Initialize Extensions
    db.init_app(app)
    login_manager.init_app(app)

    migrate = Migrate(app, db)

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    with app.app_context():
        db.create_all()

    from views import app as views_blueprint
    app.register_blueprint(views_blueprint)

    return app

if __name__ == '__main__':
    app = create_app()
    #app.run(debug=True) 
    app.run(debug=True, host='0.0.0.0')
