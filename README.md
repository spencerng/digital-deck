# Digital Deck

A projection mapping take on the Invisible Deck magic routine

Powered by vosk, Processing, TouchDesigner, and a bit of Spout and OSC

## Setup

1. Download a [vosk model](https://alphacephei.com/vosk/models)
2. Run the speech recognition pipeline: `python3 asr/asr_server_microphone.py --model <model folder> `
3. Open `processing_cards/Cards.pde` and run the Processing script, ensuring that Spout is installed
4. Set up an overhead projector, or mount a mini projector such that it's projecting onto a flat surface (angled towards the left side of the performer is best)
5. Start TouchDesigner and ensure the central Kantan Mapper object outputs to your projector
6. Adjust the projection mapped cards and card box, then begin the performance

## Performance

Follow along the script at [this link](https://docs.google.com/document/d/e/2PACX-1vT4RWbKboFpatFhhWIXgymh1olzlbz-UDoUdl6nbdUQ57L1BZGt-HgxhJl-AN278AThzKU5PzMqzs47/pub)!