"""Create original small-footprint musical loops and Foley for the Godot build.

All music is algorithmically composed for this project; it contains no samples
of existing works. Uses Python's standard library only.
"""
from __future__ import annotations
import math
import random
import struct
import wave
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
OUT.mkdir(parents=True, exist_ok=True)
RATE = 22050
TAU = 2 * math.pi
PENTA = [0, 2, 4, 7, 9, 12, 14, 16, 19]
SCROLLS = [
    (86, 47, [0, 2, 4, 2, 5, 4, 1, 2], .24),
    (72, 50, [0, 4, 6, 4, 2, 1, 3, 1], .18),
    (116, 54, [0, 4, 2, 5, 4, 2, 3, 1], .30),
    (94, 43, [0, 5, 2, 6, 4, 1, 7, 3], .14),
    (104, 45, [0, 3, 5, 3, 6, 5, 4, 2], .25),
    (98, 41, [0, 2, 5, 4, 1, 3, 2, 6], .21),
    (112, 47, [0, 5, 4, 3, 7, 5, 2, 4], .30),
    (120, 52, [0, 7, 4, 6, 2, 8, 4, 6], .20),
]

def hz(midi):
    return 440.0 * (2 ** ((midi-69)/12))

def save(path, samples):
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(struct.pack("<" + "h"*len(samples), *[max(-32767,min(32767,int(v*28000))) for v in samples]))

def bell(x, f, tail=.74):
    env=math.exp(-x*5.1/tail)
    return env*(math.sin(TAU*f*x)+.29*math.sin(TAU*f*2.009*x)+.13*math.sin(TAU*f*3.33*x))

def make_loop(number, bpm, root, melody, texture):
    beat=60.0/bpm
    duration=beat*16
    n=int(duration*RATE)
    randomizer=random.Random(number*1811)
    samples=[0.0]*n
    # Eight calm phrases repeated and varied; every world has a unique register
    # and polyrhythmic percussion rather than a generic game-loop backing track.
    root_f=hz(root)
    for i in range(n):
        t=i/RATE
        wobble=.012*math.sin(t*2.4+number)
        drone=(math.sin(TAU*root_f/2*t)+.3*math.sin(TAU*root_f*t))* .038
        air=math.sin(TAU*root_f*1.501*t+wobble)*.008
        samples[i]=drone+air
    for j in range(16):
        pitch=PENTA[melody[j%8]]
        f=hz(root+pitch+12)
        start=(j*beat + (beat*.11 if (j+number)%4==3 else 0.0))
        length=min(int(RATE*beat*.88),n-int(start*RATE))
        if length<=0:continue
        amplitude=.078 if j%4==0 else .049
        if number in (2,6):amplitude*=1.26
        for q in range(length):
            t=q/RATE
            touch=math.sin(TAU*f*t+2.7*math.exp(-t*24))
            overtone=.32*math.sin(TAU*f*2.0*t)+.12*math.sin(TAU*f*2.994*t)
            env=(1-math.exp(-t*110))*math.exp(-t/(beat*.39))
            samples[int(start*RATE)+q]+=amplitude*env*(touch+overtone)
    # Dry frame-drums, woodblocks, or bowls depending on the location.
    for j in range(32):
        start=int(j*beat/2*RATE)
        if start>=n:break
        strength=(.12 if j%4==0 else .039)*texture
        for q in range(min(int(.105*RATE),n-start)):
            t=q/RATE
            thump=math.sin(TAU*(83+22*math.exp(-t*35))*t)
            scratch=randomizer.uniform(-1,1)*math.exp(-t*51)
            samples[start+q]+=strength*math.exp(-t*26)*(thump+.15*scratch)
    # Soft fades prevent clicks when the Godot audio player restarts its loop.
    edge=min(int(.055*RATE),n//3)
    for i in range(edge):
        fade=math.sin((i+1)/(edge+1)*math.pi/2)**2
        samples[i]*=fade
        samples[n-i-1]*=fade
    save(OUT/f"scroll_{number:02d}.wav",samples)

def make_fx(name,frequency,duration,kind):
    rng=random.Random(sum(map(ord,name)))
    n=int(duration*RATE)
    a=[]
    for i in range(n):
        t=i/RATE
        if kind=="bell":
            val=bell(t,frequency,duration*.92)*.37
        elif kind=="wood":
            val=(math.sin(TAU*frequency*t)+.37*rng.uniform(-1,1))*math.exp(-t*32)*.38
        elif kind=="slide":
            f=frequency*math.exp(-t*4)
            val=(math.sin(TAU*f*t)+.19*math.sin(TAU*2.4*f*t))*math.exp(-t*8)*.28
        elif kind=="gong":
            val=(math.sin(TAU*frequency*t)+.25*math.sin(TAU*frequency*1.419*t)+.16*math.sin(TAU*frequency*2.18*t))*math.exp(-t*4)*.31
        else:
            val=(math.sin(TAU*frequency*t)+.36*math.sin(TAU*(frequency*1.52)*t))*math.exp(-t*9)*.30
        val*=min(1.0,t*170)
        a.append(val)
    save(OUT/f"fx_{name}.wav",a)

for idx,(bpm,root,melody,texture) in enumerate(SCROLLS,1):
    make_loop(idx,bpm,root,melody,texture)
for spec in [
    ("drop",420,.33,"slide"),("tap",600,.12,"wood"),
    ("place",466,.4,"bell"),("magic",820,.58,"bell"),
    ("settle",310,.34,"slide"),("tribute",182,1.1,"gong"),
    ("loss",136,1.2,"gong"),("wood",520,.19,"wood"),
    ("bell",720,.55,"bell"),("blade",960,.27,"slide"),
]:
    make_fx(*spec)
print("Created",len(list(OUT.glob('*.wav'))),"original WAV files in",OUT)
