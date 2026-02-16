# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A collection of standalone HTML files comparing how different AI models (Claude, GPT, Gemini, Grok) respond to the same prompt: "Write in a single html file the program which will display Amp/Freq/Time diagram from microphone input." Each file is a self-contained microphone audio visualizer with no external dependencies.

## Running

Open any `.html` file directly in a browser. No build step, no server required. Each file uses the Web Audio API (`getUserMedia` + `AnalyserNode`) and Canvas 2D for rendering.

## Architecture

Each HTML file is fully self-contained (inline CSS + JS). Files are named by the AI that generated them:

- **claude.html** - Isometric 3D waterfall with color-coded amplitude
- **grok.html** - Waveform + scrolling spectrogram with custom color gradient
- **gemini.html** / **gpt.html** - Scrolling spectrogram (time on X, frequency on Y, color = amplitude)
- **gpt2.html** - Dual canvas: waveform (time domain) + frequency bars
- **gpt3.html** - Isometric 3D landscape with mouse rotation/pan/zoom controls

Common pattern across all files: microphone access via `getUserMedia`, FFT via `AnalyserNode`, rendering via `requestAnimationFrame` loop on a `<canvas>`.
