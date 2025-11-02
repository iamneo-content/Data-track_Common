# ------------------------------------------------------------
# Title : Python Answer Evaluator using Gemini 2.0 Flash
# Objective : Compare student's answer with correct one and display score + feedback
# ------------------------------------------------------------

import google.generativeai as genai
import csv
import random

#  Configure Gemini API key (for local/demo use only)
API_KEY = "AIzaSyCdvMDha90EvkQuf1ftC_XQLx_Jrnw_EhI"   # <-- replace with your actual key
genai.configure(api_key=API_KEY)

#  Create Gemini model
model = genai.GenerativeModel("gemini-2.0-flash")

CSV_FILE = "python_questions.csv"

def load_questions():
    """Load all questions and answers from the CSV file."""
    questions = []
    with open(CSV_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            questions.append(row)
    return questions

def evaluate_answer(reference_answer, student_answer):
    """
    Uses Gemini to compare student's answer with the correct one.
    Returns a dictionary with score and feedback.
    """
    prompt = f"""
    Evaluate the following Python concept answer.

    Correct Answer:
    {reference_answer}

    Student's Answer:
    {student_answer}

    Task:
    - Give a similarity score from 0 to 100.
    - Provide one-line constructive feedback.
    Format exactly as:
    Score: <number>
    Feedback: <short feedback>
    """

    response = model.generate_content(prompt)
    text = response.text.strip() if response and response.text else ""

    score, feedback = "N/A", "No feedback."
    for line in text.split("\n"):
        if line.lower().startswith("score"):
            score = line.split(":")[-1].strip()
        elif line.lower().startswith("feedback"):
            feedback = line.split(":")[-1].strip()

    return {"score": score, "feedback": feedback}


if __name__ == "__main__":
    print(" Python Concept Evaluator (Gemini 2.0 Flash)\n")

    data = load_questions()
    q = random.choice(data)   # pick one random question

    print(f"Question: {q['question']}")
    user_answer = input("\nYour Answer: ").strip()

    print("\n Evaluating your answer...\n")

    result = evaluate_answer(q["answer"], user_answer)

    print(f"Score: {result['score']}")
    print(f"Feedback: {result['feedback']}")
