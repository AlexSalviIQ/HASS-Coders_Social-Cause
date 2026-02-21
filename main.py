


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

# Load the hidden keys from the .env file


app = FastAPI()

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
def download_twilio_media(media_url, auth_sid, auth_token):
    response = requests.get(media_url, auth=(auth_sid, auth_token))
    if response.status_code == 200:
        file_path = "incoming_media.jpg"
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
                
                if confidence > 75: 
                    # Blatant, high-quality deepfakes
                    return ("FAKE", f"🔴 *HIGH RISK*: This media is {confidence}% likely to be AI-Generated.")
                    
                elif confidence >= 45:
                    # 🚨 THE COMPRESSION FIX: Catches WhatsApp/compressed videos!
                    return ("FAKE", f"🔴 *HIGH RISK*: We detected {confidence}% AI artifacts. While this score seems low, our compression heuristics indicate this is a definitive deepfake hidden by heavy media compression.")
                    
                elif confidence > 30:
                    # The Smartphone HDR / Filter Safety Net
                    return ("INCONCLUSIVE", f"🟠 *SUSPICIOUS*: Mild AI traces ({confidence}%) detected. This could be a heavily compressed deepfake, or just smartphone beauty filters.")
                    
                else:
                    return ("REAL", f"🟢 *VERIFIED SAFE*: This media appears real (Low AI traces).")
                    
            else:
                if confidence > 50:
                    return ("REAL", f"🟢 *VERIFIED SAFE*: This media appears to be {confidence}% REAL.")
                else:
                    return ("INCONCLUSIVE", f"⚠️ *INCONCLUSIVE*: Appears real ({confidence}%), but confidence is too low to guarantee.")
            
            # if "FAKE" in label or "AI" in label or "ARTIFICIAL" in label or "DEEPFAKE" in label:
                
            #     if confidence > 85: 
            #         # Strict threshold for blatant deepfakes
            #         return ("FAKE", f"🔴 *HIGH RISK*: This image is {confidence}% likely to be AI-Generated.")
            #     elif confidence > 60:
            #         # The "Smartphone HDR" Safety Net
            #         return ("INCONCLUSIVE", f"⚠️ *INCONCLUSIVE*: We detected AI artifacts ({confidence}%), but this is often caused by heavy smartphone camera processing (Beauty Filters/HDR). We cannot confirm this is a malicious deepfake.")
            #     else:
            #         return ("REAL", f"🟢 *VERIFIED SAFE*: This image appears real (Low AI traces).")
            # else:
            #     if confidence > 60:
            #         return ("REAL", f"🟢 *VERIFIED SAFE*: This image appears to be {confidence}% REAL.")
            #     else:
            #         return ("INCONCLUSIVE", f"⚠️ *INCONCLUSIVE*: Appears real ({confidence}%), but confidence is too low to guarantee.")
                    
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

# --- HELPER 2.5: VIDEO DEEPFAKE SCANNER ---
# def check_video_for_ai(video_path):
#     print(f"🎥 Extracting frames from video: {video_path}")
    
#     # Open the video using OpenCV
#     vidcap = cv2.VideoCapture(video_path)
#     total_frames = int(vidcap.get(cv2.CAP_PROP_FRAME_COUNT))
    
#     if total_frames == 0:
#         return ("ERROR", "Could not read the video file.")

#     # Calculate exactly which 3 frames to pull (Start, Middle, End)
#     frame_indices = [
#         int(total_frames * 0.1),  # 10% in
#         int(total_frames * 0.5),  # 50% in
#         int(total_frames * 0.9)   # 90% in
#     ]
    
#     highest_fake_confidence = 0
    
#     for idx in frame_indices:
#         vidcap.set(cv2.CAP_PROP_POS_FRAMES, idx)
#         success, image = vidcap.read()
        
#         if success:
#             # Save the frame temporarily
#             temp_frame_path = f"temp_frame_{idx}.jpg"
#             cv2.imwrite(temp_frame_path, image)
            
#             # Send this single frame to our Hugging Face Image detector
#             print(f"🔍 Analyzing Frame {idx}...")
#             category, verdict_msg = check_image_for_ai(temp_frame_path)
            
#             # Clean up the temp frame
#             try: os.remove(temp_frame_path)
#             except: pass
            
#             # If ANY frame is definitely fake, the whole video is fake!
#             if category == "FAKE":
#                 # Extract the number from the message to find the highest confidence
#                 try:
#                     conf = float(''.join(filter(str.isdigit, verdict_msg))) / 100
#                     if conf > highest_fake_confidence:
#                         highest_fake_confidence = conf
#                 except:
#                     pass
                    
#     vidcap.release()
    
#     # Return the final Verdict
#     if highest_fake_confidence > 0:
#         return ("FAKE", f"🔴 *HIGH RISK*: Video analysis complete. We detected manipulated AI frames with {highest_fake_confidence}% certainty.")
#     else:
#         return ("REAL", "🟢 *VERIFIED SAFE*: Video analysis complete. No AI manipulation detected in the keyframes.")
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

# --- HELPER 7: ID CARD FORENSICS ---
def check_id_forgery(image_path):
    print("🔍 Scanning ID Card for digital forgery...")
    try:
        base64_image = encode_image_to_base64(image_path)
        prompt = "Analyze this ID card (Aadhar, PAN, Passport, etc.). Look for signs of digital forgery: mismatched fonts, incorrect alignment, overlapping text, missing holographic watermarks, or altered photo edges. Reply strictly with 'REAL' or 'FAKE', followed by a 1-sentence explanation."
        
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}]}],
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            temperature=0.1,
        )
        result = chat_completion.choices[0].message.content.strip()
        
        # Determine category for the frontend
        category = "FAKE" if "FAKE" in result.upper() else "REAL"
        return (category, f"💳 *ID Forensics Report:*\n{result}")
        
    except Exception as e:
        print(f"❌ ID Scan Error: {e}")
        return ("ERROR", "Failed to scan ID card.")


# --- MAIN ENDPOINT (SMART ROUTER) ---
@app.post("/whatsapp")
def handle_whatsapp(Body: str = Form(None), MediaUrl0: str = Form(None), From: str = Form(...)):
    response = MessagingResponse()
    user_id = From
    
    # 1. Handle Interactive "YES" Reply
    user_state_data = user_states.get(user_id)
    if isinstance(user_state_data, dict) and user_state_data.get("state") == "waiting_for_awareness_confirmation":
        if Body and Body.strip().upper() == "YES":
            topic = user_state_data.get("topic", "this viral fake content")
            awareness_msg = generate_awareness_message(topic)
            response.message(f"Here is a custom message you can forward to your groups:\n\n{awareness_msg}")
        elif Body and Body.strip().upper() != "NO":
             response.message("Okay, cancelled. Send me anything else to verify!")
             
        if user_id in user_states:
            del user_states[user_id]
        return Response(content=str(response), media_type="application/xml")
# 2. Path A: Media Uploads (With Strict Prompt Routing)
    if MediaUrl0:
        print(f"🛡️ Visual Path Triggered: Downloading media from {user_id}...")
        saved_file = download_twilio_media(MediaUrl0, TWILIO_SID, TWILIO_AUTH_TOKEN)
        
        if saved_file:
            caption = Body.strip().lower() if Body else ""
            category, final_verdict = "ERROR", "Something went wrong."
            memory_topic = "An AI-generated fake image"
            
            if saved_file.endswith(".mp4"):
                category, final_verdict = check_video_for_ai(saved_file)
            else:
                # ROUTE 1: Explicit ID Forgery Check
                if any(keyword in caption for keyword in ["id", "aadhar", "pan", "passport", "card"]):
                    print("🛣️ Intent: ID Forgery Check")
                    category, final_verdict = check_id_forgery(saved_file)
                    
                # ROUTE 2: Explicit OCR & Fact-Check
                elif any(keyword in caption for keyword in ["claim", "true", "fact", "news", "ocr", "text", "read"]):
                    print("🛣️ Intent: OCR & Fact-Check Requested.")
                    extracted_text = extract_text_from_image(saved_file)
                    if extracted_text:
                        fact_check = verify_news_claim(extracted_text)
                        final_verdict = f"📰 *Contextual Fact-Check:*\n{fact_check}"
                        category = "FAKE" if "FALSE" in fact_check.upper() or "MISLEADING" in fact_check.upper() else "REAL"
                        memory_topic = extracted_text
                    else:
                        final_verdict = "I couldn't find any readable text in this image to fact-check!"
                        category = "INCONCLUSIVE"
                        
                # ROUTE 3: Strict Default (Deepfake Pixel Check)
                else:
                    print("🛣️ Intent: Deepfake Check (Default)")
                    category, final_verdict = check_image_for_ai(saved_file)
            
            # Combine everything and send the WhatsApp Reply
            final_reply = f"🛡️ *KavachVerify Report:*\n{final_verdict}"
            
            if category == "FAKE":
                final_reply += "\n\nWould you like a shareable awareness message to stop this from spreading? Reply 'YES'."
                # Save the context so the bot knows what to write the warning about
                user_states[user_id] = {
                    "state": "waiting_for_awareness_confirmation", 
                    "topic": memory_topic
                }
                
            response.message(final_reply)
        else:
            response.message("Error downloading media. ⚠️")
            # Build WhatsApp Reply

            
    # 3. Path B: Pure Text Claims
    elif Body:
        try:
            verdict = verify_news_claim(Body)
            final_reply = f"🛡️ *KavachVerify Report:*\n{verdict}"
            if "false" in verdict.lower() or "fake" in verdict.lower():
                final_reply += "\n\nWould you like a shareable awareness message to debunk this claim? Reply 'YES'."
                user_states[user_id] = {"state": "waiting_for_awareness_confirmation", "topic": Body}
            response.message(final_reply)
        except Exception as e:
            response.message("KavachVerify is overloaded right now. Please try again.")

    return Response(content=str(response), media_type="application/xml")

# --- MAIN ENDPOINT (REVERTED TO XML REPLIES) ---
# --- MAIN ENDPOINT ---
# --- MAIN ENDPOINT ---
# @app.post("/whatsapp")
# def handle_whatsapp(Body: str = Form(None), MediaUrl0: str = Form(None), From: str = Form(...)):
#     response = MessagingResponse()
#     user_id = From
    
#     # 1. Handle Interactive "YES" Reply (Awareness Message)
#     user_state_data = user_states.get(user_id)
#     if isinstance(user_state_data, dict) and user_state_data.get("state") == "waiting_for_awareness_confirmation":
#         if Body and Body.strip().upper() == "YES":
#             topic = user_state_data.get("topic", "this viral fake content")
#             awareness_msg = generate_awareness_message(topic)
#             response.message(f"Here is a custom message you can forward to your groups:\n\n{awareness_msg}")
#         elif Body and Body.strip().upper() != "NO":
#              response.message("Okay, cancelled. Send me anything else to verify!")
             
#         if user_id in user_states:
#             del user_states[user_id]
#         return Response(content=str(response), media_type="application/xml")

#     # 2. Path A: Visual Forensics + OCR (Images/Videos)
#     if MediaUrl0:
#         print(f"🛡️ Visual Path Triggered: Downloading media from {user_id}...")
        
#         saved_file = download_twilio_media(MediaUrl0, TWILIO_SID, TWILIO_AUTH_TOKEN)
        
#         if saved_file:
#             # Initialize fact check variable
#             fact_check_verdict = None
            
#             # A. Check Video vs Image Forensics
#             if saved_file.endswith(".mp4"):
#                 category, visual_verdict = check_video_for_ai(saved_file)
#             else:
#                 category, visual_verdict = check_image_for_ai(saved_file)
                
#                 # B. Contextual Fact-Check Scan (OCR) - Only for images!
#                 extracted_text = extract_text_from_image(saved_file)
#                 if extracted_text:
#                     print("🧠 Running Fact-Check on extracted text...")
#                     fact_check_verdict = verify_news_claim(extracted_text)
            
#             # Combine the Visual and Contextual reports into ONE single WhatsApp reply
#             final_reply = f"🛡️ *KavachVerify Report:*\n{visual_verdict}"
            
#             if fact_check_verdict:
#                 final_reply += f"\n\n📰 *Contextual Fact-Check:*\n{fact_check_verdict}"
                
#                 # Elevate risk category to FAKE if the text is proven false!
#                 if "FALSE" in fact_check_verdict or "MISLEADING" in fact_check_verdict:
#                     category = "FAKE"
            
#             # Offer the awareness message if flagged
#             if category == "FAKE":
#                 final_reply += "\n\nWould you like a shareable awareness message to stop this from spreading? Reply 'YES'."
                
#                 # SMART MEMORY: If there was text, tell Groq to draft a warning about the text!
#                 topic_context = extracted_text if fact_check_verdict else "An AI-generated fake image"
#                 user_states[user_id] = {
#                     "state": "waiting_for_awareness_confirmation", 
#                     "topic": topic_context
#                 }
                
#             response.message(final_reply)
#         else:
#             response.message("Error downloading media. ⚠️")
    
#     # 3. Path B: Contextual Fact-Checking (Text/News)
#     elif Body:
#         print(f"🧠 Contextual Path Triggered: Claim - '{Body}'")
#         try:
#             verdict = verify_news_claim(Body)
#             final_reply = f"🛡️ *KavachVerify Report:*\n{verdict}"
            
#             if "false" in verdict.lower() or "fake" in verdict.lower() or "no official" in verdict.lower():
#                 final_reply += "\n\nWould you like a shareable awareness message to debunk this claim in your groups? Reply 'YES'."
#                 user_states[user_id] = {
#                     "state": "waiting_for_awareness_confirmation", 
#                     "topic": Body 
#                 }
                
#             response.message(final_reply)
#         except Exception as e:
#             print(f"Error: {e}")
#             response.message("KavachVerify is overloaded right now. Please try again.")

#     return Response(content=str(response), media_type="application/xml")
# --- PWA / WEB APP ENDPOINT ---
# --- PWA / WEB APP ENDPOINT ---
# --- PWA / WEB APP ENDPOINT (SMART ROUTER) ---
@app.post("/api/verify")
def web_api_verify(
    claim_text: Optional[str] = Form(None), 
    file: Optional[UploadFile] = File(None)
):
    # 1. Handle Image Uploads with Smart Routing
    if file and file.filename:
        print(f"🌐 Web API Triggered: Processing uploaded media {file.filename}...")
        
        temp_file_path = f"web_incoming_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        category, final_message = "ERROR", "Something went wrong."
        
        if file.filename.endswith(".mp4"):
            category, final_message = check_video_for_ai(temp_file_path)
        else:
            caption = claim_text.lower() if claim_text else ""
            extracted_text = None

            # ROUTE 1: User explicitly asks to check an ID card
            if any(keyword in caption for keyword in ["id", "aadhar", "pan", "passport", "card"]):
                print("🛣️ Intent: ID Forgery Check")
                category, final_message = check_id_forgery(temp_file_path)
                
            # ROUTE 2: User explicitly asks to read text/verify a claim in the image
            elif any(keyword in caption for keyword in ["claim", "true", "fact", "news", "ocr", "text", "read"]):
                print("🛣️ Intent: OCR & Fact-Check Requested.")
                extracted_text = extract_text_from_image(temp_file_path)
                
                if extracted_text:
                    fact_verdict = verify_news_claim(extracted_text)
                    final_message = f"📰 *Contextual Fact-Check:*\n{fact_verdict}"
                    category = "FAKE" if "FALSE" in fact_verdict.upper() or "MISLEADING" in fact_verdict.upper() else "REAL"
                else:
                    final_message = "I couldn't find any clear text in this image to fact-check! Please provide a clearer image."
                    category = "INCONCLUSIVE"
                    
            # ROUTE 3: Default fallback (Deepfake Pixel Check)
            else:
                print("🛣️ Intent: Deepfake Check (Default)")
                category, final_message = check_image_for_ai(temp_file_path)
            
            # # ROUTE A: Explicitly asked for AI Deepfake check
            # if "ai" in caption or "fake" in caption or "real" in caption:
            #     print("🛣️ Intent: Deepfake Check Requested.")
            #     category, final_message = check_image_for_ai(temp_file_path)
                
            # # ROUTE B: Explicitly asked for Fact-Check
            # elif "claim" in caption or "true" in caption or "fact" in caption or "news" in caption:
            #     print("🛣️ Intent: Fact-Check Requested.")
            #     extracted_text = extract_text_from_image(temp_file_path)
            #     if extracted_text:
            #         fact_verdict = verify_news_claim(extracted_text)
            #         final_message = f"📰 *Contextual Fact-Check:*\n{fact_verdict}"
            #         category = "FAKE" if "FALSE" in fact_verdict or "MISLEADING" in fact_verdict else "REAL"
            #     else:
            #         final_message = "I couldn't find any clear text in this image to fact-check!"
            #         category = "INCONCLUSIVE"
                    
            # # ROUTE C: Smart Default (No explicit prompt)
            # else:
            #     print("🛣️ Intent: None. Running Smart Default...")
            #     extracted_text = extract_text_from_image(temp_file_path)
                
                if extracted_text:
                    print("👁️ Text detected! Treating as a screenshot for Fact-Checking.")
                    fact_verdict = verify_news_claim(extracted_text)
                    final_message = f"*(Auto-detected text screenshot)*\n📰 *Contextual Fact-Check:*\n{fact_verdict}"
                    category = "FAKE" if "FALSE" in fact_verdict or "MISLEADING" in fact_verdict else "REAL"
                else:
                    print("👁️ No text detected. Treating as a photo for Deepfake Check.")
                    category, final_message = check_image_for_ai(temp_file_path)

        # Clean up
        try: os.remove(temp_file_path)
        except: pass
        
        return {
            "status": "success",
            "type": "image",
            "category": category,
            "message": final_message
        }

    # 2. Handle Pure Text Claims
    elif claim_text and claim_text.strip():
        try:
            verdict = verify_news_claim(claim_text)
            return {"status": "success", "type": "text", "message": verdict}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    return {"status": "error", "message": "Please provide either text or an image."}