# Research Project
## Project Structure
- `data/raw/`: Original data (read-only)
- `data/clean/`: Processed data
- `code/`: Stata do-files
- `output/`: Tables and Figures
- `paper/`: LaTeX files

## Build Commands
- Run Stata script: `stata -b do code/master.do`
- Compile LaTeX: `pdflatex paper/main.tex`

## Code Style Guidelines
- **Stata**: Use clear variable labels, version control at the top of do-files.
- **Organization**: Always use relative paths (e.g., `../data/raw/`) to ensure reproducibility.