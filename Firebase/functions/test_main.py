import pytest
from firebase_functions import https_fn
from main import on_request_example

def test_on_request_example_success(mocker):
    """Test successful request handling."""
    # Create a mock request
    mock_request = mocker.Mock(spec=https_fn.Request)
    mock_request.headers = {'X-Forwarded-For': '127.0.0.1'}
    mock_request.method = 'GET'
    mock_request.url = 'http://localhost/test'
    
    # Call the function
    response = on_request_example(mock_request)
    
    # Verify response
    assert response.status_code == 200
    assert response.data.decode() == "Hello world!"

def test_on_request_example_with_error(mocker):
    """Test error handling in the request handler."""
    # Create a mock request that will trigger an error
    mock_request = mocker.Mock(spec=https_fn.Request)
    mock_request.headers = None  # This will cause an attribute error
    
    # Call the function
    response = on_request_example(mock_request)
    
    # Verify error response
    assert response.status_code == 500
    assert response.data.decode() == "Internal server error" 