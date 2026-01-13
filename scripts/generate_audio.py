import wave
import math
import struct
import random

def write_wav(filename, duration, frequency_func, volume=0.5):
    sample_rate = 44100
    n_frames = int(duration * sample_rate)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        data = bytearray()
        for i in range(n_frames):
            t = i / sample_rate
            freq = frequency_func(t, duration)
            sample = int(volume * 32767.0 * math.sin(2.0 * math.pi * freq * t))
            data += struct.pack('<h', sample)
            
        wav_file.writeframes(data)

# Generate Jump Sound (Ascending sweep)
def jump_freq(t, duration):
    return 200 + (t / duration) * 400  # 200Hz to 600Hz

write_wav('assets/audio/jump.wav', 0.3, jump_freq, volume=0.3)

# Generate Title Music (Simple arpeggio loop)
def music_freq(t, duration):
    # Simple C Major arpeggio
    measure = t % 1.0 # 1 second per measure
    note = int(measure * 4) # 4 notes per second
    
    notes = [261.63, 329.63, 392.00, 523.25] # C4, E4, G4, C5
    return notes[note % 4]

# Generate 10 seconds of "music"
write_wav('assets/audio/title_music.wav', 10.0, music_freq, volume=0.2)
