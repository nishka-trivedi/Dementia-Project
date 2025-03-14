from openai import OpenAI
client = OpenAI(api_key="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")

completion = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {
            "role": "user",
            "content": "What is dementia?"
        }
        
    ]
)

print(completion.choices[0].message.content)


