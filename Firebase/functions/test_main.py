# test_main.py

import os
import pytest
from unittest.mock import patch, MagicMock
from video_summary.main import process_video_impl

@pytest.fixture
def mock_env():
    os.environ["STORAGE_BUCKET"] = "my-test-bucket"
    os.environ["OPENAI_API_KEY"] = "dummy_key"
    yield
    os.environ.pop("STORAGE_BUCKET", None)
    os.environ.pop("OPENAI_API_KEY", None)

@patch("video_summary.main.firebase_admin.get_app", return_value=MagicMock())
@patch("video_summary.main.firebase_admin.initialize_app")
@patch("video_summary.main.firestore")
@patch("video_summary.main.OpenAI")
def test_process_video_success(mock_openai, mock_firestore, mock_init_app, mock_get_app, mock_env):
    mock_db = MagicMock()
    mock_firestore.client.return_value = mock_db

    mock_openai_instance = MagicMock()
    mock_openai.return_value = mock_openai_instance
    mock_openai_instance.chat.completions.create.return_value = MagicMock(
        choices=[
            MagicMock(
                message=MagicMock(
                    content='{"shortDescription": "Test short", "detailedDescription": "Test detail"}'
                )
            )
        ]
    )

    event_data = {
        "bucket": "my-test-bucket",
        "contentType": "video/quicktime",
        "name": "videos/TEST_ID/original.mov"
    }

    result = process_video_impl(event_data)

    assert "Video processed successfully" in result
    mock_db.collection.assert_called_with("videos")
    mock_openai_instance.chat.completions.create.assert_called_once()
