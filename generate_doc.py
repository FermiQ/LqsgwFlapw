import argparse
import os
import re

def parse_fortran_file(filepath):
    """
    Parses a Fortran file to extract modules, subroutines, functions, and variables.
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return None
    except Exception as e:
        print(f"Error reading file {filepath}: {e}")
        return None

    # Remove comments (lines starting with c, *, or !)
    # Process line continuations (&) by joining lines. This is a simplified approach.
    processed_lines = []
    for line in content.splitlines():
        stripped_line = line.strip()
        if stripped_line.startswith(('c', '*', '!')):
            continue
        if processed_lines and processed_lines[-1].endswith('&'):
            processed_lines[-1] = processed_lines[-1][:-1] + stripped_line
        else:
            processed_lines.append(stripped_line)

    clean_content = "\n".join(processed_lines)

    # Extract file base name
    file_name = os.path.basename(filepath)

    # Regex patterns (simplified for common cases)
    module_use_pattern = re.compile(r"^\s*use\s+([a-z0-9_]+)", re.IGNORECASE | re.MULTILINE)
    subroutine_pattern = re.compile(
        r"^\s*subroutine\s+([a-z0-9_]+)\s*(?:\((.*?)\))?",
        re.IGNORECASE | re.MULTILINE
    )
    # Fortran function patterns can be complex due to optional type prefixes and result clauses
    function_pattern = re.compile(
        r"^\s*(?:(?:real|integer|character|logical|double\s*precision|complex)(?:\s*\(.*?\))?\s+)?function\s+([a-z0-9_]+)\s*\((.*?)\)\s*(?:result\s*\((.*?)\))?",
        re.IGNORECASE | re.MULTILINE
    )

    # Module-level variable declarations (very simplified)
    # This will capture lines like: type :: var1, var2 or type, intent(in) :: var
    # It doesn't distinguish between module scope and local scope perfectly without full parsing.
    # We'll try to refine this by looking for declarations outside subroutines/functions.

    # First, find module blocks
    module_blocks_matches = list(re.finditer(r"^\s*module\s+([a-z0-9_]+)\s*$(.*?)^\s*end\s*module\s+\1", clean_content, re.IGNORECASE | re.MULTILINE | re.DOTALL))

    module_variables = []
    if module_blocks_matches:
        for mod_match in module_blocks_matches:
            module_content = mod_match.group(2)
            # Remove subroutines and functions from module content to isolate module-level variables
            module_content_no_subs_funcs = re.sub(subroutine_pattern, "", module_content)
            module_content_no_subs_funcs = re.sub(function_pattern, "", module_content_no_subs_funcs)

            # Look for variable declarations: type :: var, type, attr :: var
            # This is a very basic pattern and might need significant improvement.
            var_decl_pattern = re.compile(
                r"^\s*(real|integer|character|logical|double\s*precision|complex|type\s*\(.*?\))\s*(?:,\s*[^:]+)?::\s*([a-z0-9_,\s()]+)",
                re.IGNORECASE | re.MULTILINE
            )
            for var_match in var_decl_pattern.finditer(module_content_no_subs_funcs):
                var_type = var_match.group(1).strip()
                var_names_str = var_match.group(2).strip()
                # Split variable names, handling array dimensions like var(dim)
                raw_names = [name.strip().split('(')[0] for name in var_names_str.split(',')]
                for name in raw_names:
                    if name: # Ensure not empty string
                        module_variables.append({"name": name, "type": var_type})

    modules_used = sorted(list(set(module_use_pattern.findall(clean_content))))

    subroutines = []
    for match in subroutine_pattern.finditer(clean_content):
        name = match.group(1)
        args_str = match.group(2)
        args = [arg.strip() for arg in args_str.split(',') if arg.strip()] if args_str else []
        subroutines.append({"name": name, "args": args})

    functions = []
    for match in function_pattern.finditer(clean_content):
        name = match.group(1)
        args_str = match.group(2)
        args = [arg.strip() for arg in args_str.split(',') if arg.strip()] if args_str else []
        # Return type might be part of the declaration (group before function name) or result clause
        # This regex doesn't fully capture the type prefix yet, needs refinement.
        # For now, we'll placeholder the return type.
        return_type = "unknown" # Placeholder
        if match.group(3): # result(var_name)
            return_type = f"result({match.group(3)})"
        # elif match.group(1) contains type: # This part of regex needs to be structured to capture prefix
        #    return_type = match.group(1).strip() # Simplified
        functions.append({"name": name, "args": args, "return_type": return_type})

    return {
        "file_name": file_name,
        "modules_used": modules_used,
        "subroutines": subroutines,
        "functions": functions,
        "module_variables": module_variables,
    }

def generate_markdown(parsed_data, template_with_placeholders):
    """
    Generates Markdown documentation from parsed Fortran data using a template.
    """
    if not parsed_data:
        return None

    # Perform replacements of placeholders for code blocks
    current_template = template_with_placeholders.replace("FORTRAN_CODE_BLOCK_START", "! --- Start Fortran Example ---")
    current_template = current_template.replace("FORTRAN_CODE_BLOCK_END", "! --- End Fortran Example ---")

    file_name = parsed_data["file_name"]

    modules_used_list_md = "\n".join(f"*   `{mod}`" for mod in parsed_data["modules_used"]) \
        if parsed_data["modules_used"] else "None."

    subroutines_md = []
    for sub in parsed_data["subroutines"]:
        arg_list = ", ".join(sub["args"])
        subroutines_md.append(f"*   **{sub['name']}**({arg_list}): *Brief description placeholder.*")

    functions_md = []
    for func in parsed_data["functions"]:
        arg_list = ", ".join(func["args"])
        # For now, return type is basic.
        functions_md.append(f"*   **{func['name']}**({arg_list}) (returns {func['return_type']}): *Brief description placeholder.*")

    subroutines_functions_list_md = "\n".join(subroutines_md + functions_md) \
        if (subroutines_md + functions_md) else "None."

    module_variables_list_md = "\n".join(f"*   **{var['name']}** ({var['type']}): *Description placeholder.*" \
                                         for var in parsed_data["module_variables"]) \
        if parsed_data["module_variables"] else "None."

    modules_used_comma_separated_md = ", ".join(f"`{mod}`" for mod in parsed_data["modules_used"]) \
        if parsed_data["modules_used"] else "None."

    # Populate template
    markdown_content = current_template.format(
        file_name=file_name,
        modules_used_list=modules_used_list_md,
        subroutines_functions_list=subroutines_functions_list_md,
        module_variables_list=module_variables_list_md,
        modules_used_list_comma_separated=modules_used_comma_separated_md
    )
    return markdown_content

MARKDOWN_TEMPLATE_WITH_PLACEHOLDERS = """\
# {{file_name}} - Code Documentation

## Overview

*Please provide a brief description of what this code file does and its role within the larger project.*

## Key Components

### Modules Used
{{modules_used_list}}

### Subroutines/Functions Defined
{{subroutines_functions_list}}

## Important Variables/Constants
{{module_variables_list}}

## Usage Examples

*Please provide examples or code snippets demonstrating how to use the functions, classes, or modules in this file.*

FORTRAN_CODE_BLOCK_START
! Example code snippet
FORTRAN_CODE_BLOCK_END

## Dependencies and Interactions

*   **Internal Dependencies:**
    *   Relies on modules: {{modules_used_list_comma_separated}}
    *   *(Add other specific interactions if known)*
*   **External Libraries:**
    *   *(Specify if any external libraries are directly used and not via other project modules)*

---
*Documentation generated by AI assistant. Please review and enhance.*
"""

def main():
    parser = argparse.ArgumentParser(description="Generate Markdown documentation from Fortran source files.")
    parser.add_argument("fortran_file", help="Path to the Fortran source file.")
    args = parser.parse_args()

    fortran_filepath = args.fortran_file

    # Create docs/markdown directory if it doesn't exist
    output_dir = "docs/markdown"
    os.makedirs(output_dir, exist_ok=True)

    # Parse the Fortran file
    parsed_data = parse_fortran_file(fortran_filepath)

    if not parsed_data:
        print(f"Failed to parse {fortran_filepath}. Exiting.")
        return

    # Generate Markdown content
    markdown_content = generate_markdown(parsed_data, MARKDOWN_TEMPLATE_WITH_PLACEHOLDERS)

    if not markdown_content:
        print("Failed to generate Markdown content. Exiting.")
        return

    # Determine output filename
    base_name = parsed_data["file_name"]
    output_filename = os.path.splitext(base_name)[0] + ".md"
    output_filepath = os.path.join(output_dir, output_filename)

    # Write the Markdown content to the output file
    try:
        with open(output_filepath, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        print(f"Successfully generated documentation: {output_filepath}")
    except Exception as e:
        print(f"Error writing Markdown file {output_filepath}: {e}")

if __name__ == "__main__":
    main()
```
