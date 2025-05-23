import aiohttp
from config import OPENAI_API_KEY

async def summarize(text, session):
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {"role": "system", "content": "다음 뉴스를 한 문단으로 요약해줘."},
            {"role": "user", "content": text}
        ]
    }
    async with session.post(url, json=data, headers=headers) as res:
        res_json = await res.json()
        return res_json["choices"][0]["message"]["content"]
