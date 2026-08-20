# Static Scan with ModelAudit

Load when scanning model files for trojans, malicious code, and embedded executables.

## Basic Command

```bash
promptfoo scan-model [OPTIONS] PATH...
```

## Examples

```bash
# Scan a single model file
promptfoo scan-model model.pkl

# Scan multiple models and directories
promptfoo scan-model model.pkl model2.h5 models_directory

# Export results to JSON
promptfoo scan-model model.pkl --format json --output results.json

# Add custom blacklist patterns
promptfoo scan-model model.pkl --blacklist "unsafe_model" --blacklist "malicious_net"

# Strict mode for security-critical deployments
promptfoo scan-model ./models/ --strict

# Scan directly from HuggingFace without downloading
promptfoo scan-model hf://meta-llama/Llama-3-8B

# Scan from cloud storage
promptfoo scan-model s3://my-bucket/models/custom-finetune.safetensors

# SARIF output for CI/CD
promptfoo scan-model ./models/ --strict --no-write --format sarif --output model-scan-results.sarif
```

## Detection Categories

| Category | Examples |
|---|---|
| Pickle attacks | Dangerous opcodes, arbitrary code on deserialization |
| TensorFlow | Suspicious operations, Keras Lambda layers |
| Embedded executables | PE, ELF, Mach-O binaries |
| Credentials | API keys, tokens, passwords |
| Network patterns | URLs, IPs, socket operations |
| Encoded payloads | Base64, hex, obfuscated code |
| Weight anomalies | Backdoor indicators |

## When to Use Static Scanning

Scan model files when:
- Downloading models from HuggingFace, Civitai, or other repositories
- Receiving fine-tuned models from vendors or internal teams
- Pulling models from cloud storage (S3, GCS, Azure Blob)
- Building container images that include model weights

## CI/CD Integration

```yaml
# .github/workflows/model-scan.yml
name: Model Security Scan
on:
  push:
    paths:
      - 'models/**'
  pull_request:
    paths:
      - 'models/**'
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          npm install -g promptfoo
          pip install modelaudit
      - name: Scan models
        run: |
          promptfoo scan-model ./models/ \
            --strict \
            --no-write \
            --format sarif \
            --output model-scan-results.sarif
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: model-scan-results.sarif
```

## Limitations

Static scanning CANNOT detect:
- How the model behaves at inference time
- Whether safety training has been degraded
- Subtle behavioral backdoors triggered by specific inputs
- Whether the model meets your security requirements

**Static scanning is necessary but not sufficient.** Always pair with dynamic red team testing.