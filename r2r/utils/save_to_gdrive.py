import subprocess
import json
from pathlib import Path
from typing import List, Dict

def save_batch_to_gdrive(
    results: List[Dict],
    batch_idx: int,
    output_dir: str,
    gdrive_folder: str = "R2R_Results",  # Folder name in your Google Drive
    rclone_remote: str = "gdrive"
):
    """
    Save batch results to local file and sync to Google Drive.
    
    Args:
        results: List of result dictionaries from the batch
        batch_idx: Current batch index
        output_dir: Local output directory
        gdrive_folder: Target folder in Google Drive
        rclone_remote: Name of rclone remote (configured in rclone config)
    """
    # Create local file
    local_path = Path(output_dir) / f"batch_{batch_idx:04d}_results.json"
    local_path.parent.mkdir(parents=True, exist_ok=True)

    with open(local_path, 'w') as f:
        json.dump(results, f, indent=2)

    # Upload to Google Drive using rclone
    gdrive_path = f"{rclone_remote}:{gdrive_folder}/{local_path.name}"

    try:
        subprocess.run(
            ["rclone", "copy", str(local_path), f"{rclone_remote}:{gdrive_folder}/"],
            check=True,
            capture_output=True,
            text=True
        )
        print(f"✓ Batch {batch_idx} saved to Google Drive: {gdrive_folder}/{local_path.name}")
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to upload batch {batch_idx}: {e.stderr}")
        
if __name__ == "__main__":
    # Example usage
    sample_results = [
        {"id": 1, "response": "This is a sample response."},
        {"id": 2, "response": "This is another sample response."}
    ]
    save_batch_to_gdrive(
        results=sample_results,
        batch_idx=0,
        output_dir="./output",
        gdrive_folder="rclone_test"
    )