import numpy as np
import wave
import struct

def gwave(a, b, c, T, Fs):
    # Generate time array
    t = np.linspace(0, T, int(Fs * T), endpoint=False)
    
    # Calculate instantaneous phase by integrating frequency
    # Phase(t) = integral of 2*pi*f(t) dt
    # For f(t) = a*t^2 + b*t + c:
    # Phase(t) = 2*pi * (a*t^3/3 + b*t^2/2 + c*t)
    phase = 2 * np.pi * (a * t**3 / 3 + b * t**2 / 2 + c * t)
    
    # Generate the signal
    signal = np.sin(phase)
    
    # Normalize to 16-bit range
    signal_normalized = np.int16(signal * 32767)
    
    # Write WAV file
    with wave.open("output.wav", 'w') as wav_file:
        # Set WAV file parameters
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 2 bytes per sample (16-bit)
        wav_file.setframerate(Fs)  # Sampling frequency
        wav_file.setnframes(len(signal_normalized))
        
        # Write audio data
        for sample in signal_normalized:
            wav_file.writeframes(struct.pack('<h', sample))
    return signal