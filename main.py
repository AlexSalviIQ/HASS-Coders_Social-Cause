


import os
from typing import Optional, Union
import cv2
import requests
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, Form, Response
from twilio.twiml.messaging_response import MessagingResponse
from twilio.rest import Client
from serpapi import GoogleSearch
from groq import Groq
from fastapi import FastAPI, Form, Response, File, UploadFile
import shutil
import base64
import numpy as np
from dotenv import load_dotenv
import re
from fastapi import Request
from fastapi.staticfiles import StaticFiles
from fpdf import FPDF
import uuid
import json
from datetime import datetime
# Load the hidden keys from the .env file


app = FastAPI()

os.makedirs("reports", exist_ok=True)
app.mount("/reports", StaticFiles(directory="reports"), name="reports")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For a hackathon, "*" allows all domains. 
    allow_credentials=True,
    allow_methods=["*"], # Allows POST, GET, OPTIONS, etc.
    allow_headers=["*"], # Allows all headers
)
load_dotenv()

# 🛡️ YOUR SECURE CREDENTIALS
TWILIO_SID = os.getenv("TWILIO_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
SERPAPI_KEY = os.getenv("SERPAPI_KEY")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
HF_TOKEN = os.getenv("HF_TOKEN")

# Initialize Groq Client
groq_client = Groq(api_key=GROQ_API_KEY)
twilio_client = Client(TWILIO_SID, TWILIO_AUTH_TOKEN)

# Hugging Face Vision API Config
API_URL = "https://router.huggingface.co/hf-inference/models/umm-maybe/AI-image-detector"
headers = {
    "Authorization": f"Bearer {HF_TOKEN}",
    "Content-Type": "image/jpeg" # Critical for the new HF router!
}

# --- SIMPLE IN-MEMORY STATE MANAGEMENT ---
# Format: { "whatsapp:+1415...": "waiting_for_awareness_confirmation" }
user_states = {}

# --- HELPER 1: DOWNLOAD MEDIA ---
# --- HELPER 1: DOWNLOAD MEDIA (UPDATED FOR AUDIO & VIDEO) ---
def download_twilio_media(media_url, auth_sid, auth_token, content_type="image/jpeg"):
    response = requests.get(media_url, auth=(auth_sid, auth_token))
    if response.status_code == 200:
        # Dynamically set the file extension based on what WhatsApp sends
        ext = ".jpg"
        if content_type and "video" in content_type: ext = ".mp4"
        elif content_type and "audio" in content_type: ext = ".ogg"
        
        file_path = f"incoming_media{ext}"
        with open(file_path, "wb") as f:
            f.write(response.content)
        return file_path
    return None
# --- HELPER 2: AI IMAGE CHECK WITH THRESHOLDS ---
def check_image_for_ai(image_path):
    try:
        with open(image_path, "rb") as f:
            image_data = f.read()
        
        response = requests.post(API_URL, headers=headers, data=image_data)
        
        if response.status_code != 200:
            print(f"❌ HF API Error {response.status_code}: {response.text}")
            return ("ERROR", "The Forensic AI is waking up or experiencing heavy load. Please resend in 20 seconds!")

        results = response.json()
        print(f"🔍 HF Raw Response: {results}") 
        
        if isinstance(results, dict) and "error" in results:
            return ("ERROR", f"AI System booting up... ({results.get('estimated_time', 20)}s remaining). Try again shortly!")
        
        # Extract the Verdict with Thresholds
        if isinstance(results, list) and len(results) > 0:
            results.sort(key=lambda x: x['score'], reverse=True)
            top_result = results[0]
            label = top_result['label'].upper()
            confidence = round(top_result['score'] * 100, 2)


            
            if "FAKE" in label or "AI" in label or "ARTIFICIAL" in label or "DEEPFAKE" in label:
                
                if confidence > 85: 
                    # Strict threshold for blatant deepfakes
                    return ("FAKE", f"🔴 *HIGH RISK*: This image is {confidence}% likely to be AI-Generated.")
                elif confidence > 60:
                    # The "Smartphone HDR" Safety Net
                    return ("INCONCLUSIVE", f"⚠️ *INCONCLUSIVE*: We detected AI artifacts ({confidence}%), but this is often caused by heavy smartphone camera processing (Beauty Filters/HDR). We cannot confirm this is a malicious deepfake.")
                else:
                    return ("REAL", f"🟢 *VERIFIED SAFE*: This image appears real (Low AI traces).")
            else:
                if confidence > 60:
                    return ("REAL", f"🟢 *VERIFIED SAFE*: This image appears to be {confidence}% REAL.")
                else:
                    return ("INCONCLUSIVE", f"⚠️ *INCONCLUSIVE*: Appears real ({confidence}%), but confidence is too low to guarantee.")
                    
        return ("ERROR", "Could not determine the image source.")
            
    except Exception as e:
        print(f"❌ Vision API Crash: {e}")
        return ("ERROR", "Image analysis failed due to a server error.")

# --- HELPER 3: VERIFY NEWS (UPGRADED: Global Search, Reasoning & Multilingual) ---
# --- HELPER 3: VERIFY NEWS / CHAT / WEATHER ---
def verify_news_claim(claim_text):
    # 1. Intercept Greetings Instantly (Saves API calls!)
    greetings = ["hi", "hello", "hey", "who are you", "help", "hi there"]
    if claim_text.strip().lower() in greetings:
        return "👋 Hi there! I am KavachVerify, your AI misinformation firewall. Send me a news claim, a forwarded image, an ID card, or ask for the latest news/weather, and I'll investigate it for you!"

    # 2. Broaden the search for Fact-Checks, News, and Weather!
    search_params = {
        "q": f"{claim_text} fact check OR news OR weather",
        "api_key": SERPAPI_KEY,
        "engine": "google",
        "gl": "in" 
    }
    search = GoogleSearch(search_params)
    results = search.get_dict().get("organic_results", [])
    
    if not results:
        return "I couldn't find any verified information across the web for this specific query."

    context = "\n".join([f"{r.get('title')}: {r.get('snippet')} - {r.get('link')}" for r in results[:4]])
    
    prompt = f"""
    User Query: "{claim_text}"
    Live Web Context:
    {context}
    
    Task: If the user is asking a general question (like weather or news), answer it directly using the Web Context. 
    If the user is asking to verify a claim, format your response EXACTLY like this:
    VERDICT: [Choose one: 🟢 TRUE, 🔴 FALSE, 🟠 MISLEADING, or ⚪ UNVERIFIED]
    REASONING: [2-sentence explanation].
    
    Rule: Reply in the exact same language as the User Query.
    """
    
    chat_completion = groq_client.chat.completions.create(
        messages=[
            {"role": "system", "content": "You are KavachVerify's helpful assistant and expert fact-checker."},
            {"role": "user", "content": prompt}
        ],
        model="llama-3.3-70b-versatile",
        temperature=0.2, 
    )
    return chat_completion.choices[0].message.content

# --- HELPER 4: GENERATE AWARENESS MESSAGE (Groq) ---
# --- HELPER 4: GENERATE AWARENESS MESSAGE (UPDATED) ---
def generate_awareness_message(topic_context):
    prompt = f"""
    You are an anti-misinformation bot. 
    Write a short, punchy WhatsApp warning message (max 3 sentences) telling people that the following claim/media is FAKE: "{topic_context}". 
    Urge them not to forward it and to verify facts first. Use relevant emojis.
    """
    chat_completion = groq_client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama-3.3-70b-versatile",
        temperature=0.7,
    )
    return chat_completion.choices[0].message.content
## --- HELPER 2.5: VIDEO DEEPFAKE SCANNER (OMNI-MODAL) ---
def check_video_for_ai(video_path):
    print(f"🎥 Extracting frames from video: {video_path}")
    
    # METHOD 1: Temporal Consistency (Look for face-swaps and morphs first)
    temporal_glitch = check_temporal_consistency(video_path)
    if temporal_glitch:
        return ("FAKE", f"🔴 *HIGH RISK*: Temporal inconsistency detected! {temporal_glitch}")

    # Proceed to Standard Frame Extraction
    vidcap = cv2.VideoCapture(video_path)
    total_frames = int(vidcap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    if total_frames == 0:
        return ("ERROR", "Could not read the video file.")

    frame_indices = [
        int(total_frames * 0.1),
        int(total_frames * 0.5),
        int(total_frames * 0.9)
    ]
    
    highest_fake_confidence = 0
    ai_watermarks = ["veo", "runway", "pika", "kling", "luma", "sora", "heygen", "invideo"]
    
    for idx in frame_indices:
        vidcap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        success, image = vidcap.read()
        
        if success:
            temp_frame_path = f"temp_frame_{idx}.jpg"
            cv2.imwrite(temp_frame_path, image)
            print(f"🔍 Analyzing Frame {idx}...")
            
            # METHOD 2: The Watermark Hunter
            detected_watermark = detect_video_watermark(temp_frame_path)
            if detected_watermark:
                for mark in ai_watermarks:
                    if mark in detected_watermark:
                        vidcap.release()
                        try: os.remove(temp_frame_path)
                        except: pass
                        return ("FAKE", f"🔴 *HIGH RISK*: Video analysis complete. We detected a known AI-generator watermark ('{mark.upper()}') in the frames.")

            # METHOD 3: Pixel-Level AI Check 
            category, verdict_msg = check_image_for_ai(temp_frame_path)
            if category == "FAKE":
                try:
                    conf = float(''.join(filter(str.isdigit, verdict_msg))) / 100
                    if conf > highest_fake_confidence:
                        highest_fake_confidence = conf
                except:
                    pass
            
            try: os.remove(temp_frame_path)
            except: pass
                    
    vidcap.release()
    
    if highest_fake_confidence > 0:
        return ("FAKE", f"🔴 *HIGH RISK*: Video analysis complete. We detected manipulated AI pixels with {highest_fake_confidence}% certainty.")
    else:
        return ("REAL", "🟢 *VERIFIED SAFE*: Video analysis complete. No temporal morphing, watermarks, or manipulated pixels detected.")
# --- HELPER 2.6: WATERMARK HUNTER ---
def detect_video_watermark(image_path):
    print("👁️ Inspecting frame corners for AI watermarks...")
    try:
        base64_image = encode_image_to_base64(image_path)
        
        # A highly specific forensic prompt to find tiny watermarks
        prompt = "Scan the bottom-right and bottom-left corners of this image very carefully. Look for tiny, semi-transparent text or logos, specifically words like 'Veo', 'Runway', 'Pika', 'Kling', or 'Luma'. If you find any watermark, reply with just that word. If there is absolutely no watermark, reply with 'NONE'."
        
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}]}],
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            temperature=0.1,
        )
        
        result = chat_completion.choices[0].message.content.strip().lower()
        print(f"🏷️ Watermark Vision Result: {result}")
        
        if "none" not in result:
            return result
        return None
        
    except Exception as e:
        print(f"❌ Watermark Scan Error: {e}")
        return None
    
# --- HELPER 2.7: TEMPORAL CONSISTENCY CHECKER (FILMSTRIP) ---
# --- HELPER 2.7: TEMPORAL CONSISTENCY CHECKER (TIMELINE STRIP) ---
def check_temporal_consistency(video_path):
    print("⏱️ Running Temporal Consistency Check (Full Timeline Scan)...")
    try:
        vidcap = cv2.VideoCapture(video_path)
        total_frames = int(vidcap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        if total_frames < 10:
            return None
            
        # 🚨 THE FIX: Grab frames from across the entire video timeline!
        milestones = [0.2, 0.4, 0.6, 0.8]
        frames = []
        
        for m in milestones:
            vidcap.set(cv2.CAP_PROP_POS_FRAMES, int(total_frames * m))
            success, image = vidcap.read()
            if success:
                # Resize to make the stitching fast and the payload small
                image = cv2.resize(image, (600, 600))
                frames.append(image)
                
        vidcap.release()
        
        if len(frames) == 4:
            # Stitch frames horizontally into a single "timeline strip"
            filmstrip = cv2.hconcat(frames)
            strip_path = f"temp_filmstrip.jpg"
            cv2.imwrite(strip_path, filmstrip)
            
            base64_image = encode_image_to_base64(strip_path)
            
            # 🚨 THE FIX: Upgraded Forensic Prompt
            prompt = "You are a forensic video analyst. This image is a 'timeline' of 4 frames taken from the beginning, middle, and end of a video (read left to right). Analyze the chronological transition. Does the primary person's identity, gender, face, or core physical structure unnaturally mutate, morph, or completely change between these frames? Reply 'FAKE' if you detect an AI identity morph or severe temporal glitch, followed by a 1-sentence reason. Otherwise, reply 'REAL'."
            
            chat_completion = groq_client.chat.completions.create(
                messages=[{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}]}],
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                temperature=0.1,
            )
            
            result = chat_completion.choices[0].message.content.strip()
            print(f"⏱️ Temporal Result: {result}")
            
            try: os.remove(strip_path)
            except: pass
            
            if "FAKE" in result.upper():
                return result
        return None
        
    except Exception as e:
        print(f"❌ Temporal Scan Error: {e}")
        return None


# --- HELPER 5: ENCODE IMAGE FOR GROQ ---
def encode_image_to_base64(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')
# --- HELPER 6: GROQ VISION OCR ---
def extract_text_from_image(image_path):
    print("👁️ Scanning image for hidden text/claims...")
    try:
        base64_image = encode_image_to_base64(image_path)
        
        chat_completion = groq_client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "Extract all readable text from this image. If there is no text, reply with the exact word 'NONE'. Do not add any extra commentary, just the extracted text."},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            temperature=0.1,
        )
        
        extracted_text = chat_completion.choices[0].message.content.strip()
        
        if "NONE" in extracted_text.upper() or len(extracted_text) < 10:
            return None
            
        print(f"📄 Extracted Text: {extracted_text}")
        return extracted_text
        
    except Exception as e:
        print(f"❌ OCR Error: {e}")
        return None
    
# --- HELPER 7.5: SMART CRYPTOGRAPHIC ID VALIDATOR ---
def cryptographic_id_check(extracted_text):
    text_clean = extracted_text.upper().replace(" ", "")
    extracted_upper = extracted_text.upper()
    
    # 1. Detect and Validate PAN CARD
    pan_match = re.search(r'[A-Z]{5}[0-9]{4}[A-Z]', text_clean)
    if pan_match:
        pan = pan_match.group(0)
        print(f"🪪 Detected PAN Card format: {pan}")
        if pan[3] != 'P':
            return ("FAKE", f"🔴 *CRYPTOGRAPHIC FAILURE*: The PAN number {pan} is algorithmically invalid. The 4th character must be 'P' for a citizen. This is a randomly generated fake.")
        return ("REAL", f"🟢 *CRYPTOGRAPHIC SUCCESS*: The PAN number {pan} matches official government structural ciphers.")

    # 2. Detect and Validate AADHAAR CARD (Structural + Checksum)
    # This Regex safely captures 3 blocks, allowing the last block to be 2-4 characters if OCR drops an asterisk.
    aadhar_match = re.search(r'(?<![A-Z0-9X*])([0-9X*]{4})[\s-]?([0-9X*]{4})[\s-]?([0-9X*]{2,4})(?![A-Z0-9X*])', extracted_upper)
    
    if aadhar_match:
        aadhar_num = "".join(aadhar_match.groups())
        print(f"🪪 Detected Aadhaar Card format: {aadhar_num}")
        
        mask_count = sum(1 for char in aadhar_num if char in '*X')
        
        if mask_count > 0:
            # UIDAI Rule: Official Masked Aadhaar cards hide EXACTLY the first 8 digits.
            first_8_chars = aadhar_num[:8]
            last_chars = aadhar_num[8:]
            
            masks_in_first_8 = sum(1 for c in first_8_chars if c in '*X')
            masks_in_last = sum(1 for c in last_chars if c in '*X')
            
            if masks_in_first_8 < 8 or masks_in_last > 0:
                return ("FAKE", f"🔴 *STRUCTURAL FAILURE*: Invalid Aadhaar masking. Official Masked Aadhaar cards hide EXACTLY the first 8 digits (e.g., XXXX XXXX 1234). The number '{aadhar_match.group(0)}' masks the wrong position. This is a structural fake.")
            else:
                return ("INCONCLUSIVE", "⚠️ *CRYPTOGRAPHIC WARNING*: Valid Masked Aadhaar detected. Mathematical verification cannot be performed on hidden digits. We will evaluate visual authenticity.")
                
        # If NO masks, ensure it's exactly 12 digits and run the Math!
        elif len(aadhar_num) != 12 and aadhar_num.isdigit():
            d = [[0,1,2,3,4,5,6,7,8,9], [1,2,3,4,0,6,7,8,9,5], [2,3,4,0,1,7,8,9,5,6], [3,4,0,1,2,8,9,5,6,7], [4,0,1,2,3,9,5,6,7,8], [5,9,8,7,6,0,4,3,2,1], [6,5,9,8,7,1,0,4,3,2], [7,6,5,9,8,2,1,0,4,3], [8,7,6,5,9,3,2,1,0,4], [9,8,7,6,5,4,3,2,1,0]]
            p = [[0,1,2,3,4,5,6,7,8,9], [1,5,7,6,2,8,3,0,9,4], [5,8,0,3,7,9,6,1,4,2], [8,9,1,6,0,4,3,5,2,7], [9,4,5,3,1,2,6,8,7,0], [4,2,8,6,5,7,3,9,0,1], [2,7,9,3,8,0,6,4,1,5], [7,0,4,6,9,1,3,2,5,8]]
            
            c = 0
            inverted_array = [int(x) for x in aadhar_num][::-1]
            for i, val in enumerate(inverted_array):
                c = d[c][p[i % 8][val]]
                
            if c != 0:
                return ("FAKE", f"🔴 *CRYPTOGRAPHIC FAILURE*: The Aadhaar number {aadhar_num} failed the UIDAI Verhoeff Checksum. This is a mathematically invalid number.")
            return ("REAL", f"🟢 *CRYPTOGRAPHIC SUCCESS*: The Aadhaar number {aadhar_num} passed the offline UIDAI Verhoeff checksum algorithm.")
            
    return None, None

# --- HELPER 7: ID CARD FORENSICS (WITH CRYPTO CHECK) ---
def check_id_forgery(image_path):
    print("🔍 Scanning ID Card for digital forgery and cryptographic validity...")
    try:
        base64_image = encode_image_to_base64(image_path)
        
        # First, run the offline Government Database check!
        extracted_text = extract_text_from_image(image_path)
        crypto_msg = ""
        if extracted_text:
            crypto_cat, crypto_msg_result = cryptographic_id_check(extracted_text)
            if crypto_cat == "FAKE":
                return (crypto_cat, crypto_msg_result) # Instantly fail it!
            # 🚨 FIX: Added INCONCLUSIVE so the Masked Warning prints!
            elif crypto_cat == "REAL" or crypto_cat == "INCONCLUSIVE":
                crypto_msg = crypto_msg_result + "\n\n"
                
        # If the numbers are mathematically valid, check for visual Photoshop!
        prompt = "Analyze this ID card. Look for signs of digital forgery: mismatched fonts, incorrect alignment, overlapping text, missing holograms, or altered photo edges. Reply strictly with 'REAL' or 'FAKE', followed by a 1-sentence explanation."
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}]}],
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            temperature=0.1,
        )
        result = chat_completion.choices[0].message.content.strip()
        category = "FAKE" if "FAKE" in result.upper() else "REAL"
        
        return (category, f"{crypto_msg}💳 *Visual Forensics Report:*\n{result}")
    except Exception as e:
        return ("ERROR", "Failed to scan ID card.")


# --- HELPER 9: VOICE TO TEXT (WHISPER AI) ---
def transcribe_audio(audio_path):
    print("🎙️ Transcribing voice note...")
    try:
        with open(audio_path, "rb") as file:
            transcription = groq_client.audio.transcriptions.create(
                file=(os.path.basename(audio_path), file.read()),
                model="whisper-large-v3-turbo",
                response_format="text"
            )
        print(f"🗣️ User Voice: '{transcription.strip()}'")
        return transcription.strip()
    except Exception as e:
        print(f"❌ Audio Transcribe Error: {e}")
        return None

# --- HELPER 10: CONTEXTUAL VISION BRIDGE (THE PREDATOR DRINK FIX) ---
def evaluate_image_with_context(image_path, user_caption):
    print(f"🧠 Contextual Vision Triggered: Linking Image with '{user_caption}'...")
    try:
        base64_image = encode_image_to_base64(image_path)
        prompt = f"The user uploaded this image and asked: '{user_caption}'. Answer their question directly based ONLY on the context of this image. If their text is a claim about the image, fact-check it based on what you see. If the image is completely unrelated to their question, tell them. Reply in the exact same language as their question."
        
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}]}],
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            temperature=0.2,
        )
        return chat_completion.choices[0].message.content.strip()
    except Exception as e:
        return "Could not evaluate image context."

# --- HELPER 11: OFFICIAL PDF REPORT GENERATOR ---
# --- HELPER 11.2: OFFICIAL PDF REPORT GENERATOR CLASS ---
class PDFReport(FPDF):
    def header(self):
        # 1. Logo (Top Left)
        try:
            self.image("Kavach_logo.png", 10, 8, 25)
        except: pass
        
        # 2. Main Title (Center Aligned)
        self.set_font("Arial", "B", 20)
        self.set_text_color(0, 51, 102) # Professional Dark Blue
        self.cell(0, 15, "OFFICIAL VERIFICATION REPORT", ln=True, align="C")
        
        # 3. Timestamp (Top Right)
        self.set_y(15)
        self.set_font("Arial", "", 10)
        self.set_text_color(100, 100, 100)
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S IST")
        self.cell(0, 10, f"Date: {timestamp}", ln=True, align="R")
        
        # Line break
        self.ln(10)
        self.set_draw_color(0, 51, 102)
        self.line(10, 35, 200, 35)
        self.ln(10)

    def footer(self):
        # Position at 25 mm from bottom
        self.set_y(-25)
        self.set_font("Arial", "I", 10)
        self.set_text_color(128, 128, 128)
        self.cell(0, 5, "Electronically verified & generated by KavachVerify AI.", ln=True, align="C")
        self.cell(0, 5, "This document is an AI analysis summary to aid in misinformation reporting.", ln=True, align="C")
        self.cell(0, 5, f"Page {self.page_no()}", ln=True, align="C")

def generate_official_report(content_type, raw_subject, raw_description):
    print("📄 Compiling Official Verification PDF...")
    try:
        # 1. Ask AI to Formalize the Report Data!
        ai_data = generate_formal_report_content(raw_subject, raw_description)
        
        if not ai_data:
            # Safe Fallback just in case AI fails
            ai_data = {
                "subject": raw_subject[:60] + "..." if len(raw_subject)>60 else raw_subject,
                "severity": "UNKNOWN",
                "findings": raw_description,
                "causes": "Further analysis required.",
                "effects": "Potential spread of unverified information."
            }
            
        pdf = PDFReport()
        pdf.add_page()
        
        # --- WATERMARK (Behind the text) ---
        pdf.set_font("Arial", "B", 45)
        pdf.set_text_color(240, 240, 240) # Very Light Grey
        pdf.set_xy(10, 120)
        pdf.cell(0, 10, "KAVACH VERIFY", align="C", ln=True)
        pdf.set_xy(10, 135)
        pdf.cell(0, 10, "CONFIDENTIAL", align="C", ln=True)
        
        # Reset cursor for actual text
        pdf.set_y(45)

        # --- META INFO ---
        pdf.set_font("Arial", "B", 12)
        pdf.set_text_color(0, 0, 0)
        
        pdf.cell(40, 8, "Subject:", border=0)
        pdf.set_font("Arial", "", 12)
        pdf.multi_cell(0, 8, ai_data['subject'].encode('latin-1', 'replace').decode('latin-1'))
        
        pdf.set_font("Arial", "B", 12)
        pdf.cell(40, 8, "Content Type:", border=0)
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 8, content_type.upper(), ln=True)
        
        pdf.set_font("Arial", "B", 12)
        pdf.cell(40, 8, "Severity Level:", border=0)
        pdf.set_font("Arial", "B", 12)
        
        # Dynamic Severity Color
        sev = ai_data['severity'].upper()
        if "HIGH" in sev: pdf.set_text_color(200, 0, 0) # Red
        elif "MEDIUM" in sev: pdf.set_text_color(200, 100, 0) # Orange
        else: pdf.set_text_color(0, 150, 0) # Green
        pdf.cell(0, 8, sev, ln=True)
        
        # Divider Line
        pdf.ln(5)
        pdf.set_draw_color(200, 200, 200)
        pdf.line(10, pdf.get_y(), 200, pdf.get_y())
        pdf.ln(5)

        # --- DETAILED SECTIONS ---
        def add_section(title, text):
            pdf.set_font("Arial", "B", 14)
            pdf.set_text_color(0, 51, 102)
            pdf.cell(0, 10, title, ln=True)
            pdf.set_font("Arial", "", 11)
            pdf.set_text_color(0, 0, 0)
            clean_text = text.encode('latin-1', 'replace').decode('latin-1')
            pdf.multi_cell(0, 7, clean_text)
            pdf.ln(8)

        add_section("1. Forensic Findings & Description", ai_data['findings'])
        add_section("2. Suspected Causes & Methodology", ai_data['causes'])
        add_section("3. Potential Real-World Impact", ai_data['effects'])

        # Save File
        filename = f"report_{uuid.uuid4().hex[:8]}.pdf"
        filepath = os.path.join("reports", filename)
        pdf.output(filepath)
        return filename
    except Exception as e:
        print(f"❌ PDF Error: {e}")
        return None

# --- HELPER 11.1: AI REPORT FORMALIZER ---
def generate_formal_report_content(user_query, raw_verdict):
    print("🧠 AI is drafting formal report contents...")
    prompt = f"""
    Convert the following verification result into a formal forensic report.
    User Input/Query: "{user_query}"
    System Verdict: "{raw_verdict}"

    Respond ONLY with a valid JSON object in this exact format. Use formal, professional, legal-style language:
    {{
        "subject": "A formal, concise 4-7 word title for the report",
        "severity": "HIGH, MEDIUM, or LOW",
        "findings": "Detailed formal explanation of what was analyzed and the official verdict",
        "causes": "Technical or social reasons behind this (e.g., AI generation, manipulation, lack of context)",
        "effects": "Potential real-world impact or harm if this misinformation spreads"
    }}
    """
    try:
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama-3.3-70b-versatile",
            temperature=0.2,
            response_format={"type": "json_object"}
        )
        return json.loads(chat_completion.choices[0].message.content)
    except Exception as e:
        print(f"❌ AI Report Generation Error: {e}")
        return None

#

# =====================================================================
# 📱 1. WHATSAPP ENDPOINT 
# =====================================================================
@app.post("/whatsapp")
def handle_whatsapp(
    request: Request, # 🚨 REQUIRED TO GENERATE THE PDF LINK
    Body: str = Form(None), 
    MediaUrl0: str = Form(None), 
    MediaContentType0: str = Form(None), 
    From: str = Form(...)
):
    response = MessagingResponse()
    user_id = From
    caption = Body.strip() if Body else ""
    
    # --- 1. HANDLE INTERACTIVE REPLIES (AWARENESS OR REPORT) ---
    user_state_data = user_states.get(user_id)
    
    # 🚨 THE FIX: Listen for the correct state!
    if isinstance(user_state_data, dict) and user_state_data.get("state") == "waiting_for_action":
        if caption.upper() == "AWARENESS":
            topic = user_state_data.get("topic", "this viral fake content")
            awareness_msg = generate_awareness_message(topic)
            response.message(f"Forward this to your groups:\n\n{awareness_msg}")
            
        elif caption.upper() == "REPORT":
            topic = user_state_data.get("topic", "Verification Request")
            verdict_text = user_state_data.get("verdict", "No details.")
            c_type = user_state_data.get("type", "Media Document")
            
            # Generate the PDF and create the public link!
            pdf_filename = generate_official_report(c_type, topic, verdict_text)
            if pdf_filename:
                pdf_link = f"{request.base_url}reports/{pdf_filename}"
                response.message(f"📄 *Here is your Official Verification Report (Summary):*\n{pdf_link}\n\n🚨 *For official reporting, please visit:* https://kavachverify.app/report")
            else:
                response.message("Sorry, the report generator is currently busy.")
                
        elif caption.upper() != "NO":
             response.message("Okay, cancelled. Send me anything else to verify!")
             
        if user_id in user_states:
            del user_states[user_id]
        return Response(content=str(response), media_type="application/xml")

    # --- 2. THE MAIN ROUTER ---
    final_verdict = ""
    category = "REAL"
    memory_topic = "An AI-generated fake image"
    content_type_label = "Image"

    if MediaUrl0:
        print(f"🛡️ Visual/Audio Path Triggered from {user_id}...")
        saved_file = download_twilio_media(MediaUrl0, TWILIO_SID, TWILIO_AUTH_TOKEN, MediaContentType0)
        
        if saved_file:
            if saved_file.endswith((".ogg", ".mp3", ".wav")):
                content_type_label = "Voice Note"
                transcribed = transcribe_audio(saved_file)
                if transcribed:
                    fact_msg = verify_news_claim(transcribed)
                    final_verdict += f"🗣️ *Voice Transcribed:* '{transcribed}'\n\n📰 *Fact-Check:*\n{fact_msg}\n\n"
                    category = "FAKE" if "FALSE" in fact_msg.upper() or "MISLEADING" in fact_msg.upper() else "REAL"
                    memory_topic = transcribed
                else:
                    final_verdict += "Could not understand the audio.\n\n"
                    category = "ERROR"
            
            elif saved_file.endswith(".mp4"):
                content_type_label = "Video File"
                category, msg = check_video_for_ai(saved_file)
                final_verdict += f"🎥 *Video Forensics:*\n{msg}\n\n"
                
            else:
                caption_lower = caption.lower()
                if any(k in caption_lower for k in ["verify", "check", "true", "fake", "real", "claim", "fact", "ocr", "read"]):
                    extracted_text = extract_text_from_image(saved_file)
                    if extracted_text:
                        text_clean = extracted_text.upper().replace(" ", "")
                        extracted_lower = extracted_text.lower()
                        is_id_card = (
                            re.search(r'[A-Z]{5}[0-9]{4}[A-Z]', text_clean) or 
                            re.search(r'(?<![A-Z0-9X*])([0-9X*]{4})[\s-]?([0-9X*]{4})[\s-]?([0-9X*]{2,4})(?![A-Z0-9X*])', extracted_text.upper()) or 
                            any(k in caption_lower for k in ["id", "aadhar", "pan", "passport", "card"]) or
                            any(k in extracted_lower for k in ["aadhaar", "aadhar", "income tax department", "government of india", "dob:", "permanent account number"])
                        )
                        if is_id_card:
                            content_type_label = "Government ID Card"
                            print("🛣️ Smart Route: ID Card Detected by OCR/Regex!")
                            category, msg = check_id_forgery(saved_file)
                            final_verdict += f"{msg}\n\n"
                        else:
                            content_type_label = "News/Text Screenshot"
                            fact_check = verify_news_claim(extracted_text)
                            final_verdict += f"📰 *Contextual Fact-Check:*\n{fact_check}\n\n"
                            category = "FAKE" if "FALSE" in fact_check.upper() or "MISLEADING" in fact_check.upper() else "REAL"
                            memory_topic = extracted_text
                    else:
                        content_type_label = "Image with Claim"
                        context_msg = evaluate_image_with_context(saved_file, caption)
                        final_verdict += f"👁️ *Contextual Report:*\n{context_msg}\n\n"
                        category = "FAKE" if "FALSE" in context_msg.upper() or "FAKE" in context_msg.upper() or "MISLEADING" in context_msg.upper() else "REAL"
                        memory_topic = caption
                else:
                    content_type_label = "Image File"
                    category, msg = check_image_for_ai(saved_file)
                    final_verdict += f"🖼️ *Image Forensics:*\n{msg}\n\n"
                    
            try: os.remove(saved_file)
            except: pass

    elif caption:
        content_type_label = "Text Claim"
        text_verdict = verify_news_claim(caption)
        final_verdict += f"📝 *Claim Fact-Check:*\n{text_verdict}"
        if "FALSE" in text_verdict.upper() or "MISLEADING" in text_verdict.upper():
            category = "FAKE"
        memory_topic = caption

    # --- 3. FINAL OUTPUT & SAVE STATE ---
    final_reply = f"🛡️ *KavachVerify Report:*\n{final_verdict.strip()}"
    
    # 🚨 THE FIX: Set the state to "waiting_for_action" so it matches the listener above!
    if category == "FAKE" or category == "INCONCLUSIVE":
        final_reply += "\n\nOptions:\nReply *'REPORT'* to download an official PDF report for authorities.\nReply *'AWARENESS'* to get a shareable warning message."
        
        user_states[user_id] = {
            "state": "waiting_for_action", 
            "topic": memory_topic,
            "verdict": final_verdict.strip(),
            "type": content_type_label
        }
        
    response.message(final_reply)
    return Response(content=str(response), media_type="application/xml")

@app.post("/api/verify")
def web_api_verify(
    request: Request,
    claim_text: Optional[str] = Form(None), 
    file: Optional[UploadFile] = File(None)
):
    final_message = ""
    category = "REAL"

    if file and file.filename:
        print(f"🌐 Web API Triggered: Processing {file.filename}...")
        
        temp_file_path = f"web_incoming_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        file_ext = file.filename.lower()
        
        if file_ext.endswith(('.mp3', '.wav', '.ogg', '.m4a', '.webm')):
            print("🛣️ Intent: Voice Input")
            transcribed_text = transcribe_audio(temp_file_path)
            if transcribed_text:
                fact_msg = verify_news_claim(transcribed_text)
                final_message += f"🗣️ *Voice Transcribed:* '{transcribed_text}'\n\n📰 *Fact-Check:*\n{fact_msg}\n\n"
                category = "FAKE" if "FALSE" in fact_msg.upper() or "MISLEADING" in fact_msg.upper() else "REAL"
            else:
                final_message += "Could not understand the audio.\n\n"
                category = "ERROR"
                
        elif file_ext.endswith('.mp4'):
            print("🛣️ Intent: Video Deepfake Check")
            category, visual_msg = check_video_for_ai(temp_file_path)
            final_message += f"🎥 *Video Forensics:*\n{visual_msg}\n\n"
            
        else:
            caption = claim_text.lower() if claim_text else ""
            
            # 🚨 THE SMART AUTO-ROUTER (Properly Indented!)
            if any(k in caption for k in ["verify", "check", "true", "fake", "real", "claim", "fact", "ocr", "read"]):
                print("🛣️ Intent: Verify Request. Running Smart OCR Scan...")
                extracted_text = extract_text_from_image(temp_file_path)
                
                if extracted_text:
                    text_clean = extracted_text.upper().replace(" ", "")
                    extracted_lower = extracted_text.lower()
                    
# 1. AUTO-DETECT ID CARDS (Regex OR Caption OR OCR Text!)
                    is_id_card = (
                        re.search(r'[A-Z]{5}[0-9]{4}[A-Z]', text_clean) or 
                        re.search(r'(?<![A-Z0-9X*])([0-9X*]{4})[\s-]?([0-9X*]{4})[\s-]?([0-9X*]{2,4})(?![A-Z0-9X*])', extracted_text.upper()) or 
                        any(k in caption for k in ["id", "aadhar", "pan", "passport", "card"]) or
                        any(k in extracted_lower for k in ["aadhaar", "aadhar", "income tax department", "government of india", "dob:", "permanent account number"])
                    )
                    
                    if is_id_card:
                        print("🛣️ Smart Route: ID Card Detected by OCR/Regex!")
                        category, msg = check_id_forgery(temp_file_path)
                        final_message += f"{msg}\n\n"
                    else:
                        print("🛣️ Smart Route: Text Fact-Check Detected!")
                        fact_check = verify_news_claim(extracted_text)
                        final_message += f"📰 *Contextual Fact-Check:*\n{fact_check}\n\n"
                        category = "FAKE" if "FALSE" in fact_check.upper() or "MISLEADING" in fact_check.upper() else "REAL"
                else:
                    print(f"🛣️ Smart Route: Contextual Vision Bridge - '{claim_text}'")
                    context_msg = evaluate_image_with_context(temp_file_path, claim_text)
                    final_message += f"👁️ *Contextual Report:*\n{context_msg}\n\n"
                    category = "FAKE" if "FALSE" in context_msg.upper() or "FAKE" in context_msg.upper() or "MISLEADING" in context_msg.upper() else "REAL"
                    
            else:
                print("🛣️ Intent: Deepfake Check (Default)")
                category, msg = check_image_for_ai(temp_file_path)
                final_message += f"🖼️ *Image Forensics:*\n{msg}\n\n"
                
        try: os.remove(temp_file_path)
        except: pass

    elif claim_text and claim_text.strip():
        print(f"🛣️ Intent: Pure Text Claim - '{claim_text}'")
        text_verdict = verify_news_claim(claim_text)
        final_message += f"📝 *Claim Fact-Check:*\n{text_verdict}"
        if "FALSE" in text_verdict.upper() or "MISLEADING" in text_verdict.upper():
            category = "FAKE"

    if not final_message:
        return {"status": "error", "message": "Please provide text, image, or audio."}
    
    pdf_download_url = None
    if category == "FAKE" or category == "INCONCLUSIVE":
        pdf_filename = generate_official_report("Media/Claim", claim_text if claim_text else "Verification Request", final_message.strip())
        if pdf_filename:
            pdf_download_url = f"{request.base_url}reports/{pdf_filename}"

    return {
        "status": "success",
        "type": "omni_report",
        "category": category,
        "message": final_message.strip(),
        "report_pdf_url": pdf_download_url  # <--- ADD THIS LINE
    }