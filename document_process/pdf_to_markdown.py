import os
import pdfplumber

def pdf_to_markdown(pdf_folder, markdown_folder):
    # Ensure the output directory exists
    if not os.path.exists(markdown_folder):
        os.makedirs(markdown_folder)

    # Get all PDF files in the specified directory
    files = [f for f in os.listdir(pdf_folder) if f.lower().endswith('.pdf')]
    for i, file in enumerate(files):
        pdf_path = os.path.join(pdf_folder, file)
        md_filename = f"{os.path.splitext(file)[0]}.md"
        md_path = os.path.join(markdown_folder, md_filename)

        with pdfplumber.open(pdf_path) as pdf:
            with open(md_path, 'w', encoding='utf-8') as md_file:
                for num, page in enumerate(pdf.pages):
                    text = page.extract_text(x_tolerance_ratio=0.2)
                    if text:
                        md_file.write(text)
                        md_file.write("\n")

if __name__ == '__main__':
    # Read environment variables for paths
    pdf_folder = os.environ.get('PDF_FOLDER', '/app/pdfs')
    markdown_folder = os.environ.get('MARKDOWN_FOLDER', '/app/markdowns')

    # Run the conversion function
    pdf_to_markdown(pdf_folder, markdown_folder)