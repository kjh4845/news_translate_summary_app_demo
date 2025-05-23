import aiohttp
from config import DEEPL_API_KEY

async def translate_text(text, session):
    url = "https://api-free.deepl.com/v2/translate"
    data = {
        "text": text,
        "target_lang": "KO"
    }
    headers = {
        "Authorization": f"DeepL-Auth-Key {DEEPL_API_KEY}"
    }
    async with session.post(url, data=data, headers=headers) as res:
        res_json = await res.json()
        return res_json["translations"][0]["text"]
