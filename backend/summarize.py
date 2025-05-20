from openai import OpenAI
from config import OPENAI_API_KEY

client = OpenAI(api_key=OPENAI_API_KEY)

def summarize(text):
    messages = [
        {"role": "system", "content": "다음 뉴스를 한 문단으로 요약해줘."},
        {"role": "user", "content": text}
    ]
    res = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages
    )
    return res.choices[0].message.content