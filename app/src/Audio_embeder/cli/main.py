import os
import sys

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)

from tqdm import tqdm
from utils.logging_util import setup_logger
from cli.helpers import display_menu, get_user_choice, get_path_with_default
from cli.config import CONFIG

logger = setup_logger(__name__)

def handle_encode(config, input_file, output_file, secret_audio_file):
    logger.info(f"Encoding using {config['name']}")

    encoded_path = config["encode"](input_file, output_file, secret_audio_file)

    if encoded_path:
        print(f"\nEncoded image saved to: {encoded_path}")
    else:
        print("\nEncoding failed.")


def handle_decode(config, encoded_image_file, output_audio_file):
    logger.info(f"Decoding using {config['name']}")

    decoded_path = config["decode"](encoded_image_file, output_audio_file)

    if decoded_path:
        print(f"\nExtracted audio saved to: {decoded_path}")
    else:
        print("Failed to decode hidden audio.")


def handle_main_choice(choice):
    """Handles the user's main menu choice."""
    logger.info(f"User selected main menu choice: {choice}")

    if choice == 1:
        # ENCODE
        input_file = get_path_with_default(
            CONFIG["default_input_file"],
            "carrier image file"
        )
        secret_audio_file = get_path_with_default(
            CONFIG["default_secret_file"],
            "secret audio file"
        )
        output_file = get_path_with_default(
            CONFIG["default_output_file"],
            "output encoded image file"
        )

        handle_encode(CONFIG, input_file, output_file, secret_audio_file)

    elif choice == 2:
        # DECODE
        encoded_image_file = get_path_with_default(
            CONFIG["default_output_file"],
            "encoded image file"
        )
        output_audio_file = get_path_with_default(
            CONFIG["default_decoded_file"],
            "output extracted audio file"
        )

        handle_decode(CONFIG, encoded_image_file, output_audio_file)

    elif choice == 3:
        logger.info("Exiting the program.")
        sys.exit(0)

    else:
        logger.warning("Invalid choice entered by user.")
        print("\nEnter a valid choice!")


def main():
    """Main function to run the CLI program."""
    while True:
        display_menu(
            ["Encode audio into image", "Decode audio from image", "Exit"],
            "Select an option"
        )
        choice = get_user_choice(3)
        if choice is not None:
            handle_main_choice(choice)


if __name__ == "__main__":
    main()