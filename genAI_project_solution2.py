# ------------------------------------------------------------
# Title : SQL/DB Question & Answer Split (Gemini 2.0 Flash)
# Objective : Display questions on console, save only answers to file
# ------------------------------------------------------------

import google.generativeai as genai
import json

API_KEY = "AIzaSyCdvMDha90EvkQuf1ftC_XQLx_Jrnw_EhI"
genai.configure(api_key=API_KEY)

model = genai.GenerativeModel("gemini-2.0-flash")

def generate_qa(topic: str):
    """
    Generates 3 beginner-level quiz questions with answers for the given SQL topic.
    Returns questions (list) and answers (list) separately.
    """
    prompt = f"""
    Create 3 beginner-level quiz questions **with answers** for the SQL topic '{topic}'.
    Each question and answer should be concise and conceptual.
    Format clearly as:
    Q1: <question>
    A1: <answer>
    Q2: <question>
    A2: <answer>
    Q3: <question>
    A3: <answer>
    """

    response = model.generate_content(prompt)
    text = response.text.strip() if response and response.text else ""
    if not text:
        return [], []

    questions, answers = [], []
    for line in text.split("\n"):
        line = line.strip()
        if line.lower().startswith("q"):
            questions.append(line)
        elif line.lower().startswith("a"):
            answers.append(line)

    return questions, answers


if __name__ == "__main__":
    print(" SQL/DB Question Generator \n")

    topic = input("Enter one SQL topic: ").strip()
    if not topic:
        print(" Please enter a valid topic.")
        exit()

    print(f"\n Topic: {topic}\n")

    questions, answers = generate_qa(topic)

    if questions:
        print("Here are your 3 questions:\n")
        for q in questions:
            print(q)
    else:
        print("No questions generated.")

    print("\nAnswers are being saved...")

    answers_data = {"topic": topic, "answers": answers}

    with open("sql_answers.json", "w", encoding="utf-8") as f:
        json.dump(answers_data, f, ensure_ascii=False, indent=4)

    print(" Only answers saved to sql_answers.json (refreshes each run)")
