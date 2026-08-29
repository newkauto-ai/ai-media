# BGM Adapter

Compile the ADP Music Brief and derived music prompt into an independent BGM asset request. Store the resulting asset and mix decision outside Video Prompts.

Read the [BGM Production Contract](../contracts/bgm-production-contract.md) before planning or executing a request. The configured provider path is [ElevenLabs Music v2](elevenlabs-music-v2-adapter.md). Its guarded script is dry-run by default; adding the Adapter does not authorize a live call.

Before any generation, present provider, model, exact prompt hash, duration, quantity, output format, estimated credits, monetary-cost status, output path, and stopping condition. One approved call must stop after download and technical integrity checks. Human listening and timeline editing remain separate decisions.
