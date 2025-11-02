# ------------------------------------------------------------
# Title : Idea-to-Text Generator using Gemini 2.0 Flash
# Objective : Demonstrate a simple prompt → response workflow
# ------------------------------------------------------------

import google.generativeai as genai

#1. Configure Gemini API key directly (LOCAL DEMO ONLY)
# Replace the placeholder below with your actual key.
API_KEY = "AIzaSyCdvMDha90EvkQuf1ftC_XQLx_Jrnw_EhI"
genai.configure(api_key=API_KEY)

# 2. Create the model instance
model = genai.GenerativeModel("gemini-2.0-flash")

def generate_text(user_input: str) -> str:
    """
    Sends the idea prompt to Gemini and returns the generated response.
    """
    if not user_input:
        return " Please enter a valid idea."

    prompt = f"Generate a creative and simple explanation or expansion for the idea: {user_input}"
    response = model.generate_content(prompt)

    return response.text.strip() if response and response.text else "No response generated."

if __name__ == "__main__":
    print(" Welcome to the Gemini Idea Generator!")
    idea = input("Enter your idea or topic: ").strip()
    print("\n Generating...\n")

    output = generate_text(idea)
    print(output)
