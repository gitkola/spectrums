# Spectrums

A comparison of how different AI models respond to the same prompt. Each file is a self-contained microphone audio visualizer — no dependencies, no build step.

## Prompt

> Write in a single html file the program which will display Amp/Freq/Time diagram from microphone input.

## Models

| File          | Model  | Visualization                                         |
| ------------- | ------ | ----------------------------------------------------- |
| `claude.html` | Claude | Isometric 3D waterfall with color-coded amplitude     |
| `gpt.html`    | GPT    | Scrolling spectrogram (time × frequency × color)      |
| `gpt2.html`   | GPT    | Dual canvas: waveform + frequency bars                |
| `gpt3.html`   | GPT    | Isometric 3D landscape with mouse rotation/pan/zoom   |
| `gemini.html` | Gemini | Scrolling spectrogram (time × frequency × color)      |
| `grok.html`   | Grok   | Waveform + scrolling spectrogram with custom gradient |

## Usage

Open `index.html` in a browser to view all visualizers in a tabbed mobile-first interface, or open any individual `.html` file directly.
