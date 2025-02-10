# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

import logging
from firebase_functions import https_fn
from firebase_admin import initialize_app

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] %(asctime)s - %(message)s'
)
logger = logging.getLogger('aiaio')

initialize_app()

@https_fn.on_request()
def on_request_example(req: https_fn.Request) -> https_fn.Response:
    try:
        logger.info(f"Received request from {req.headers.get('X-Forwarded-For', 'unknown')}")
        
        # Process request here
        response_text = "Hello world!"
        
        logger.info("Request processed successfully")
        return https_fn.Response(response_text)
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return https_fn.Response(
            "Internal server error", 
            status=500
        )