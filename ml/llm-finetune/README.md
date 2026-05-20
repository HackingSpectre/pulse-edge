# LLM fine-tuning (optional)

Fine-tune Gemma 3 1B on a small medical-Q&A + persona dataset using Unsloth
+ LoRA on a single Colab T4 GPU (free tier). Output is a GGUF or MediaPipe
`.task` file the Pulse Edge app can side-load via Settings → AI Assistant.

## Quick start

1. Open `notebooks/01_unsloth_lora_gemma3.ipynb` in Google Colab.
2. Runtime → Change runtime type → T4 GPU.
3. Run all. The notebook:
   - installs Unsloth,
   - downloads `unsloth/gemma-3-1b-it-bnb-4bit`,
   - mixes MedQuAD + HealthSearchQA + the persona examples in
     `data/persona_examples.jsonl`,
   - trains a LoRA adapter (~30 min on T4),
   - exports to GGUF Q4_K_M.

## Datasets

The notebook fetches:

| Dataset | License | Use |
|---|---|---|
| MedQuAD | CC0 | medical Q&A grounding |
| HealthSearchQA | Apache 2.0 | conversational queries |
| `data/persona_examples.jsonl` | this repo | the Pulse Edge voice |

`persona_examples.jsonl` is a hand-written set demonstrating the assistant's
required behavior: refuse diagnosis, plain language, suggest seeing a
clinician for serious symptoms, never invent vitals.

## Loading into the app

Either:

* drop the resulting `.gguf` into `app/assets/models/` and update
  `ModelBundle.gemma3Lite` to point at a local file URL, or
* publish the file (e.g. Hugging Face) and update the `url` field.
