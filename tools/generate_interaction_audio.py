"""Generate small original interaction sounds for Jianhu, without samples."""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUTPUT = Path(__file__).resolve().parents[1] / "assets" / "audio"


def write(name, duration, render):
    samples = [render(i / RATE) for i in range(int(duration * RATE))]
    # Fade the final few milliseconds to avoid an audible discontinuity.
    fade = int(.012 * RATE)
    for i in range(fade):
        samples[-1 - i] *= i / fade
    pcm = [max(-32767, min(32767, round(x * 25000))) for x in samples]
    with wave.open(str(OUTPUT / f"fx_{name}.wav"), "wb") as out:
        out.setparams((1, 2, RATE, len(pcm), "NONE", "not compressed"))
        out.writeframes(struct.pack(f"<{len(pcm)}h", *pcm))


def pluck(t):
    attack = 1 - math.exp(-t * 150)
    body = (math.sin(math.tau * 570 * t) * math.exp(-t * 14)
            + .32 * math.sin(math.tau * 1142 * t) * math.exp(-t * 25)
            + .10 * math.sin(math.tau * 1707 * t) * math.exp(-t * 45))
    return .30 * attack * body


noise = random.Random(429)
def parry(t):
    envelope = (1 - math.exp(-t * 65)) * math.exp(-t * 10)
    # An airy brush sweep and a short wooden knock, with a smooth attack.
    sweep = noise.uniform(-1, 1) * math.exp(-t * 17)
    knock = math.sin(math.tau * (230 * t - 190 * t * t)) * math.exp(-t * 18)
    return envelope * (.12 * sweep + .35 * knock)


write("peg", .32, pluck)
write("parry", .38, parry)
