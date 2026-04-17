from utils.logging_util import setup_logger
from cli.config import ALGORITHMS

logger = setup_logger(__name__)


def display_menu(options, header):
    """Displays a menu with a header and a list of options."""
    logger.info(f"Displaying {header} menu to the user.")
    print(f"\n{header}:")
    for idx, option in enumerate(options, 1):
        print(f"{idx}) {option}")


def get_user_choice(num_options):
    """Gets a validated user choice for a menu."""
    try:
        choice = int(input("\nChoice: "))
        if 1 <= choice <= num_options:
            return choice
        logger.warning("Choice out of range.")
        print("\nInvalid choice, please select a valid option.")
    except ValueError:
        logger.error("Invalid input; not a number.")
        print("\nPlease enter a valid number!")
    return None


def get_path_with_default(default_path, label):
    """Gets a file path from the user or uses the default path."""
    use_standard = input(f"\nUse default path ({default_path}) for the {label}? (y/n): ").strip().lower()

    if use_standard == "y":
        logger.info(f"Using default path for {label}: {default_path}")
        return default_path

    file_path = input(f"Enter the path to the {label}: ").strip()
    logger.info(f"User entered custom path for {label}: {file_path}")
    return file_path


def display_algorithm_menu():
    """Displays the algorithm selection menu based on the ALGORITHMS dictionary."""
    options = [algo["name"] for algo in ALGORITHMS.values()]
    display_menu(options, "Select an algorithm")