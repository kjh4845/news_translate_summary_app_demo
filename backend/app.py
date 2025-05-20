from flask import Flask, request, jsonify
from flask_cors import CORS
from news import fetch_news
from translate import translate_text
from summarize import summarize

app = Flask(__name__)
CORS(app)

@app.route("/news", methods=["GET"])
def get_news():
    country = request.args.get("country", "us")
    page = int(request.args.get("page", 1))

    articles = fetch_news(country=country.lower(), page=page)
    results = []

    for article in articles:
        raw_content = article.get("content") or ""

        # 내용이 짧거나 잘린 경우 보완
        if "[+" in raw_content or len(raw_content) < 200:
            raw_content = article.get("description", "") + " " + article.get("title", "")

        # Deepl Free 버전 제한 고려
        if len(raw_content) > 4900:
            raw_content = raw_content[:4900]

        try:
            translated_title = translate_text(article["title"])  # 한국어로 번역
            translated_content = translate_text(raw_content)
            summary = summarize(translated_content)

            results.append({
                "title": translated_title,
                "url": article["url"],
                "image": article["image"],
                "translated": translated_content,
                "summary": summary
            })
        except Exception as e:
            print(f"[에러] 뉴스 처리 중 문제 발생: {e}")
            continue

    return jsonify(results)

if __name__ == "__main__":
    app.run(debug=True)
