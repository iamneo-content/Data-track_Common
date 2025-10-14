# import pandas as pd
# from genai_client import call_gemini_json

# def main():
#     df = pd.read_csv('data/job_logs.csv')
#     failed_jobs = df[df['status'] == 'FAILED']
#     for idx, row in failed_jobs.iterrows():
#         job_name = row['job_name']
#         run_start_utc = row['run_start_utc']
#         run_end_utc = row['run_end_utc']
#         error_message = row['error']
#         affected_tables = row['affected_tables']

#         prompt = (
#             "Write a concise (≤120 words), factual, professional incident summary for the following failed data pipeline job. "
#             "Output ONLY strict JSON with the keys: summary, impact, technical_details, next_steps.\n\n"
#             f"Job name: {job_name}\n"
#             f"Run start time (UTC): {run_start_utc}\n"
#             f"Run end time (UTC): {run_end_utc}\n"
#             f"Error message: {error_message}\n"
#             f"Affected tables: {affected_tables}\n\n"
#             "Constraints:\n"
#             "Keep the writing neutral, factual, and professional.\n"
#             "Do not add any commentary outside the JSON."
#         )

#         row_dict = {
#             "job_name": job_name,
#             "run_start_utc": run_start_utc,
#             "run_end_utc": run_end_utc,
#             "error_message": error_message,
#             "affected_tables": affected_tables
#         }

#         response_json = call_gemini_json(prompt, row_dict, idx)

# if __name__ == "__main__":
#     main()

# import pandas as pd
# from genai_client import call_gemini_json

# def main():
#     df = pd.read_csv('data/job_logs.csv')
#     failed_jobs = df[df['status'] == 'FAILED']
#     for idx, row in failed_jobs.iterrows():
#         job_name = row['job_name']
#         run_start_utc = row['run_start_utc']
#         run_end_utc = row['run_end_utc']
#         error_message = row['error']
#         affected_tables = row['affected_tables']

#         prompt = (
#             "Write a concise (≤120 words), factual, professional incident summary for the following failed data pipeline job. "
#             "Output ONLY strict JSON with the keys: summary, impact, technical_details, next_steps.\n\n"
#             f"Job name: {job_name}\n"
#             f"Run start time (UTC): {run_start_utc}\n"
#             f"Run end time (UTC): {run_end_utc}\n"
#             f"Error message: {error_message}\n"
#             f"Affected tables: {affected_tables}\n\n"
#             "Constraints:\n"
#             "Keep the writing neutral, factual, and professional.\n"
#             "Do not add any commentary outside the JSON."
#         )

#         row_dict = {
#             "job_name": job_name,
#             "run_start_utc": run_start_utc,
#             "run_end_utc": run_end_utc,
#             "error_message": error_message,
#             "affected_tables": affected_tables
#         }

#         response_json = call_gemini_json(prompt, row_dict, idx)

# if __name__ == "__main__":
#     main()

import csv
from genai_client import call_gemini_json


def main():
    """
    Main function to generate incident reports for failed data pipeline jobs.
    
    Process:
    1. Load job logs from CSV
    2. Filter for failed jobs
    3. Construct prompts for each failed job
    4. Invoke Gemini to generate structured incident reports
    """
    
    # Step 1: Load job logs from CSV
    failed_jobs = []
    
    try:
        with open('data/job_logs.csv', 'r', encoding='utf-8') as file:
            csv_reader = csv.DictReader(file)
            
            # Step 2: Filter for failed jobs only
            for row in csv_reader:
                if row.get('status', '').strip().upper() == 'FAILED':
                    failed_jobs.append(row)
    
    except FileNotFoundError:
        return
    except Exception as e:
        return
    
    # Check if there are any failed jobs
    if not failed_jobs:
        return
    
    # Step 3 & 4: Process each failed job
    index = 0
    for job in failed_jobs:
        # Extract job details
        job_name = job.get('job_name', 'Unknown Job')
        run_start_utc = job.get('run_start_utc', 'N/A')
        run_end_utc = job.get('run_end_utc', 'N/A')
        error_message = job.get('error', 'No error message provided')
        affected_tables = job.get('affected_tables', 'N/A')
        
        # Construct the prompt for Gemini
        user_prompt = f"""You are a data engineering incident analyst. Generate a Write a concise (≤120 words) incident report for a failed data pipeline job.

Job Context:
- Job Name: {job_name}
- Run Start Time (UTC): {run_start_utc}
- Run End Time (UTC): {run_end_utc}
- Error Message: {error_message}
- Affected Tables: {affected_tables}

Instructions:
- Write a factual, neutral incident report in plain language
- Keep the summary to 120 words or less
- Use a professional and concise tone
- Avoid blame or subjective commentary
- Output ONLY valid JSON with these exact keys: summary, impact, technical_details, next_steps
- Do not include any text outside the JSON structure
- Do not add any commentary outside the JSON.

Generate the incident report now."""

        # Prepare row context for the function
        row_context = {
            'job_name': job_name,
            'run_start_utc': run_start_utc,
            'run_end_utc': run_end_utc,
            'affected_tables': affected_tables
        }
        
        # Step 4: Invoke Gemini API
        call_gemini_json(user_prompt, row_context, index)
        
        index += 1


if __name__ == "__main__":
    main()