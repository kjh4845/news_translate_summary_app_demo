import requests
from config import DEEPL_API_KEY

def translate_text(text):
    url = "https://api-free.deepl.com/v2/translate"
    data = {
        "text": text,
        "target_lang": "KO"
    }
    headers = {
        "Authorization": f"DeepL-Auth-Key {DEEPL_API_KEY}"
    }
    res = requests.post(url, data=data, headers=headers)
    return res.json()["translations"][0]["text"]