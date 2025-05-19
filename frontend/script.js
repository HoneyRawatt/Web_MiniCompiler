// Monaco Editor configuration
require.config({ paths: { vs: 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.36.1/min/vs' }});

require(['vs/editor/editor.main'], function() {
    // Initialize Monaco Editor
    const editor = monaco.editor.create(document.getElementById('editor'), {
        value: `#include <stdio.h>

int main() {
    int age;
    printf("Enter the age: ");
    scanf("%d", &age);
    printf("You entered: %d\\n", age);
    return 0;
}`,
        language: 'c',
        theme: 'vs-dark',
        automaticLayout: true,
        minimap: {
            enabled: true
        },
        fontSize: 14,
        tabSize: 4,
        scrollBeyondLastLine: false,
        lineNumbers: 'on',
        roundedSelection: true,
        scrollbar: {
            vertical: 'visible',
            horizontal: 'visible',
            useShadows: true,
            verticalScrollbarSize: 10,
            horizontalScrollbarSize: 10
        }
    });

    // Add C language configuration
    monaco.languages.register({ id: 'c' });
    monaco.languages.setMonarchTokensProvider('c', {
        tokenizer: {
            root: [
                [/[a-z_$][\w$]*/, { 
                    cases: {
                        '@keywords': 'keyword',
                        '@default': 'identifier'
                    }
                }],
                [/[A-Z][\w\$]*/, 'type.identifier'],
                [/[0-9]+/, 'number'],
                [/".*?"/, 'string'],
                [/\/\/.*/, 'comment'],
                [/[+\-*/=<>!&|^%]+/, 'operator'],
                [/[;:,.(){}[\]]/, 'delimiter']
            ]
        },
        keywords: [
            'if', 'else', 'while', 'for', 'return', 'int', 'char', 'void', 'main',
            'printf', 'scanf', 'include', 'define', 'struct', 'typedef', 'enum',
            'switch', 'case', 'break', 'continue', 'default', 'do', 'goto', 'sizeof'
        ]
    });

    // Get DOM elements
    const compileBtn = document.getElementById('compile-btn');
    const outputElement = document.getElementById('output');
    const programInput = document.getElementById('program-input');

    // Add loading state to button
    function setLoading(isLoading) {
        compileBtn.disabled = isLoading;
        compileBtn.innerHTML = isLoading 
            ? '<i class="fas fa-spinner fa-spin"></i> Compiling...'
            : '<i class="fas fa-play"></i> Compile & Run';
    }

    // Add success/error styling to output
    function setOutputStyle(isSuccess) {
        outputElement.style.color = isSuccess ? 'var(--success-color)' : 'var(--error-color)';
    }

    // Add animation to output
    function animateOutput() {
        outputElement.style.opacity = '0';
        setTimeout(() => {
            outputElement.style.opacity = '1';
        }, 100);
    }

    // Compile button click handler
    compileBtn.addEventListener('click', async () => {
        const code = editor.getValue();
        const input = programInput.value;
        
        // Clear previous output
        outputElement.textContent = '';
        setOutputStyle(true);
        
        // Validate input for scanf
        if (!input && code.includes('scanf')) {
            outputElement.textContent = '⚠️ Please enter input in the input box above before clicking Compile & Run';
            setOutputStyle(false);
            animateOutput();
            return;
        }
        
        try {
            setLoading(true);
            const response = await fetch('http://localhost:5000/compile', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    code: code,
                    input: input
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                outputElement.textContent = result.output;
                setOutputStyle(true);
            } else {
                outputElement.textContent = '❌ ' + result.errors.join('\n');
                setOutputStyle(false);
            }
        } catch (error) {
            outputElement.textContent = '❌ Error: ' + error.message;
            setOutputStyle(false);
        } finally {
            setLoading(false);
            animateOutput();
        }
    });

    // Add keyboard shortcut (Ctrl/Cmd + Enter) to compile
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, () => {
        compileBtn.click();
    });

    // Add input validation for program input
    programInput.addEventListener('input', () => {
        if (programInput.value.trim()) {
            programInput.style.borderColor = 'var(--success-color)';
        } else {
            programInput.style.borderColor = 'rgba(255, 255, 255, 0.1)';
        }
    });
}); 