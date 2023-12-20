import unittest
from app import app, db
from models import User

class UserRegistrationTestCase(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
        db.create_all()

    def tearDown(self):
        db.session.remove()
        db.drop_all()

    def test_user_registration(self):
        response = self.app.post('/register', json={
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass'
        })
        self.assertEqual(response.status_code, 201)

if __name__ == '__main__':
    unittest.main()
