import pandas as pd
from genai_client import interactive_loop


def main():
    df = pd.read_csv("data/viewership.csv")

    if "date" in df.columns:
        df["date"] = pd.to_datetime(df["date"], errors="ignore")

    if "region" in df.columns:
        df["region"] = (
            df["region"]
            .astype(str)
            .str.strip()
            .str.upper()
            .replace("", pd.NA)
        )

    analyst_prompt = (
        "You are a Data Analyst.\n"
        "You are given a pandas DataFrame named df with columns:\n"
        "- date (datetime), region (string), total_watch_hours (float), unique_users (int), new_subscribers (int)\n\n"
        "Your job: Convert each natural-language question about the dataset into valid pandas code ONLY.\n"
        "Rules:\n"
        "- Output only Python code (no comments, markdown, or explanations).\n"
        "- Do not modify df in place; create new variables as needed.\n"
        "- The final DataFrame variable must be named result.\n"
        "- Use clear, readable pandas logic (boolean masks, groupby, reset_index, etc.).\n"
    )

    strategist_prompt = (
        "You are a Business Strategist.\n"
        "You are given a dataset representing daily streaming metrics with columns:\n"
        "- date (datetime), region (string), total_watch_hours (float), unique_users (int), new_subscribers (int)\n\n"
        "Your job: Answer the user's question with a short, plain-English business summary.\n"
        "Rules:\n"
        "- Keep the explanation concise (~100 words), clear, and beginner-friendly.\n"
        "- Mention only the most relevant metrics and obvious trends.\n"
        "- Suggest 1-2 simple next actions. No code, no formulas.\n"
    )
    interactive_loop(df, analyst_prompt, strategist_prompt)


if __name__ == "__main__":
    main()
