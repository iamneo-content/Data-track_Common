import pandas as pd
from genai_client import interactive_loop

def main():
    df = pd.read_csv("data/orders.csv")
    df['order_date'] = pd.to_datetime(df['order_date'])
    df['region'] = (
        df['region']
        .astype(str)
        .str.strip()
        .str.upper()
        .replace("", pd.NA)
    )

    few_shot_examples = [
        {
            "question": "Total order amount yesterday across all regions.",
            "code": (
                "mask = (df['order_date'] == pd.Timestamp.today().normalize() - pd.Timedelta(days=1))\n"
                "val = df.loc[mask, 'amount'].sum()\n"
                "result = pd.DataFrame({'total_amount': [val]})"
            ),
        },
        {
            "question": "Count of orders for APAC on 2025-09-27.",
            "code": (
                "mask = (df['region'] == 'APAC') & (df['order_date'] == '2025-09-27')\n"
                "val = df.loc[mask, 'order_id'].count()\n"
                "result = pd.DataFrame({'order_count': [val]})"
            ),
        },
        {
            "question": "Total number of orders per region this month.",
            "code": (
                "month = pd.Timestamp.today().month\n"
                "mask = df['order_date'].dt.month == month\n"
                "val = df.loc[mask].groupby('region')['order_id'].count().reset_index()\n"
                "result = val.rename(columns={'order_id': 'order_count'})"
            ),
        },
    ]

    prompt_lines = [
        "You are a pandas expert. Convert every natural-language question to valid pandas code only. No comments, no markdown, no explanations.",
        "Assign the final output to a DataFrame named result.",
        "",
    ]
    for shot in few_shot_examples:
        prompt_lines.append(f"Question:\n{shot['question']}")
        prompt_lines.append(f"Expected Pandas Code:\n{shot['code']}\n")
    base_prompt = "\n".join(prompt_lines)

    interactive_loop(df, base_prompt)

if __name__ == "__main__":
    main()