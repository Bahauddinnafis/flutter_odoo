import json
import requests

class OdooRPC:
    def __init__(self, url, db, username, password):
        self.url = url
        self.db = db
        self.username = username
        self.password = password
        self.session_id = None

    def authenticate(self):
        params = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "service": "common",
                "method": "login",
                "args": [self.db, self.username, self.password]
            }
        }
        response = requests.post(self.url, data=json.dumps(params))
        
        import ipdb;ipdb.set_trace()
        
        data = response.json()
        if 'error' in data:
            raise Exception(data['error'])
        else:
            self.session_id = data['result']
    
    def execute_kw(self, model, method, *args, **kwargs):
        params = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute_kw",
                "args": [self.db, self.session_id, self.password, model, method, args],
                "kwargs": kwargs
            }
        }
        response = requests.post(self.url, data=json.dumps(params))
        data = response.json()
        if 'error' in data:
            raise Exception(data['error'])
        else:
            return data['result']

# Ganti dengan URL Odoo Anda, nama database, serta username dan password
url = "http://localhost:8069"
db = "training"
username = "admin"
password = "mn"

# Membuat objek OdooRPC
odoo = OdooRPC(url, db, username, password)

# Melakukan autentikasi
odoo.authenticate()

# Contoh pemanggilan method execute_kw untuk membaca data dari model 'res.partner'
result = odoo.execute_kw('res.partner', 'search_read', [], {'limit': 5, 'fields': ['name', 'email']})
print(result)
