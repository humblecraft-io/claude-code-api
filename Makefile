# Claude Code API - Simple & Working

# Virtual environment settings
VENV_DIR = venv
VENV_BIN = $(VENV_DIR)/bin
PYTHON = $(VENV_BIN)/python
PIP = $(VENV_BIN)/pip

# Python targets
.PHONY: venv
venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment..."; \
		python3 -m venv $(VENV_DIR); \
		echo "Virtual environment created at $(VENV_DIR)"; \
		echo ""; \
		echo "To activate it manually, run:"; \
		echo "  source $(VENV_BIN)/activate"; \
	else \
		echo "Virtual environment already exists at $(VENV_DIR)"; \
	fi

install: venv
	@echo "Installing dependencies in virtual environment..."
	$(PIP) install --upgrade pip
	$(PIP) install -e .
	@echo ""
	@echo "✓ Installation complete!"
	@echo "To use the venv, run: source $(VENV_BIN)/activate"

test:
	$(PYTHON) -m pytest tests/ -v

test-real:
	$(PYTHON) tests/test_real_api.py

start:
	$(VENV_BIN)/uvicorn claude_code_api.main:app --host 0.0.0.0 --port 8000 --reload --reload-exclude="*.db*" --reload-exclude="*.log"

start-prod:
	$(VENV_BIN)/uvicorn claude_code_api.main:app --host 0.0.0.0 --port 8000

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete

clean-venv:
	rm -rf $(VENV_DIR)
	@echo "Virtual environment removed"

kill:
	@if [ -z "$(PORT)" ]; then \
		echo "Error: PORT parameter is required. Usage: make kill PORT=8001"; \
	else \
		echo "Looking for processes on port $(PORT)..."; \
		if [ "$$(uname)" = "Darwin" ] || [ "$$(uname)" = "Linux" ]; then \
			PID=$$(lsof -iTCP:$(PORT) -sTCP:LISTEN -t); \
			if [ -n "$$PID" ]; then \
				echo "Found process(es) with PID(s): $$PID"; \
				kill -9 $$PID && echo "Process(es) killed successfully."; \
			else \
				echo "No process found listening on port $(PORT)."; \
			fi; \
		else \
			echo "This command is only supported on Unix-like systems (Linux/macOS)."; \
		fi; \
	fi

help:
	@echo "Claude Code API Commands:"
	@echo ""
	@echo "Python API:"
	@echo "  make venv        - Create virtual environment"
	@echo "  make install     - Install Python dependencies (creates venv if needed)"
	@echo "  make test        - Run Python unit tests with real Claude integration"
	@echo "  make test-real   - Run REAL end-to-end tests (curls actual API)"
	@echo "  make start       - Start Python API server (development with reload)"
	@echo "  make start-prod  - Start Python API server (production)"
	@echo ""
	@echo "TypeScript API:"
	@echo "  make install-js     - Install TypeScript dependencies" 
	@echo "  make test-js        - Run TypeScript unit tests"
	@echo "  make test-js-real   - Run Python test suite against TypeScript API"
	@echo "  make start-js       - Start TypeScript API server (production)"
	@echo "  make start-js-dev   - Start TypeScript API server (development with reload)"
	@echo "  make start-js-prod  - Build and start TypeScript API server (production)"
	@echo "  make build-js       - Build TypeScript project"
	@echo ""
	@echo "General:"
	@echo "  make clean       - Clean up Python cache files"
	@echo "  make clean-venv  - Remove virtual environment"
	@echo "  make kill PORT=X - Kill process on specific port"
	@echo ""
	@echo "IMPORTANT: Both implementations are functionally equivalent!"
	@echo "Use Python or TypeScript - both provide the same OpenAI-compatible API."