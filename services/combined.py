import os
import io
import re
import requests
import tempfile
import base64
import time
import threading
import queue
import speech_recognition as sr
from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_socketio import SocketIO
from pdf2image import convert_from_bytes
import pytesseract
from PIL import Image
import fitz  # PyMuPDF
from langdetect import detect, LangDetectException
import google.generativeai as genai
from gtts import gTTS

# -------------------- App & SocketIO Initialization --------------------
app = Flask(__name__)
socketio = SocketIO(app)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024 

# -------------------- SOLUTION PROVIDER FUNCTIONS & ROUTES --------------------
# Mistral API Functions for solution provider
MISTRAL_API_KEY = "jDYH4MlYvmp0cI5hwcaue34k2642oKVX"  # Replace with your actual API key
MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions"

def call_mistral_api(prompt, model="mistral-large-latest"):
    """Call the Mistral API with the provided prompt."""
    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
        "max_tokens": 1024
    }
    response = requests.post(MISTRAL_API_URL, headers=headers, json=data)
    response.raise_for_status()
    result = response.json()
    return result['choices'][0]['message']['content']

def extract_text_from_pdf(pdf_bytes):
    """Extract text from a PDF using PyMuPDF."""
    text = ""
    try:
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
        for page_num in range(len(doc)):
            page = doc.load_page(page_num)
            text += page.get_text()
        doc.close()
        return text
    except Exception as e:
        return f"Error extracting text from PDF: {str(e)}"

def extract_text_from_image(image_bytes):
    """Extract text from an image using pytesseract OCR."""
    try:
        image = Image.open(io.BytesIO(image_bytes))
        return pytesseract.image_to_string(image)
    except Exception as e:
        return f"Error extracting text from image: {str(e)}"

def process_pdf_with_ocr(pdf_bytes):
    """If regular text extraction yields limited results, use OCR on PDF images."""
    text = extract_text_from_pdf(pdf_bytes)
    if len(text.strip()) < 100 and not text.startswith("Error"):
        try:
            images = convert_from_bytes(pdf_bytes)
            ocr_text = ""
            for image in images:
                ocr_text += pytesseract.image_to_string(image)
            return ocr_text if ocr_text.strip() else text
        except Exception as e:
            return f"Error processing PDF with OCR: {str(e)}"
    return text

@app.route('/solutionprovider')
def solutionprovider_index():
    """Serve the solution provider HTML page."""
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "solutionprovider.html")

@app.route('/solutionprovider/ask', methods=['POST'])
def solutionprovider_ask():
    """Endpoint for handling queries and document uploads for the solution provider."""
    try:
        query = request.form.get('query', '')
        # Optionally, 'type' can be used for customization
        query_type = request.form.get('type', 'general')
        document_text = None

        # Process file upload if provided
        if 'document' in request.files and request.files['document'].filename != '':
            file = request.files['document']
            if file.content_length and file.content_length > 10 * 1024 * 1024:
                return jsonify({"error": "File too large. Please upload files smaller than 10MB."})
            file_bytes = file.read()
            if not file_bytes:
                return jsonify({"error": "Empty file uploaded."})
            if file.filename.lower().endswith('.pdf'):
                document_text = process_pdf_with_ocr(file_bytes)
            elif file.filename.lower().endswith(('.jpg', '.jpeg', '.png')):
                document_text = extract_text_from_image(file_bytes)
            else:
                return jsonify({"error": "Unsupported file format. Please upload PDF or image files."})
        
        # Build prompt based on document or direct text query
        if document_text:
            summary_prompt = f"Please summarize the following document in clear, concise language:\n\n{document_text}"
            response_text = call_mistral_api(summary_prompt)
        else:
            response_text = call_mistral_api(query)
            
        return jsonify({
            "response": response_text,
            "document_text": document_text  # Useful for debugging or confirmation
        })
    except Exception as e:
        app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": f"An error occurred: {str(e)}"})

# -------------------- Dummy Dataset Function --------------------
def dummy_dataset_usage():
    dataset_file = "chatbot_dataset.csv"
    try:
        with open(dataset_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        count = len(lines) - 1
        print(f"Dataset loaded with {count} conversation pairs from {dataset_file}.")
    except Exception as e:
        print(f"Error loading dataset {dataset_file}: {e}")

# -------------------- LEGAL ASSISTANT SETUP --------------------
LEGAL_API_KEY = "jDYH4MlYvmp0cI5hwcaue34k2642oKVX"
LEGAL_MODEL = "mistral-medium"
LEGAL_ENDPOINT = "https://api.mistral.ai/v1/chat/completions"
legal_token = 0
legal_tts_queue = queue.Queue()

def get_legal_response(user_input, language="en"):
    system_prompt = (
        "You are an AI legal assistant. Provide clear and concise legal information. "
        "Begin by summarizing the legal issue, then outline relevant statutes or guidelines. "
        "Include a disclaimer stating that this is not legal advice and that users should consult a qualified attorney for personalized counsel."
    )
    headers = {
        "Authorization": f"Bearer {LEGAL_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "model": LEGAL_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_input}
        ],
        "max_tokens": 500,
        "temperature": 0.7
    }
    try:
        response = requests.post(LEGAL_ENDPOINT, json=data, headers=headers, timeout=30)
        response.raise_for_status()
        result = response.json()
        return result["choices"][0]["message"]["content"]
    except requests.exceptions.RequestException as e:
        error_message = f"Error: Unable to fetch legal response. {str(e)}"
        if hasattr(e, 'response') and e.response is not None:
            error_message += f"\nResponse details: {e.response.text}"
        print(error_message)
        return error_message

def stream_response_legal(user_input, token, language="en"):
    global legal_token
    if token != legal_token:
        return
    socketio.emit('thinking_status', {'status': True}, namespace='/legal')
    try:
        full_response = get_legal_response(user_input, language)
        sentences = [s.strip() for s in re.split(r'(?<=[.!?]) +', full_response) if s.strip()]
        print(f"[LEGAL] Processing response with {len(sentences)} sentences")
        accumulated_text = ""
        for sentence in sentences:
            if token != legal_token:
                print("[LEGAL] Token changed, stopping response streaming")
                break
            accumulated_text += (" " if accumulated_text else "") + sentence
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': False}, namespace='/legal')
            socketio.sleep(0.3)
        if token == legal_token:
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': True}, namespace='/legal')
            legal_tts_queue.put((token, accumulated_text))
    except Exception as e:
        print(f"[LEGAL] Error in stream_response: {str(e)}")
        socketio.emit('error_message', {'message': f'Error generating legal response: {str(e)}'}, namespace='/legal')
    finally:
        if token == legal_token:
            socketio.emit('thinking_status', {'status': False}, namespace='/legal')

# -------------------- MEDICAL ASSISTANT SETUP --------------------
def get_medical_response(user_input, language="en"):
    system_prompt = (
        "You are an AI medical assistant. Provide your response in clear, short sentences separated by periods. "
        "First tell the user what you're going to explain, then provide the information. "
        "If symptoms are mentioned, suggest possible conditions and first-aid remedies. Recommend only OTC medicines. "
        "If symptoms are severe, suggest consulting a doctor."
    )
    headers = {
        "Authorization": f"Bearer {LEGAL_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "model": LEGAL_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_input}
        ],
        "max_tokens": 150,
        "temperature": 0.7
    }
    try:
        response = requests.post(LEGAL_ENDPOINT, json=data, headers=headers, timeout=30)
        response.raise_for_status()
        result = response.json()
        return result["choices"][0]["message"]["content"]
    except requests.exceptions.RequestException as e:
        error_message = f"Error: Unable to fetch medical response. {str(e)}"
        if hasattr(e, 'response') and e.response is not None:
            error_message += f"\nResponse details: {e.response.text}"
        print(error_message)
        return error_message

medical_token = 0
medical_tts_queue = queue.Queue()

def stream_response_medical(user_input, token, language="en"):
    global medical_token
    if token != medical_token:
        return
    socketio.emit('thinking_status', {'status': True}, namespace='/medical')
    try:
        full_response = get_medical_response(user_input, language)
        sentences = [s.strip() for s in re.split(r'(?<=[.!?]) +', full_response) if s.strip()]
        print(f"[MEDICAL] Processing response with {len(sentences)} sentences")
        accumulated_text = ""
        for sentence in sentences:
            if token != medical_token:
                print("[MEDICAL] Token changed, stopping response streaming")
                break
            accumulated_text += (" " if accumulated_text else "") + sentence
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': False}, namespace='/medical')
            socketio.sleep(0.3)
        if token == medical_token:
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': True}, namespace='/medical')
            medical_tts_queue.put((token, accumulated_text))
    except Exception as e:
        print(f"[MEDICAL] Error in stream_response: {str(e)}")
        socketio.emit('error_message', {'message': f'Error generating medical response: {str(e)}'}, namespace='/medical')
    finally:
        if token == medical_token:
            socketio.emit('thinking_status', {'status': False}, namespace='/medical')

# -------------------- GOVERNMENT ASSISTANT SETUP --------------------
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyAF4hfa-UGF2MzWeYXS1eesyxPqojfkFMs")  # Replace with your actual Gemini API key
GEMINI_MODEL = "gemini-1.5-pro"
genai.configure(api_key=GEMINI_API_KEY)
government_token = 0
government_tts_queue = queue.Queue()

def get_grievance_response(user_input):
    system_prompt = '''You are an empathetic and professional Grievance Filing Assistant. Please guide the user through the grievance filing process based on the following details.'''
    try:
        model = genai.GenerativeModel(GEMINI_MODEL)
        chat = model.start_chat(history=[])
        response = chat.send_message(f"{system_prompt}\n\nUser input: {user_input}")
        return response.text
    except Exception as e:
        print(f"Error with Government Assistant API: {str(e)}")
        return f"Error: Unable to fetch response. {str(e)}"

def stream_response_government(user_input, token):
    global government_token
    if token != government_token:
        return
    socketio.emit('thinking_status', {'status': True}, namespace='/government')
    try:
        full_response = get_grievance_response(user_input)
        sentences = [s.strip() for s in re.split(r'(?<=[.!?]) +', full_response) if s.strip()]
        print(f"[GOVERNMENT] Processing response with {len(sentences)} sentences")
        accumulated_text = ""
        for sentence in sentences:
            if token != government_token:
                print("[GOVERNMENT] Token changed, stopping response streaming")
                break
            accumulated_text += (" " if accumulated_text else "") + sentence
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': False}, namespace='/government')
            socketio.sleep(0.3)
        if token == government_token:
            socketio.emit('response_stream', {'text': accumulated_text, 'is_final': True}, namespace='/government')
            government_tts_queue.put((token, accumulated_text))
    except Exception as e:
        print(f"[GOVERNMENT] Error in stream_response: {str(e)}")
        socketio.emit('error_message', {'message': f'Error generating response: {str(e)}'}, namespace='/government')
    finally:
        if token == government_token:
            socketio.emit('thinking_status', {'status': False}, namespace='/government')

# -------------------- VOICE RECOGNITION FUNCTION --------------------
def recognize_speech(namespace, stream_func):
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("Speak now...")
        audio = r.listen(source)
    try:
        text = r.recognize_google(audio)
        print("You said: " + text)
        socketio.emit('user_message', {'text': text}, namespace=namespace)
        try:
            detected_lang = detect(text)
        except LangDetectException:
            detected_lang = "en"
        if namespace == '/legal':
            global legal_token
            stream_func(text, legal_token, detected_lang)
        elif namespace == '/medical':
            global medical_token
            stream_func(text, medical_token, detected_lang)
        elif namespace == '/government':
            global government_token
            stream_func(text, government_token)
    except sr.UnknownValueError:
        print("Could not understand the audio.")
    except sr.RequestError as e:
        print(f"Could not request results from the speech recognition service; {e}")

# -------------------- TTS PROCESSING FUNCTION --------------------
def process_tts(namespace, tts_queue, get_current_token):
    while True:
        token, text = tts_queue.get()
        current_token = get_current_token()
        if token != current_token:
            continue
        try:
            tts = gTTS(text=text, lang='en')
            temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
            tts.save(temp_file.name)
            temp_file.close()
            with open(temp_file.name, "rb") as f:
                audio_data = f.read()
            audio_base64 = base64.b64encode(audio_data).decode('utf-8')
            socketio.emit('tts_audio', {'audio': audio_base64}, namespace=namespace)
            os.unlink(temp_file.name)
        except Exception as e:
            print(f"Error processing TTS for namespace {namespace}: {str(e)}")

# Start TTS processing threads for each namespace
def get_legal_token():
    return legal_token

def get_medical_token():
    return medical_token

def get_government_token():
    return government_token

legal_tts_thread = threading.Thread(target=process_tts, args=('/legal', legal_tts_queue, get_legal_token))
legal_tts_thread.daemon = True
legal_tts_thread.start()

medical_tts_thread = threading.Thread(target=process_tts, args=('/medical', medical_tts_queue, get_medical_token))
medical_tts_thread.daemon = True
medical_tts_thread.start()

government_tts_thread = threading.Thread(target=process_tts, args=('/government', government_tts_queue, get_government_token))
government_tts_thread.daemon = True
government_tts_thread.start()

# -------------------- COMBINED ASSISTANT ROUTES --------------------
@app.route('/services/legal.html')
def serve_legal():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "legal.html")

@app.route('/services/medical.html')
def serve_medical():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "medical.html")

@app.route('/services/government.html')
def serve_government():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "government.html")

@app.route('/services/emergency.html')
def serve_emergency():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "emergency.html")

@app.route('/')
def index():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    return send_from_directory(base_dir, "index.html")

@app.route('/CitiVoice/services/solutionprovider.html')
def serve_solutionprovider():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    return send_from_directory(current_dir, "solutionprovider.html")


# -------------------- SOCKET.IO LEGAL NAMESPACE --------------------
@socketio.on('send_message', namespace='/legal')
def handle_legal_message(data):
    global legal_token
    user_input = data['message'].strip()
    if not user_input:
        return
    try:
        detected_lang = detect(user_input)
    except LangDetectException:
        detected_lang = "en"
    print(f"[LEGAL] Received new message: '{user_input}'")
    legal_token += 1
    with legal_tts_queue.mutex:
        legal_tts_queue.queue.clear()
    socketio.emit('stop_audio', namespace='/legal')
    thread = threading.Thread(target=stream_response_legal, args=(user_input, legal_token, detected_lang))
    thread.daemon = True
    thread.start()

@socketio.on('start_voice_input', namespace='/legal')
def handle_legal_voice_input():
    thread = threading.Thread(target=recognize_speech, args=('/legal', stream_response_legal))
    thread.daemon = True
    thread.start()

# -------------------- SOCKET.IO MEDICAL NAMESPACE --------------------
@socketio.on('send_message', namespace='/medical')
def handle_medical_message(data):
    global medical_token
    user_input = data['message'].strip()
    if not user_input:
        return
    try:
        detected_lang = detect(user_input)
    except LangDetectException:
        detected_lang = "en"
    print(f"[MEDICAL] Received new message: '{user_input}'")
    medical_token += 1
    with medical_tts_queue.mutex:
        medical_tts_queue.queue.clear()
    socketio.emit('stop_audio', namespace='/medical')
    thread = threading.Thread(target=stream_response_medical, args=(user_input, medical_token, detected_lang))
    thread.daemon = True
    thread.start()

@socketio.on('start_voice_input', namespace='/medical')
def handle_medical_voice_input():
    thread = threading.Thread(target=recognize_speech, args=('/medical', stream_response_medical))
    thread.daemon = True
    thread.start()

# -------------------- SOCKET.IO GOVERNMENT NAMESPACE --------------------
@socketio.on('send_message', namespace='/government')
def handle_government_message(data):
    global government_token
    user_input = data['message'].strip()
    if not user_input:
        return
    try:
        detected_lang = detect(user_input)
    except LangDetectException:
        detected_lang = "en"
    print(f"[GOVERNMENT] Received new message: '{user_input}'")
    government_token += 1
    with government_tts_queue.mutex:
        government_tts_queue.queue.clear()
    socketio.emit('stop_audio', namespace='/government')
    thread = threading.Thread(target=stream_response_government, args=(user_input, government_token))
    thread.daemon = True
    thread.start()

@socketio.on('start_voice_input', namespace='/government')
def handle_government_voice_input():
    thread = threading.Thread(target=recognize_speech, args=('/government', stream_response_government))
    thread.daemon = True
    thread.start()

# -------------------- MAIN ENTRY POINT --------------------
if __name__ == '__main__':
    dummy_dataset_usage()
    print("Starting Combined Assistant Web App...")
    socketio.run(app, debug=True, port=5005)
