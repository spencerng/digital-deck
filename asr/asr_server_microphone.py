#!/usr/bin/env python3

import json
import os
import sys
import asyncio
import sounddevice as sd
import argparse
import queue

from pythonosc import udp_client

from vosk import Model, KaldiRecognizer

def int_or_str(text):
    """Helper function for argument parsing."""
    try:
        return int(text)
    except ValueError:
        return text

def callback(indata, frames, time, status):
    """This is called (from a separate thread) for each audio block."""
    loop.call_soon_threadsafe(audio_queue.put_nowait, bytes(indata))


async def recognize_loop():
    global audio_queue

    model = Model(args.model)
    audio_queue = asyncio.Queue()
    
    with sd.RawInputStream(samplerate=args.samplerate, blocksize = 2000, device=args.device, dtype='int16',
                            channels=1, callback=callback) as device:

        rec = KaldiRecognizer(model, device.samplerate)
        while True:
            data = await audio_queue.get()
            if rec.AcceptWaveform(data):
                result = rec.Result()
                final_text = json.loads(result)["text"]
                print(final_text)
            else:
                result_partial = rec.PartialResult()
                if len(result_partial) > 20:
                    partial = json.loads(result_partial)["partial"]
                    print(partial)

                    send_messages(partial)

def send_messages(text):
    if "get rid" in text:
        if "red" in text:
            client.send_message("/deck/limit_morph", "black")
        elif "black" in text:
            client.send_message("/deck/limit_morph", "red")



async def main():

    global args
    global client
    global loop

    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-l', '--list-devices', action='store_true',
                        help='show list of audio devices and exit')
    args, remaining = parser.parse_known_args()
    if args.list_devices:
        print(sd.query_devices())
        parser.exit(0)
    parser = argparse.ArgumentParser(description="ASR Server",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     parents=[parser])
    parser.add_argument('-m', '--model', type=str, metavar='MODEL_PATH',
                        help='Path to the model', default='model')
    parser.add_argument('-i', '--interface', type=str, metavar='INTERFACE',
                        help='Bind interface', default='0.0.0.0')
    parser.add_argument('-p', '--port', type=int, metavar='PORT',
                        help='Port', default=2700)
    parser.add_argument('-d', '--device', type=int_or_str,
                        help='input device (numeric ID or substring)')
    parser.add_argument('-r', '--samplerate', type=int, help='sampling rate', default=16000)
    args = parser.parse_args(remaining)
    

    client = udp_client.SimpleUDPClient("127.0.0.1", 5005)
    client.send_message("/deck/limit_morph", "red")

    loop = asyncio.get_event_loop()
    
    await recognize_loop()

if __name__ == '__main__':
    asyncio.run(main())

