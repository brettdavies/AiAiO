# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

import logging
from firebase_functions import https_fn
from firebase_admin import initialize_app
import functions_framework
from logger import Logger

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] %(asctime)s - %(message)s'
)
logger = logging.getLogger('aiaio')

initialize_app()

@https_fn.on_request()
def on_request_example(req: https_fn.Request) -> https_fn.Response:
    """Handle HTTP requests to the function.
    
    This is a test function that demonstrates logging and error handling.
    It's used to verify our CI pipeline is working correctly.
    
    Args:
        req: The HTTP request object
        
    Returns:
        https_fn.Response: A simple response with "Hello world!" or error status
    """
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

@functions_framework.http
def example_function(request):
    """Example function demonstrating logger usage"""
    Logger.info("Function invoked", "ExampleFunction")

    try:
        # Example processing
        Logger.debug("Processing request", "ExampleFunction")

        # Example success case
        Logger.info("Request processed successfully", "ExampleFunction")
        return {"success": True}

    except Exception as error:
        # Example error handling
        Logger.error_with_exception(error, "ExampleFunction")
        return {"error": "Internal server error"}, 500