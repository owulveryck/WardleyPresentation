# Makefile to convert images (JPG or PNG) to a grayscale 4-bit PDF with a custom message using ImageMagick

# Output PDF file name
OUTPUT = output.pdf

# File containing the list of image filenames
IMAGE_LIST_FILE = slides.txt

# Temporary directory for images with messages
TEMP_DIR = temp_msg

# Custom message to be added at the bottom of each image
MESSAGE = Olivier Wulveryck - OCTO Technology

# Blank image
BLANK = blank.png

# Conversion rule
all: $(BLANK) $(OUTPUT)

$(BLANK):
	convert -size 1872x1404 xc:white $(BLANK)

$(OUTPUT): $(IMAGE_LIST_FILE)
	mkdir -p $(TEMP_DIR)
	counter=1; \
	while IFS= read -r img; do \
		output_file="$(TEMP_DIR)/$$(printf "%03d" $$counter)_$$(basename $$img)"; \
		convert "$$img" -resize 1872x1404 -background white -gravity center -extent 1872x1404 -colorspace Gray -depth 4 -gravity SouthWest -pointsize 24 -annotate +10+10 '$(MESSAGE)' "$$output_file"; \
		counter=$$((counter + 1)); \
	done < $(IMAGE_LIST_FILE)
	convert -units PixelsPerInch -density 150x150 $(TEMP_DIR)/* $@
	rm -rf $(TEMP_DIR)

clean:
	rm -f $(OUTPUT) $(BLANK)

.PHONY: all clean
