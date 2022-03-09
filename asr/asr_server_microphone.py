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
                send_messages(final_text)
            else:
                result_partial = rec.PartialResult()
                if len(result_partial) > 20:
                    partial = json.loads(result_partial)["partial"]
                    print(partial)

                    send_messages(partial)

def send_messages(text):
    if "imagine" in text:
        if "fifty" in text:
            client.send_message("/deck/state", 3)
        elif ("deck" in text):
            client.send_message("/deck/state", 1)
    elif "blue deck of playing cards" in text:
        client.send_message("/deck/state", 2)
    elif "get rid" in text or "care of" in text or "giver of" in text or "get real" in text or "given the" in text:
        if "red" in text or "records" in text or "record" in text:
            client.send_message("/deck/limit_morph", "black")
            client.send_message("/deck/state", 3)
        elif "black" in text or "boy" in text or "white" in text or "bike" in text:
            client.send_message("/deck/limit_morph", "red")
            client.send_message("/deck/state", 3)
        elif "world" in text or "words" in text or "heart" in text:
            client.send_message("/deck/limit_morph", "diamonds")
            client.send_message("/deck/state", 3)
        elif "diamond" in text:
            client.send_message("/deck/limit_morph", "hearts")
            client.send_message("/deck/state", 3)
        elif "spade" in text or "speed" in text or "space" in text:
            client.send_message("/deck/limit_morph", "clubs")
            client.send_message("/deck/state", 3)
        elif "club" in text:
            client.send_message("/deck/limit_morph", "spades")
            client.send_message("/deck/state", 3)
    elif "let's keep" in text or "what's keep" in text or "what's he" in text or "of people" in text or "what's keyboard" in text:
        if "high" in text:
            client.send_message("/deck/state", 4)
            client.send_message("/deck/keep_only", "high")
        elif "low" in text or "local" in text: 
            client.send_message("/deck/state", 4)
            client.send_message("/deck/keep_only", "low")
        elif "middle" in text: 
            client.send_message("/deck/state", 4)
            client.send_message("/deck/keep_only", "middle")
    elif "flock" in text or "flux" in text:
        client.send_message("/deck/state", 5)
    elif "conjure up" in text or "contract" in text:
        if "is" in text or "ace" in text or "days" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 1)
        elif "two" in text or "too" in text or "to" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 2)
        elif "three" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 3)
        elif "four" in text or "for" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 4)
            
        elif "five" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 5)
        elif "six" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 6)
        elif "seven" in text or "southern" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 7)
        elif "eat" in text or "eight" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 8)
        elif "nine" in text or "line" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 9)
        elif "top" in text or "ten" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 10)
        elif "jack" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 11)
        elif "queen" in text or "quit" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 12)
        elif "king" in text:
            client.send_message("/deck/state", 6)
            client.send_message("/deck/chosen_value", 13)
    elif "insert" in text:
        client.send_message("/deck/state", 7)

            


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

    loop = asyncio.get_event_loop()
    
    await recognize_loop()

if __name__ == '__main__':
    asyncio.run(main())

