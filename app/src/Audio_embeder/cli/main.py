import os
import sys
from tqdm import tqdm

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)

from utils.logging_util import setup_logger
from cli.helpers import display_menu, get_user_choice, get_path_with_default, display_algorithm_menu
from cli.config import ALGORITHMS

logger = setup_logger(__name__)


def handle_algorithm_choice(encode=True):
    """Handles the user's choice of algorithm for encoding or decoding."""
    display_algorithm_menu()

    algo_choice = get_user_choice(len(ALGORITHMS))
    if algo_choice is None or algo_choice not in ALGORITHMS:
        logger.warning("Invalid algorithm choice.")
        print("\nInvalid algorithm choice!")
        return

    algorithm = ALGORITHMS[algo_choice]

    if encode:
        input_file = get_path_with_default(
            algorithm["default_input_file"],
            "carrier image file"
        )
        secret_audio_file = get_path_with_default(
            algorithm["default_secret_file"],
            "secret audio file"
        )
        output_file = get_path_with_default(
            algorithm["default_output_file"],
            "output encoded image file"
        )
        handle_encode(algorithm, input_file, output_file, secret_audio_file)
    else:
        encoded_image_file = get_path_with_default(
            algorithm["default_output_file"],
            "encoded image file"
        )
        output_audio_file = get_path_with_default(
            algorithm["default_decoded_file"],
            "output extracted audio file"
        )
        handle_decode(algorithm, encoded_image_file, output_audio_file)


def handle_encode(algorithm, input_file, output_file, secret_audio_file):
    """Encodes an audio file into an image using the chosen algorithm."""
    logger.info(
        f"Encoding using {algorithm['name']}. Output file will be: {output_file}"
    )

    for _ in tqdm(range(1), desc="Encoding Progress"):
        algorithm["encode"](input_file, output_file, secret_audio_file)

    print(f"\nEncoded image saved to: {output_file}")


def handle_decode(algorithm, encoded_image_file, output_audio_file):
    """Decodes hidden audio from an image using the chosen algorithm."""
    logger.info(
        f"Decoding using {algorithm['name']} from file: {encoded_image_file}"
    )

    decoded_path = None
    for _ in tqdm(range(1), desc="Decoding Progress"):
        decoded_path = algorithm["decode"](encoded_image_file, output_audio_file)

    if decoded_path:
        print(f"\nExtracted audio saved to: {decoded_path}")
    else:
        print("Failed to decode hidden audio.")


def handle_main_choice(choice):
    """Handles the user's main menu choice."""
    logger.info(f"User selected main menu choice: {choice}")

    if choice == 1:
        handle_algorithm_choice(encode=True)
    elif choice == 2:
        handle_algorithm_choice(encode=False)
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