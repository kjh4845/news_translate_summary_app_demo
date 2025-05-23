from quart import Quart, request, jsonify
from news import fetch_news
from translate import translate_text
from summarize import summarize
import aiohttp
import asyncio

app = Quart(__name__)

@app.route("/news", methods=["GET"])
async def get_news():
    country = request.args.get("country", "us")
    page = int(request.args.get("page", 1))
    articles = fetch_news(country=country.lower(), page=page)

    async with aiohttp.ClientSession() as session:
        async def process_article(article):
            raw_content = article.get("content") or ""
            if "[+" in raw_content or len(raw_content) < 200:
                raw_content = article.get("description", "") + " " + article.get("title", "")
            if len(raw_content) > 4900:
                raw_content = raw_content[:4900]

            try:
                translated_title, translated_content = await asyncio.gather(
                    translate_text(article["title"], session),
                    translate_text(raw_content, session)
                )
                summary = await summarize(translated_content, session)
                return {
                    "title": translated_title,
                    "url": article["url"],
                    "image": article["image"],
                    "translated": translated_content,
                    "summary": summary
                }
            except Exception as e:
                print(f"[에러] 뉴스 처리 중: {e}")
                return None

        tasks = [process_article(article) for article in articles]
        processed = await asyncio.gather(*tasks)
        results = [r for r in processed if r]

    return jsonify(results)

if __name__ == "__main__":
    app.run()
