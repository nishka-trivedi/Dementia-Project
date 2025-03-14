from PIL import Image
from transformers import pipeline
pipe = pipeline("image-classification", model="Alex14005/model-Dementia-classification-Alejandro-Arroyo")
print(pipe("https://huggingface.co/Alex14005/model-Dementia-classification-Alejandro-Arroyo/resolve/main/No-demented.jpg"))


image=Image.open("/Users/nish/flutter_test/Dementia_App/moderate-demented2.png")
results=pipe(image)
print(results)
scores=[a["score"] for a in results] 
print(scores)
index=scores.index(max(scores))
print(index)
print(scores[index])