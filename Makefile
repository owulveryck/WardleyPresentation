# Makefile to convert images (JPG or PNG) to a grayscale 4-bit PDF with a custom message, contrast adjustment, 8 levels of gray, and a background image using ImageMagick

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

# Background image
BACKGROUND = background.png

# SVG files to be converted to PNG
SVG_FILES = $(wildcard *.svg)
PNG_FILES = $(SVG_FILES:.svg=.png)

# # Background image with rounded corners and annotation
BACKGROUND_IMAGE = background.png

# Conversion rule
all: $(BLANK) $(OUTPUT) $(BACKGROUND_IMAGE)


$(BLANK):
	convert -size 1872x1404 xc:white $(BLANK)

$(BACKGROUND_IMAGE):
	convert -size 1872x1404 xc:white -fill none -stroke gray -strokewidth 60 -draw "roundrectangle 30,30 1842,1374 45,45" rounded.png
	convert -background none -fill white -gravity Center -pointsize 20 label:'$(MESSAGE)' label.png
	convert rounded.png label.png -gravity South -geometry +0+20 -composite $(BACKGROUND_IMAGE)
	rm rounded.png label.png

$(OUTPUT): $(IMAGE_LIST_FILE) $(BACKGROUND_IMAGE) svg2png
	mkdir -p $(TEMP_DIR)
	counter=1; \
	while IFS='|' read -r img title; do \
		temp_img="$(TEMP_DIR)/temp_$$(printf "%03d" $$counter)_$$(basename $$img)"; \
		output_file="$(TEMP_DIR)/$$(printf "%03d" $$counter)_$$(basename $$img)"; \
		convert "$$img" -contrast -resize 1752x1284 -background none -gravity center -extent 1752x1284 -colorspace Gray -colors 8 "$$temp_img"; \
		convert -background none -fill white -gravity Center -pointsize 20 label:"$$title" label.png; \
		convert $(BACKGROUND_IMAGE) label.png -gravity North -geometry +0+20 -composite slide.png; \
		composite -gravity center "$$temp_img" slide.png "$$output_file"; \
		rm "$$temp_img" label.png slide.png; \
		counter=$$((counter + 1)); \
	done < $(IMAGE_LIST_FILE)
	convert -units PixelsPerInch -density 150x150 $(TEMP_DIR)/* $@
	rm -rf $(TEMP_DIR)

svg2png: $(PNG_FILES)

%.png: %.svg
	convert $< $@

clean:
	rm -f $(OUTPUT) $(BLANK) $(PNG_FILES)

.PHONY: all clean svg2png
