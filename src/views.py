from flask import Blueprint, request, jsonify, render_template, redirect, url_for, after_this_request
from flask_login import login_user, logout_user, current_user, login_required
from extensions import db
from models import User, Account, Transaction 
from werkzeug.security import check_password_hash
from prometheus_client import generate_latest, Counter, REGISTRY
from flask import Response

app = Blueprint('app', __name__)

# Define counters for both successful and failed transactions
transactions_success_total = Counter('transactions_success_total', 'Total number of successful transactions')
transactions_failed_total = Counter('transactions_failed_total', 'Total number of failed transactions')

# counter to track the number of visits to the homepage
home_visits_counter = Counter('home_visits', 'Number of visits to the home page') 


@app.route('/')
def home():
    home_visits_counter.inc()  # Increment the counter
    return render_template('home.html')

@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype="text/plain")

# Define a Prometheus counter for 401 errors
http_401_errors_total = Counter('http_401_errors_total', 'Total number of HTTP 401 Unauthorized errors')

@app.after_request
def count_401_errors(response):
    if response.status_code == 401:
        http_401_errors_total.inc()  # Increment the counter for 401 errors
    return response

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # User information
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        # Account information
        account_name = request.form.get('account_name')
        account_type = request.form.get('account_type')

        if not all([username, email, password, account_name, account_type]):
            return jsonify({'message': 'Missing data'}), 400

        new_user = User(username=username, email=email)
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.flush()  # Flush to assign an ID to new_user

        new_account = Account(user_id=new_user.id, account_name=account_name, account_type=account_type)
        db.session.add(new_account)
        db.session.commit()

        return redirect(url_for('app.login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        user = User.query.filter_by(username=username).first()

        if user and user.verify_password(password):
            login_user(user)
            return redirect(url_for('app.home'))
        else:
            return jsonify({'message': 'Invalid username or password'}), 401

    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('app.home'))
@app.route('/accounts', methods=['GET'])
@login_required
def view_accounts():
    # Refetch the accounts to get the updated balances
    accounts = Account.query.filter_by(user_id=current_user.id).all()
    return render_template('accounts.html', accounts=accounts)

@app.route('/account/<int:account_id>')
@login_required
def account_detail(account_id):
    # Refetch the account to get the updated balance
    account = Account.query.filter_by(id=account_id, user_id=current_user.id).first()
    if account:
        return render_template('account_detail.html', account=account)
    else:
        return "Account not found", 404

def commit_and_refresh_account(account):
    db.session.commit()
    db.session.refresh(account)

@app.route('/account/<int:account_id>/transaction', methods=['POST'])
@login_required
def create_transaction(account_id):
    account = Account.query.get(account_id)
    if not account or account.user_id != current_user.id:
        return "Account not found", 404

    transaction_type = request.form.get('type')
    amount = float(request.form.get('amount'))

    if not all([transaction_type, amount]):
        return jsonify({'message': 'Missing data'}), 400

    if transaction_type == 'deposit':
        account.balance += amount
    elif transaction_type == 'withdrawal':
        if account.balance >= amount:
            account.balance -= amount
        else:
            return jsonify({'message': 'Insufficient funds'}), 400

    new_transaction = Transaction(account_id=account_id, type=transaction_type, amount=amount)
    db.session.add(new_transaction)
    db.session.commit()  # Ensure the changes are committed

    return redirect(url_for('app.account_detail', account_id=account_id))


@app.route('/account/<int:account_id>/transactions')
@login_required
def view_transactions(account_id):
    account = Account.query.get(account_id)
    if not account or account.user_id != current_user.id:
        return "Account not found", 404

    transactions = Transaction.query.filter_by(account_id=account_id).all()
    return render_template('transactions.html', transactions=transactions)

@app.route('/transactions')
@login_required
def view_all_transactions():
    accounts = Account.query.filter_by(user_id=current_user.id).all()
    account_ids = [account.id for account in accounts]
    transactions = Transaction.query.filter(Transaction.account_id.in_(account_ids)).all()
    return render_template('transactions.html', transactions=transactions)

@app.route('/add_transaction', methods=['GET'])
@login_required
def add_transaction_form():
    accounts = Account.query.filter_by(user_id=current_user.id).all()
    return render_template('add_transaction.html', accounts=accounts)

@app.route('/add_transaction', methods=['POST'])
@login_required
def add_transaction():
    account_id = request.form.get('account_id')
    transaction_type = request.form.get('type')
    amount = request.form.get('amount')

    if not all([account_id, transaction_type, amount]):
        transactions_failed_total.inc()  # Increment failed transactions counter here
        return jsonify({'message': 'Missing data'}), 400

    amount = float(amount)  # Convert amount to float after validation
    account = Account.query.get(account_id)

    if not account or account.user_id != current_user.id:
        transactions_failed_total.inc()  # Increment failed transactions counter here
        return "Account not found", 404

    # Handle transaction logic
    if transaction_type == 'deposit':
        account.balance += amount
    elif transaction_type == 'withdrawal':
        if account.balance >= amount:
            account.balance -= amount
        else:
            transactions_failed_total.inc()  # Increment failed transactions counter here
            return jsonify({'message': 'Insufficient funds'}), 400

    # Transaction is successful if none of the above conditions are met
    transactions_success_total.inc()  # Increment success transactions counter here

    # Create and commit transaction
    new_transaction = Transaction(account_id=account_id, type=transaction_type, amount=amount)
    db.session.add(new_transaction)
    db.session.commit()

    return redirect(url_for('app.view_all_transactions'))

# @app.route('/add_transaction', methods=['POST'])
# @login_required
# def add_transaction():
#     account_id = request.form.get('account_id')
#     transaction_type = request.form.get('type')
#     amount = float(request.form.get('amount'))  # Convert amount to float

#     if not all([account_id, transaction_type, amount]):
#         return jsonify({'message': 'Missing data'}), 400

#     account = Account.query.get(account_id)

#     # Update account balance
#     if transaction_type == 'deposit':
#         account.balance += amount
#     elif transaction_type == 'withdrawal':
#         if account.balance >= amount:
#             account.balance -= amount
#         else:
#             return jsonify({'message': 'Insufficient funds'}), 400

#     @after_this_request
#     def count_transaction(response):
#         # Increment the appropriate counter based on the response status code
#         if response.status_code == 302:
#             transactions_success_total.inc()
#         else:
#             transactions_failed_total.inc()
#         return response
    
#     # Create and commit transaction
#     new_transaction = Transaction(account_id=account_id, type=transaction_type, amount=amount)
#     db.session.add(new_transaction)
#     db.session.commit()

#     return redirect(url_for('app.view_all_transactions'))

# @app.route('/analytics')
# def analytics():
#     return "Analytics Page - Under Construction"
