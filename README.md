# Pseudo-to-C-Compiler
Pseudo_code to C code compiler using flex and bison 
# My Compiler Project

## Overview

This compiler project translates source code written in a custom language into C code, integrating both a powerful backend and an interactive frontend for ease of use. The project showcases my skills in full-stack development using HTML, CSS, JavaScript, and Flask.

## 🌟 Features

- **Tokenization and Parsing:** Utilizes lexical and syntax analysis to process input code.
- **Semantic Checks:** Ensures code correctness before translation.
- **Intermediate Code Generation:** Converts parsed structures into executable C code.
- **Control Structures:** Supports `if`, `else`, `do-while`, and `for` loops.
- **Function Definitions and Calls:** Handles custom functions and parameter passing.
- **Error Handling:** Robust error messages for easier debugging.
- **Web Interface:** Interactive frontend for input and output, using HTML, CSS, and JavaScript.
- **Backend Integration:** Flask used to connect frontend and backend seamlessly.

## 🛠️ Technologies Used

- **Flex/Bison:** For lexical and syntax analysis.
- **C Programming Language:** Core language for compiler logic and code generation.
- **HTML/CSS/JavaScript:** Creates a user-friendly frontend interface.
- **Flask:** Facilitates communication between the frontend and backend.
- **Standard Libraries:** Utilized for string manipulation and input/output operations.

## 🔍 Example

### 🧾 Pseudo-Code Input
```plaintext
START
DECLARE n, i, result
INPUT n
PRINT n

FOR (i = 1; i <= n; i = i + 1) {
  result = square(i)
  PRINT result
}

END

FUNCTION square(x)
  RETURN x * x
```
🔁 Translates To C Code
```bash
#include <stdio.h>

int main() {
    int n = 0;
    int i = 0;
    int result = 0;
    scanf("%d", &n);
    printf("%d\n", n);
for (i = 1; (i <= n); i = (i + 1)) {
    result = square(i);
    printf("%d\n", result);
}

    return 0;
}

int square(int x) {
    return (x * x);

}

```
Set Up the Backend:

Build the Compiler:
```bash
flex pseudo_code.l
bison -d pseudo_code.y
gcc y.tab.c lex.yy.c -o pseudo_compiler_ -ly -lfl
```

Run the Flask Application:
```bash
python app.py
```
Access the Frontend:

🧭 Locate the frontend/front1.html file in your project folder and double-click it to open in your default browser.
