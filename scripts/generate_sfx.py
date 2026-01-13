import wave
import math
import random
import struct

def generate_wave(filename, duration, frequency_func, volume=0.5):
    sample_rate = 44100
    n_samples = int(sample_rate * duration)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(n_samples):
            t = i / sample_rate
            freq = frequency_func(t, duration)
            value = int(32767.0 * volume * math.sin(2.0 * math.pi * freq * t))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

def damage_sound(t, d):
    # Dissonant descending slide
    return 400 - (t / d) * 300 + random.uniform(-20, 20)

def kill_sound(t, d):
    # Quick ascending slide (coin-like but punchier)
    return 400 + (t / d) * 800

def menu_sound(t, d):
    return 440

if __name__ == "__main__":
    generate_wave("assets/audio/damage.wav", 0.3, damage_sound, 0.6)
    generate_wave("assets/audio/kill.wav", 0.15, kill_sound, 0.5)
    print("Generated audio files.")
