def text_to_binary(text):
    binary = ""
    for char in text:
        binary += format(ord(char), "08b")
    return binary


def binary_to_text(binary):
    text = ""
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            text += chr(int(byte, 2))
    return text


def encode_text(cover_text, secret_text):
    # Zero-width characters
    zero_width_0 = '\u200B'   # Zero Width Space
    zero_width_1 = '\u200C'   # Zero Width Non-Joiner
    end_marker = '\u200D'     # Zero Width Joiner

    binary_secret = text_to_binary(secret_text)

    hidden_data = ""
    for bit in binary_secret:
        if bit == '0':
            hidden_data += zero_width_0
        else:
            hidden_data += zero_width_1

    encoded_text = cover_text + hidden_data + end_marker
    return encoded_text


def decode_text(encoded_text):
    zero_width_0 = '\u200B'
    zero_width_1 = '\u200C'
    end_marker = '\u200D'

    hidden_binary = ""

    for char in encoded_text:
        if char == zero_width_0:
            hidden_binary += '0'
        elif char == zero_width_1:
            hidden_binary += '1'
        elif char == end_marker:
            break

    if hidden_binary == "":
        return "No hidden message found."

    return binary_to_text(hidden_binary)


def save_to_file(filename, content):
    with open(filename, "w", encoding="utf-8") as file:
        file.write(content)


def read_from_file(filename):
    with open(filename, "r", encoding="utf-8") as file:
        return file.read()


def main():
    print("Text Steganography Program")
    print("1. Encode secret text into cover text")
    print("2. Decode secret text from encoded text")

    choice = input("Enter your choice (1 or 2): ")

    if choice == '1':
        cover_text = input("\nEnter the cover text:\n")
        secret_text = input("\nEnter the secret message:\n")

        encoded = encode_text(cover_text, secret_text)
        print("\nSecret message encoded successfully.")

        print("\nChoose output option:")
        print("1. Display encoded text")
        print("2. Save encoded text to file")

        output_choice = input("Enter your choice (1 or 2): ")

        if output_choice == '1':
            print("\nEncoded Text:\n")
            print(encoded)
            print("\nNote: The hidden characters are invisible, so it may look the same as the cover text.")
        elif output_choice == '2':
            filename = input("Enter output filename (example: encoded.txt): ")
            save_to_file(filename, encoded)
            print(f"Encoded text saved to {filename}")
        else:
            print("Invalid output choice.")

    elif choice == '2':
        print("\nChoose input option:")
        print("1. Paste encoded text")
        print("2. Read encoded text from file")

        input_choice = input("Enter your choice (1 or 2): ")

        if input_choice == '1':
            encoded_text = input("\nPaste the encoded text:\n")
        elif input_choice == '2':
            filename = input("Enter filename (example: encoded.txt): ")
            try:
                encoded_text = read_from_file(filename)
            except FileNotFoundError:
                print("File not found.")
                return
        else:
            print("Invalid input choice.")
            return

        decoded_message = decode_text(encoded_text)
        print("\nDecoded Message:")
        print(decoded_message)

    else:
        print("Invalid choice.")


if __name__ == "__main__":
    main()