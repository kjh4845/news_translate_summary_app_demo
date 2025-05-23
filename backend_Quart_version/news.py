import requests
from config import GNEWS_API_KEY

def fetch_news(country="us", page=1):
    url = "https://gnews.io/api/v4/top-headlines"
    params = {
        "country": country,
        "pageSize": 5,
        "page": page,
        "apikey": GNEWS_API_KEY
    }
    response = requests.get(url, params=params)
    return response.json().get("articles", [])
