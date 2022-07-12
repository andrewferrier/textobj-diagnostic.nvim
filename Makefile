.PHONY: all clean test

test:
	nvim --headless -c "PlenaryBustedFile tests/textobj-diagnostic.lua"
