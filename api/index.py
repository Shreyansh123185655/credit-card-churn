from http.server import BaseHTTPRequestHandler
import json

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        response = {
            "status": "online",
            "project": "Credit Card Customer Churn & Predictive Risk Analytics",
            "author": "Shreyansh Gupta",
            "github": "https://github.com/Shreyansh123185655/credit-card-churn",
            "metrics": {
                "total_customers": 10127,
                "baseline_churn_rate_pct": 16.07,
                "model_accuracy": 0.9487,
                "roc_auc": 0.9834
            }
        }
        self.wfile.write(json.dumps(response, indent=2).encode('utf-8'))
        return
