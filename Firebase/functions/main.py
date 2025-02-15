# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

import os
import logging
from firebase_functions import https_fn, storage_fn
from firebase_admin import initialize_app, credentials
import functions_framework
from logger import Logger
from video_summary.main import process_video  # Import your function

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] %(asctime)s - %(message)s'
)
logger = logging.getLogger('aiaio')

# Initialize Firebase Admin once
cred = credentials.ApplicationDefault()
initialize_app(cred, {
    'storageBucket': os.getenv('FIREBASE_STORAGE_BUCKET')
})

# Export the function with region only
video_summary = storage_fn.on_object_finalized(
    region="us-central1"
)(process_video)
