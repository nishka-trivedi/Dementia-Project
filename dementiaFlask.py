from flask import Flask, jsonify, request
from openai import OpenAI
from PIL import Image
import io
import json
from transformers import pipeline

client = OpenAI(api_key="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")

app = Flask(__name__)

MRI_IMAGE_LINKS = {
    "Alzheimer's": "https://drive.google.com/uc?id=1ugITJaeNI5Q7zz25LWes6DhxVkMiAA-v",
    "Vascular Dementia": "https://drive.google.com/uc?id=1VuEWdSXsSO33qikcSrKKN67t30IQZjSu",
    "Lewy Body Dementia": "https://drive.google.com/uc?id=1pPSbxPZ6iTlUD4z3uK4G48fdjT2Ng2an",
    "Frontotemporal Dementia": "https://drive.google.com/uc?id=1x8Q8gteFhOlOYzggS7bBRNlF7zPNc7sv"
}

def analyze_image(image):
    try:
        pipe = pipeline("image-classification", model="Alex14005/model-Dementia-classification-Alejandro-Arroyo")
        results = pipe(image)
        return results
    except Exception as e:
        print(f"Error processing image classification: {e}")
        return None

@app.route("/save_medication_and_symptoms", methods=["POST"])
def save_medication_and_symptoms():
    data = request.json
    return jsonify({"message": "Saved medications, history, and symptoms successfully"}), 200

@app.route("/file_upload", methods=["POST"])
def file_upload():
    file = request.files.get("image")
    if not file:
        return jsonify({"error": "No file provided"}), 400
    try:
        image = Image.open(io.BytesIO(file.read()))
        result = analyze_image(image)
        if not result:
            return jsonify({"error": "Failed to analyze image"}), 500
        scores = [a["score"] for a in result]
        index = scores.index(max(scores))
        response_json = {"message": "Uploaded successfully", "result": result[index]}
        return jsonify(response_json), 200
    except Exception as e:
        return jsonify({"error": "Failed to process image", "details": str(e)}), 500

@app.route("/generate_response", methods=["POST"])
def generate_response():
    try:
        data = request.json
        symptoms = data.get("symptoms", {})
        medications = data.get("medications", {})
        prompt = (
            "You are a medical assistant AI. Based on the following symptoms and medications, "
            "analyze and provide a response as a valid JSON output. "
            "Ensure the output is a valid JSON object with this structure:\n"
            "{\n"
            '  "Prediction analysis": "Provide a brief explanation of the potential condition.",\n'
            '  "Type of dementia": "Specify the most likely type of dementia."\n'
            "}\n\n"
            f"Symptoms: {json.dumps(symptoms)}\n"
            f"Medications: {json.dumps(medications)}"
        )

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are an AI that strictly returns JSON-formatted medical analyses."},
                {"role": "user", "content": prompt}
            ]
        )
        
        raw_response = response.choices[0].message.content
        response_json = json.loads(raw_response.strip())
        dementia_type = response_json.get("Type of dementia", "Unknown")
        mri_link = MRI_IMAGE_LINKS.get(dementia_type, "No MRI image available")
        response_json["image_url"] = mri_link
        return jsonify(response_json), 200
    except Exception as e:
        return jsonify({"Prediction analysis": "Error processing AI response", "Type of dementia": "Unknown", "error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
