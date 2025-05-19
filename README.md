# Mini Compiler Web Application

A web-based mini compiler that supports a subset of C language syntax. The application features a Monaco editor for code input and real-time compilation.

## Features
- Monaco editor for code input
- C language subset support
- Real-time compilation
- Syntax highlighting
- Error reporting
- Traditional Lex/Bison implementation

## Setup

### Prerequisites
- Python 3.6+
- GCC compiler
- Flex (Lex)
- Bison
- Make

### Backend Setup
1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Build the C compiler:
```bash
cd backend/compiler
make
cd ../..
```

4. Run the backend server:
```bash
python run.py
```

### Frontend Setup
1. Open `frontend/index.html` in your browser
2. Or serve it using a local server:
```bash
python -m http.server 8000
```

## Usage
1. Write your C code in the Monaco editor
2. Click the "Compile" button
3. View the compilation output and any errors in the output panel

## Project Structure
- `backend/` - Python Flask server and C compiler implementation
  - `compiler/` - C compiler source files
    - `lexer.l` - Lexer definition
    - `parser.y` - Parser definition
    - `Makefile` - Build configuration
- `frontend/` - HTML, CSS, and JavaScript files
  - `index.html` - Main application page
  - `styles.css` - Styling
  - `script.js` - Frontend logic

## Supported C Language Features
- Basic types (int, char, void)
- Variable declarations and assignments
- Arithmetic expressions
- Control structures (if-else, while)
- Functions
- Return statements 