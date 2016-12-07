from PIL import Image,ImageTk
from PIL import ImageTk as ITk
from PIL import ImageFilter
import Tkinter as tk
import math
import numpy
import string
import random

origImage = Image.open("Julia360.png")
origPixels = origImage.load()
(height,width) = origImage.size
newImage = Image.new("RGB", (height, width), "white")
newPixels = newImage.load()
blurRadius = 20

blurredPixels = origImage.filter(ImageFilter.GaussianBlur(radius=blurRadius)).load()
for strokeRadius in xrange(15,0,-3): 
    numSteps = 3
    strokeStep = strokeRadius
    NEIGHBOR_OFFSETS = [
    (-5,-5), (0,-5), (5,-5),
    (-5, 0),         (5, 0),
    (-5, 5), (0, 5), (5, 5)
    ]
    strokeLength = 20 * strokeRadius   
    for stroke in xrange(100000):
        randY = random.randint(0+strokeLength,height-strokeLength-1)
        randX = random.randint(0+strokeLength,width -strokeLength-1)
        try: 
            rgbCurr = blurredPixels[randY,randX]
        except:
            continue
        bestScore = None
        bestDir = None
        for (dx,dy) in NEIGHBOR_OFFSETS:
            (nX,nY) = (randX + dx, randY + dy)
            try:
                testRGB = origPixels[nY,nX]
            except:
                continue
            testScore = math.sqrt((rgbCurr[0]-testRGB[0])**2 + (rgbCurr[1]-testRGB[1])**2 + (rgbCurr[2]-testRGB[2])**2)
            if (testScore < bestScore or bestScore == None):
                bestScore = testScore
                bestDir = (dx,dy)
        for i in xrange(strokeStep):
            strokeY = randY + bestDir[1] * i
            strokeX = randX + bestDir[0] * i
            for y in xrange(strokeY-strokeRadius, strokeY + strokeRadius):
                for x in xrange(strokeX-strokeRadius, strokeX + strokeRadius):
                    if (0 <= y <= height-1 and 0 <= x <= width-1):
                        newPixels[y,x] = testRGB
newImage.save('testx.png')